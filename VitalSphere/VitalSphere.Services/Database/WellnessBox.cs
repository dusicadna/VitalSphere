using System;
using System.ComponentModel.DataAnnotations;

namespace VitalSphere.Services.Database
{
    public class WellnessBox
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(150)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? Description { get; set; }

        public byte[]? Image { get; set; }

        [MaxLength(1000)]
        public string? IncludedItems { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<Gift> Gifts { get; set; } = new List<Gift>();
    }
}

