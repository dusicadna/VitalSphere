using System;

namespace VitalSphere.Model.Responses
{
    public class AppointmentResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int WellnessServiceId { get; set; }
        public string WellnessServiceName { get; set; } = string.Empty;
        public byte[]? WellnessServiceImage { get; set; }
        public DateTime ScheduledAt { get; set; }
        public string? Notes { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}

