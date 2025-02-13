
using System.ComponentModel.DataAnnotations;
using data_service.src.data;
using data_service.src.helpers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Serilog;

namespace data_service.src.services
{
    public class DataService : IDataService
    {
        private readonly MasterDbContext _masterContext;
        private readonly SlaveDbContext _slaveContext;
        private readonly RabbitMQService _rabbitMqService;

        public
        DataService(MasterDbContext masterContext, SlaveDbContext slaveContext, RabbitMQService rabbitMqService)
        {
            _masterContext = masterContext;
            _slaveContext = slaveContext;
            _rabbitMqService = rabbitMqService;
        }

        public void StartConsumingMessages()
        {
            var channel = _rabbitMqService.GetChannel();
            string queue = "scrapingResultsQueue";

            channel.QueueDeclareAsync(queue, durable: true, exclusive: false, autoDelete: false);

            var consumer = new AsyncEventingBasicConsumer(channel);

            // Attach an async handler to process received messages
            consumer.ReceivedAsync += async (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var messageJson = System.Text.Encoding.UTF8.GetString(body);
                Log.Information("Raw JSON received: {0}", messageJson);

                try
                {
                    // Parse the JSON to check for the "id" field
                    var jsonObject = System.Text.Json.JsonDocument.Parse(messageJson).RootElement;

                    // If "id" is missing or empty, create a new JSON object with an "id" field
                    if (!jsonObject.TryGetProperty("id", out var idElement) || string.IsNullOrEmpty(idElement.GetString()))
                    {
                        // Initialize LinkedIn profile properties with null values
                        string? linkedInTitle = null;
                        string? linkedInLink = null;
                        string? linkedInSnippet = null;
                        string? linkedInDescription = null;

                        // Check if "linkedinProfile" exists and its type
                        if (jsonObject.TryGetProperty("linkedinProfile", out var linkedinProfileElement))
                        {
                            if (linkedinProfileElement.ValueKind == System.Text.Json.JsonValueKind.Object)
                            {
                                // Extract properties from "linkedinProfile" object
                                linkedInTitle = linkedinProfileElement.TryGetProperty("title", out var titleElement)
                                    ? titleElement.GetString()
                                    : null;
                                linkedInLink = linkedinProfileElement.TryGetProperty("link", out var linkElement)
                                    ? linkElement.GetString()
                                    : null;
                                linkedInSnippet = linkedinProfileElement.TryGetProperty("snippet", out var snippetElement)
                                    ? snippetElement.GetString()
                                    : null;
                                linkedInDescription = linkedinProfileElement.TryGetProperty("description", out var descriptionElement)
                                    ? descriptionElement.GetString()
                                    : null;
                            }
                            else if (linkedinProfileElement.ValueKind == System.Text.Json.JsonValueKind.String)
                            {
                                // If "linkedinProfile" is a string, log the value and set all LinkedIn properties to null
                                linkedInDescription = linkedinProfileElement.GetString();
                                Log.Information("LinkedIn profile is a string: {0}", linkedInDescription);
                            }
                        }

                        // Generate a new ID and reconstruct the JSON
                        var jsonWithId = System.Text.Json.JsonSerializer.Serialize(new
                        {
                            id = Guid.NewGuid(), // Generate a new Iw
                            email = jsonObject.TryGetProperty("email", out var emailElement) ? emailElement.GetString() : null,
                            nameOccurrences = jsonObject.TryGetProperty("nameOccurrences", out var nameOccurrencesElement)
                                  ? nameOccurrencesElement.GetInt32() : 0,
                            emailOccurrences = jsonObject.TryGetProperty("emailOccurrences", out var emailOccurrencesElement)
                                   ? emailOccurrencesElement.GetInt32() : 0,
                            linkedInTitle,
                            linkedInLink,
                            linkedInSnippet,
                            linkedInDescription,
                            dateScraped = DateTime.UtcNow,
                        });

                        messageJson = jsonWithId;
                        Log.Information("Modified JSON with generated ID: {0}", messageJson);
                    }

                    // Deserialize the modified or original JSON into the ScrapedData object
                    var scrapedData = System.Text.Json.JsonSerializer.Deserialize<ScrapedData>(messageJson);

                    if (scrapedData != null)
                    {
                        _masterContext.ScrapedDatas.Add(scrapedData);
                        await _masterContext.SaveChangesAsync();
                        Log.Information("Data saved successfully.");
                    }

                    await channel.BasicAckAsync(ea.DeliveryTag, false);
                }
                catch (Exception ex)
                {
                    Log.Error("Error processing message: {0}", ex.Message);
                    await channel.BasicNackAsync(ea.DeliveryTag, false, true);
                }
            };



            // Start consuming messages
            channel.BasicConsumeAsync(queue: queue, autoAck: false, consumer: consumer);

            Log.Information("Started consuming messages from queue: {queue}", queue);

        }


