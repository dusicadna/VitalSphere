using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace VitalSphere.Services.Database
{
    public class GiftStatus
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(250)]
        public string? Description { get; set; }

        public ICollection<Gift> Gifts { get; set; } = new List<Gift>();
    }
}

