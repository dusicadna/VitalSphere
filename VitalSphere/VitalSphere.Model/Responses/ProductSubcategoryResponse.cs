namespace VitalSphere.Model.Responses
{
    public class ProductSubcategoryResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool IsActive { get; set; }
        public int ProductCategoryId { get; set; }
        public string ProductCategoryName { get; set; } = string.Empty;
    }
}

