using System.Text.Json.Serialization;

namespace Authentication.src.data
{
    public class UserDTO
    {
        [JsonPropertyName("id")]
        public required Guid Id { get; set; }

        [JsonPropertyName("name")]
        public required string Name { get; set; }

        [JsonPropertyName("Email")]
        public required string Email { get; set; }

        [JsonPropertyName("Picture")]
        public required string Picture { get; set; }
    }
}
