namespace VitalSphere.Model.SearchObjects
{
    public class ProductSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public bool? IsActive { get; set; }
        public int? ProductSubcategoryId { get; set; }
        public int? ProductCategoryId { get; set; }
        public int? BrandId { get; set; }
    }
}
