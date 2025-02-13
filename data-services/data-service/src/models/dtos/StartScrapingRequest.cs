using System.ComponentModel.DataAnnotations;

namespace data_service.src.dtos
{
    public class StartScrapingRequest
    {
        [Required(ErrorMessage = "UserId is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "UserId must be greater than 0.")]
        public int userId { get; set; }
    }
}