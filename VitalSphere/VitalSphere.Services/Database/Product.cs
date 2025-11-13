using System;
using System.ComponentModel.DataAnnotations;

namespace VitalSphere.Services.Database
{
    public class Product
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        public decimal Price { get; set; }
        
        public byte[]? Picture { get; set; }
        public bool IsActive { get; set; } = true;

        [Required]
        public int ProductSubcategoryId { get; set; }
        public ProductSubcategory ProductSubcategory { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
