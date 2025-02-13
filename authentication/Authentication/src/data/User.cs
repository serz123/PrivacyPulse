using System.Text.Json.Serialization;

namespace Authentication.src.data
{
    public class User
    {
        [JsonPropertyName("id")]
        public required Guid Id { get; set; }

        [JsonPropertyName("name")]
        public required string Name { get; set; }

        [JsonPropertyName("Email")]
        public required string Email { get; set; }

        [JsonPropertyName("Picture")]
        public required string Picture { get; set; }

        [JsonPropertyName("OauthSubject")]
        public required string OauthSubject { get; set; }

        [JsonPropertyName("OauthIssuer")]
        public required string OauthIssuer { get; set; }
        
        public ICollection<ScrapedData> ScrapedDatas { get; set; }
    }
}
