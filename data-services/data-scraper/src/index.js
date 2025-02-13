import {  startConsumingMessages } from "./scraper.js"
import { getScrapingData } from "./scraper.js" 

// ========================================================
// getScrapingData is sent to the queue
// ========================================================

startConsumingMessages()

/*(async () => {
   const name = "Vanja Maric"
   const email = "manoleann@gmail.com"
   const city = "Göteborg"
   const collegeName = "Linnaeus University"

   try {
       const results = await getScrapingData(name, email, city, collegeName)
       console.log('Results:', results);
       console.log(JSON.stringify(results, null, 2));

   } catch (err) {
       console.error('Error:', err.message);
   }
 })();
*/