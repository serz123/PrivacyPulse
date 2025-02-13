using data_service.src.data;

namespace data_service.src.services
{
    public interface IDataService
    {
        void StartConsumingMessages();
         Task<ScrapedData> GetScrapedData(string email);
         Task PushMessageToQueueAsync(string messageEmail, string messageName, string messageCity, string messageCollegeName);
    }
}