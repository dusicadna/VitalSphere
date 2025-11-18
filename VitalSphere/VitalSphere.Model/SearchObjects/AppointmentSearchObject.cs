namespace VitalSphere.Model.SearchObjects
{
    public class AppointmentSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public string? UserFullName { get; set; }
        public string? WellnessServiceName { get; set; }
    }
}

