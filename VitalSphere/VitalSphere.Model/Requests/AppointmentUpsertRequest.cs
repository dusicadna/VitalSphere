using System;
using System.ComponentModel.DataAnnotations;

namespace VitalSphere.Model.Requests
{
    public class AppointmentUpsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int WellnessServiceId { get; set; }

        [Required]
        public DateTime ScheduledAt { get; set; }

        [MaxLength(500)]
        public string? Notes { get; set; }
    }
}

