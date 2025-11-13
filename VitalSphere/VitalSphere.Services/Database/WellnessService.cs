using System;
using System.ComponentModel.DataAnnotations;

namespace VitalSphere.Services.Database
{
    public class WellnessService
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(1000)]
        public string? Description { get; set; }

        public byte[]? Image { get; set; }

        [Required]
        [Range(0.01, 10000)]
        public decimal Price { get; set; }

        /// <summary>
        /// Duration of the service in minutes.
        /// </summary>
        [Range(1, 1440)]
        public int? DurationMinutes { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Required]
        public int WellnessServiceCategoryId { get; set; }
        public WellnessServiceCategory WellnessServiceCategory { get; set; } = null!;

        public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
    }
}

