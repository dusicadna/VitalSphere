namespace VitalSphere.Model.SearchObjects
{
    public class ProductSubcategorySearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public bool? IsActive { get; set; }
        public int? ProductCategoryId { get; set; }
    }
}

