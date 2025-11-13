using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VitalSphere.Services.Database
{
    public class Gift
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public User User { get; set; } = null!;

        [ForeignKey(nameof(WellnessBox))]
        public int WellnessBoxId { get; set; }
        public WellnessBox WellnessBox { get; set; } = null!;

        [ForeignKey(nameof(GiftStatus))]
        public int GiftStatusId { get; set; }
        public GiftStatus GiftStatus { get; set; } = null!;

        public DateTime GiftedAt { get; set; } = DateTime.UtcNow;
    }
}

