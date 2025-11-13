using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace VitalSphere.Services.Database
{
    public class WellnessServiceCategory
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(150)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? Description { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public byte[]? Image { get; set; }

        public ICollection<WellnessService> WellnessServices { get; set; } = new List<WellnessService>();
    }
}

