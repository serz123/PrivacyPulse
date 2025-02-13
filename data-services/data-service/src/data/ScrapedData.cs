using System.Text.Json.Serialization;

namespace data_service.src.data
{
    public class ScrapedData
    {
        [JsonPropertyName("id")]
        public required Guid Id { get; set; } = Guid.NewGuid();

        [JsonPropertyName("email")]  // Foreign key
        public String Email { get; set; }

        [JsonPropertyName("nameOccurrences")]
        public int NameOccurrences { get; set; }

        [JsonPropertyName("emailOccurrences")]
        public int EmailOccurrences { get; set; }
        
        [JsonPropertyName("linkedInLink")]
        public string? LinkedInLink { get; set; }

        [JsonPropertyName("linkedInTitle")]
        public string? LinkedInTitle { get; set; }
        
        [JsonPropertyName("linkedInSnippet")]
        public string? LinkedInSnippet { get; set; }

        [JsonPropertyName("linkedInDescription")]
        public string? LinkedInDescription { get; set; }

        [JsonPropertyName("dateScraped")]
        public DateTime DateScraped { get; set; }

        public User User { get; set; }
    }
}