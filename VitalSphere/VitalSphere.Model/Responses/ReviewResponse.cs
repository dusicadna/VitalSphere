using System;

namespace VitalSphere.Model.Responses
{
    public class ReviewResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserFullName { get; set; } = string.Empty;
        public int AppointmentId { get; set; }
        public int WellnessServiceId { get; set; }
        public string WellnessServiceName { get; set; } = string.Empty;
        public byte[]? WellnessServiceImage { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}

