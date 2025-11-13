using System;

namespace VitalSphere.Model.Responses
{
    public class WellnessServiceResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public byte[]? Image { get; set; }
        public decimal Price { get; set; }
        public int? DurationMinutes { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public int WellnessServiceCategoryId { get; set; }
        public string WellnessServiceCategoryName { get; set; } = string.Empty;
    }
}

