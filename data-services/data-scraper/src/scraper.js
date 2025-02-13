import { connectToRabbitMQ, getRabbitMQChannel } from "./config/rabbitmq.js";
import fetch from "node-fetch"; 
import { JSDOM } from 'jsdom';

const apiKey = process.env.API_KEY;
console.log("Api key:", apiKey);
const searchEngineId = process.env.SEARCH_ENGINE_ID;
const baseURL = "https://www.googleapis.com/customsearch/v1";

/**
 * Start consuming messages from the RabbitMQ queue and process them
 */
export async function startConsumingMessages() {
  try {
    // Connect to RabbitMQ and declare the queue
    await connectToRabbitMQ(
      `amqp://guest:guest@${process.env.RABBITMQ_HOST}`,
      "startScrapingDataQueue"
    );

    const channel = getRabbitMQChannel();
    const queue = "startScrapingDataQueue";
    const resultsQueue = "scrapingResultsQueue";

    // Declare the results queue
    channel.assertQueue(resultsQueue, { durable: true });

    console.log(`Waiting for messages in queue: ${queue}`);

    channel.consume(queue, async (msg) => {
      if (msg !== null) {
        try {
          const messageContent = msg.content.toString();
          console.log("Received message:", messageContent);

          // Parse the message content
          const parsedMessage = JSON.parse(messageContent);

          // Get scraping data
          const scrapingResults = await getScrapingData(
            parsedMessage.Name,
            parsedMessage.Email,
            parsedMessage.City,
            parsedMessage.CollegeName
          );

          // Send the results to the results queue
          channel.sendToQueue(
            resultsQueue,
            Buffer.from(JSON.stringify(scrapingResults)),
            { persistent: true }
          );

          console.log(`Results sent to ${resultsQueue}:`, scrapingResults);

          channel.ack(msg);
        } catch (err) {
          console.error("Error processing message:", err);
          channel.nack(msg);
        }
      }
    });
  } catch (error) {
    console.error("Error in consuming messages:", error);
  }
}

export async function getOccurrences(query) {
  const parameters = {
    key: apiKey,
    cx: searchEngineId,
    q: query
  };

  try {
    const response = await fetch(`${baseURL}?${new URLSearchParams(parameters)}`);
    if (!response.ok) {
      throw new Error(`API Error: ${response.status} ${response.statusText}`);
    }

    const data = await response.json();
    // Validate the existence of searchInformation and totalResults
    const totalResults = data.searchInformation?.totalResults ? parseInt(data.searchInformation.totalResults, 10) : 0;
    return totalResults;
  } catch (error) {
    console.error('Error fetching occurrences:', error.message);
    return 0; // Default to 0 if an error occurs
  }
}

export async function getLinkedinProfile(name, city, collegeName) {
  if (!name) throw new Error("Name is a required parameter.");

  // Construct the base query
  let query = `"${name}" site:linkedin.com/in/ ${city}`;
  if (city) query += ` ${city}`;
  if (collegeName) query += ` ${collegeName}`;

  const parameters = {
    key: apiKey,
    cx: searchEngineId,
    q: query,
  };

  try {
    const response = await fetch(`${baseURL}?${new URLSearchParams(parameters)}`);
    if (!response.ok) {
      throw new Error(`Error: ${response.status} ${response.statusText}`);
    }

    const data = await response.json();

    if (data.items && data.items.length > 0) {
      // Find the first result containing '/in/' in the link
      const firstLinkedInResult = data.items.find(item =>
        item.link.includes("/in/") && item.title.toLowerCase().includes(name.toLowerCase())
      );
    
      // If a result is found, return its relevant fields
      if (firstLinkedInResult) {
        return {
          title: firstLinkedInResult.title || 'No title found',
          link: firstLinkedInResult.link || 'No link found',
          snippet: firstLinkedInResult.snippet || 'No snippet available',
          description: firstLinkedInResult.pagemap.metatags?.[0]?.['og:description'] || 'No description available',
        };     
      }
    
      return "No LinkedIn profile found.";
    }

    return null;
  } catch (error) {
    console.error('Error fetching LinkedIn profiles:', error);
    return "Error fetching LinkedIn profiles.";
  }
}

// Works but cannot be integrated with the google search API
// Scraping in this way is not allowed after you get the linkedin profile - error 999
export async function searchLinkedInProfileWithBasicFetch(name, city, collegeName) {
  if (!name) throw new Error("Name is a required parameter.");

  const query = `${name} ${city} ${collegeName} linkedin.com`;
  const encodedQuery = encodeURIComponent(query);
  const googleSearchURL = `https://www.google.com/search?q=${encodedQuery}`;

  try {
    const response = await fetch(googleSearchURL);
    if (!response.ok) {
      console.log(response);

      throw new Error(`Error: ${response.status} ${response.statusText}`);
    }

    const text = await response.text();
    const dom = new JSDOM(text);
    const document = dom.window.document;
    const links = document.querySelectorAll('a[href*="linkedin.com/in/"]');

    for (const link of links) {
      let href = link.getAttribute('href');
      if (href) {
        href = href.startsWith('/url?') ? new URLSearchParams(href.split('?')[1]).get('q') : href;
        href = href.split('?')[0]; // Trim everything after the main profile part
        return href;
      }
    }

    return "No LinkedIn profile found.";
  } catch (error) {
    console.error('Error:', error);
    return "Error fetching LinkedIn profiles.";
  }
}

export async function getScrapingData(name, email, city, collegeName) {
   const nameOccurrences = await getOccurrences(name); // 1 query 
  const emailOccurrences = await getOccurrences(email); // 1 query
  const linkedinProfile = await getLinkedinProfile(name, city, collegeName)
   // Hardkodirane vrednosti
   /*const nameOccurrences = 5000; 
   const emailOccurrences = 100; 
   const linkedinProfile = {
     title: "Robert Milicevic - Software Developer",
     link: "https://www.linkedin.com/in/robertmilicevic/",
     snippet: "Experienced software developer skilled in Java and backend technologies.",
     description: "Robert Milicevic, a highly motivated developer with expertise in cloud and distributed systems.",
   };*/
 

  return {
    nameOccurrences,
    emailOccurrences,
    linkedinProfile,
    email,
  }
}
