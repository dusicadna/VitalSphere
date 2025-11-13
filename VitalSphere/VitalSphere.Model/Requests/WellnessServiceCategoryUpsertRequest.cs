using System.ComponentModel.DataAnnotations;

namespace VitalSphere.Model.Requests
{
    public class WellnessServiceCategoryUpsertRequest
    {
        [Required]
        [MaxLength(150)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? Description { get; set; }

        public byte[]? Image { get; set; }

        public bool IsActive { get; set; } = true;
    }
}

