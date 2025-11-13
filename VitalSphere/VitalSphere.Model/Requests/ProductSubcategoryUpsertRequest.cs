using System.ComponentModel.DataAnnotations;

namespace VitalSphere.Model.Requests
{
    public class ProductSubcategoryUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(250)]
        public string? Description { get; set; }

        [Required]
        public int ProductCategoryId { get; set; }

        public bool IsActive { get; set; } = true;
    }
}

