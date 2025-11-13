namespace VitalSphere.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? AppointmentId { get; set; }
        public int? WellnessServiceId { get; set; }
        public int? Rating { get; set; }
    }
}

