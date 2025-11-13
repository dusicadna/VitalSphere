using System.ComponentModel.DataAnnotations;

namespace VitalSphere.Model.Requests
{
    public class ReviewUpsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int AppointmentId { get; set; }

        [Range(1, 5)]
        public int Rating { get; set; }

        [MaxLength(1000)]
        public string? Comment { get; set; }
    }
}

