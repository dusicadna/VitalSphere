using System.ComponentModel.DataAnnotations;

namespace VitalSphere.Model.Requests
{
    public class WellnessServiceUpsertRequest
    {
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(1000)]
        public string? Description { get; set; }

        public byte[]? Image { get; set; }

        [Required]
        [Range(0.01, 10000)]
        public decimal Price { get; set; }

        [Range(1, 1440)]
        public int? DurationMinutes { get; set; }

        public bool IsActive { get; set; } = true;

        [Required]
        public int WellnessServiceCategoryId { get; set; }
    }
}

