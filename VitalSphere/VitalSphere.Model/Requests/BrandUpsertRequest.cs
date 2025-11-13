using System.ComponentModel.DataAnnotations;

namespace VitalSphere.Model.Requests
{
    public class BrandUpsertRequest
    {
        [Required]
        [MaxLength(150)]
        public string Name { get; set; } = string.Empty;

        public bool IsActive { get; set; } = true;
    }
}

