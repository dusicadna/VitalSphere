using System;

namespace VitalSphere.Model.Responses
{
    public class GiftResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int WellnessBoxId { get; set; }
        public string WellnessBoxName { get; set; } = string.Empty;
        public DateTime GiftedAt { get; set; }
    }
}

