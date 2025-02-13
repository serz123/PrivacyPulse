using System.Text.Json.Serialization;

namespace Authentication.src.data
{
    public class ScrapedData
    {
        [JsonPropertyName("id")]
        public required Guid Id { get; set; } = Guid.NewGuid();

        [JsonPropertyName("Email")]  // Foreign key
        public String Email { get; set; }

        [JsonPropertyName("nameOccurences")]
        public int NameOccurrences { get; set; }

        [JsonPropertyName("emailOccurences")]
        public int EmailOccurrences { get; set; }
        
        [JsonPropertyName("linkedinLink")]
        public string? LinkedInLink { get; set; }

        [JsonPropertyName("LinkedInTitle")]
        public string? LinkedInTitle { get; set; }
        
        [JsonPropertyName("LinkedInSnippet")]
        public string? LinkedInSnippet { get; set; }

        [JsonPropertyName("LinkedInDescription")]
        public string? LinkedInDescription { get; set; }

        [JsonPropertyName("dateScraped")]
        public DateTime DateScraped { get; set; }

        public User User { get; set; }
    }
}