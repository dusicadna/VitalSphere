using System;
using System.Collections.Generic;

namespace VitalSphere.Model.Responses
{
    public class BusinessReportResponse
    {
        public List<TopProductResponse> Top3SoldProducts { get; set; } = new List<TopProductResponse>();
        public List<TopServiceResponse> Top3ServicesUsed { get; set; } = new List<TopServiceResponse>();
        public decimal MoneyGeneratedFromProducts { get; set; }
        public decimal MoneyGeneratedFromServices { get; set; }
        public BestReviewedServiceResponse? BestReviewedService { get; set; }
        public UserWithMostServicesResponse? UserWithMostServices { get; set; }
    }

    public class TopProductResponse
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public byte[]? ProductImage { get; set; }
        public int TotalQuantitySold { get; set; }
        public decimal TotalRevenue { get; set; }
    }

    public class TopServiceResponse
    {
        public int ServiceId { get; set; }
        public string ServiceName { get; set; } = string.Empty;
        public byte[]? ServiceImage { get; set; }
        public int TotalAppointments { get; set; }
        public decimal TotalRevenue { get; set; }
    }

    public class BestReviewedServiceResponse
    {
        public int ServiceId { get; set; }
        public string ServiceName { get; set; } = string.Empty;
        public byte[]? ServiceImage { get; set; }
        public double AverageRating { get; set; }
        public int ReviewCount { get; set; }
    }

    public class UserWithMostServicesResponse
    {
        public int UserId { get; set; }
        public string UserFullName { get; set; } = string.Empty;
        public byte[]? UserImage { get; set; }
        public int TotalServicesCount { get; set; }
    }
}

