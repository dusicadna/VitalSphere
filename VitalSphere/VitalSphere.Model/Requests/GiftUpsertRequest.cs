using System;
using System.ComponentModel.DataAnnotations;

namespace VitalSphere.Model.Requests
{
    public class GiftUpsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int WellnessBoxId { get; set; }

        public DateTime? GiftedAt { get; set; }

        public int? GiftStatusId { get; set; }
    }
}

