using data_service.src.helpers;
using Microsoft.EntityFrameworkCore.Metadata;
using RabbitMQ.Client;
using Serilog;
namespace data_service.src.services
{
    public class RabbitMQService
    {
        private readonly string _hostName;
        private readonly int _port;
        private IConnection _connection;
        private IChannel _channel;

        public RabbitMQService(string hostName)
        {
            _hostName = hostName;
            _port = 5672;
        }

        public async 
        Task
Connect()
        {
            try
            {
                var factory = new ConnectionFactory()
                {
                    HostName = _hostName,
                    Port = 5672
                };

                _connection = await factory.CreateConnectionAsync();
                _channel = await _connection.CreateChannelAsync();

                // Declare a queue (you can adjust this as needed)
                await _channel.QueueDeclareAsync(
                    queue: "startScrapingDataQueue",
                    durable: false,    // Whether the queue survives server restarts
                    exclusive: false,  // Whether the queue is exclusive to the connection
                    autoDelete: false  // Whether the queue is deleted when unused
                );

                SimpleLogger.Log("Connected to RabbitMQ and declared queue.");
            }
            catch (Exception ex)
            {
                Log.Fatal(ex, "Error connecting to RabbitMQ.");
                throw;  // Ensure the app doesn't run if RabbitMQ connection fails
            }
        }

        public IChannel GetChannel()
        {
            return _channel;
        }

        public void CloseConnection()
        {
            _channel?.CloseAsync();
            _connection?.CloseAsync();
        }
    }
}