        public async Task<ScrapedData> GetScrapedData(string email)
        {
            return await Task.FromResult(FindLatestData(email));
        }

        private ScrapedData FindLatestData(string email)
        {
            try
            {
                // Query the database to find all data associated with the provided email
                var latestScrapedData = _slaveContext.ScrapedDatas
                                                     .Where(u => u.Email == email)
                                                     .OrderByDescending(u => u.DateScraped) // Sort by date in descending order
                                                     .FirstOrDefault(); // Get the first result (most recent)

                // If no data is found, return a default object with placeholder values
                if (latestScrapedData == null)
                {
                    SimpleLogger.Log($"There is no scraped data. Returning new empty object!");
                    return new ScrapedData
                    {
                        Id = Guid.NewGuid(),  // Assign a new unique ID
                        Email = email,
                        DateScraped = DateTime.MinValue // Assign the default date value
                    };
                }

                SimpleLogger.Log($"Latest scraped data found.");
                return latestScrapedData; // Return the most recent result
            }
            catch (Exception ex)
            {
                // Log any errors that occur during the database query
                SimpleLogger.Log($"Error while fetching scraped data: {ex.Message}");

                // Return a default object in case of an error
                return new ScrapedData
                {
                    Id = Guid.NewGuid(),  // Assign a new unique ID
                    Email = email,
                    DateScraped = DateTime.MinValue // Assign the default date value
                };
            }
        }


        // Method to publish a message to the queue
        public async Task PushMessageToQueueAsync(string messageEmail, string messageName, string messageCity, string messageCollegeName)
        {
            Log.Information("PushMessageToQueueAsync");
            try
            {
                var channel = _rabbitMqService.GetChannel(); // Get the channel from RabbitMQService
                Log.Information($"{channel}");
                if (channel != null)
                {
                    // Create a message object
                    var messageObject = new
                    {
                        Email = messageEmail,
                        Name = messageName,
                        City = messageCity,
                        CollegeName = messageCollegeName
                    };

                    // Serialize the object to JSON
                    var messageJson = System.Text.Json.JsonSerializer.Serialize(messageObject);

                    // Convert the message to a byte array
                    var body = System.Text.Encoding.UTF8.GetBytes(messageJson);

                    // Create message properties
                    var props = new BasicProperties();
                    props.ContentType = "text/plain";  // Set content type (example)
                    props.DeliveryMode = (DeliveryModes)2;  // Persistent message

                    // Publish the message to the "dataQueue"
                    await channel.BasicPublishAsync(
                        exchange: "",          // Default exchange (direct exchange)
                        routingKey: "startScrapingDataQueue", // The queue name
                        mandatory: true,
                        basicProperties: props,
                        body: body
                    );

                    // Log the success message after the publish
                    Log.Information($"Message sent to queue: {messageJson}");
                }
            }
            catch (Exception ex)
            {
                // Log error if publishing fails
                Log.Error(ex, "Failed to publish message to RabbitMQ.");
            }
        }


    }
}