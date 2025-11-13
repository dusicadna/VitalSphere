using System;

namespace VitalSphere.Subscriber.Models
{
    public class AppointmentNotificationDto
    {
        public string UserEmail { get; set; } = string.Empty;
        public string UserFullName { get; set; } = string.Empty;
        public string WellnessServiceName { get; set; } = string.Empty;
        public string WellnessServiceCategoryName { get; set; } = string.Empty;
        public DateTime ScheduledAt { get; set; }
        public string? Notes { get; set; }
    }
}

