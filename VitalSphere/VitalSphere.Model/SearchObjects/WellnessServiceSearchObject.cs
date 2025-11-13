namespace VitalSphere.Model.SearchObjects
{
    public class WellnessServiceSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public bool? IsActive { get; set; }
        public int? WellnessServiceCategoryId { get; set; }
    }
}

