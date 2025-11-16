using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using VitalSphere.Model.Responses;
using VitalSphere.Services.Database;
using VitalSphere.Services.Interfaces;

namespace VitalSphere.Services.Services
{
    public class BusinessReportService : IBusinessReportService
    {
        private readonly VitalSphereDbContext _context;

        public BusinessReportService(VitalSphereDbContext context)
        {
            _context = context;
        }

        public async Task<BusinessReportResponse> GetBusinessReportAsync()
        {
            // Top 3 sold products (by quantity sold)
            var top3SoldProducts = await (from oi in _context.OrderItems
                                         join o in _context.Orders on oi.OrderId equals o.Id
                                         where o.IsActive
                                         group oi by oi.ProductId into g
                                         select new
                                         {
                                             ProductId = g.Key,
                                             TotalQuantitySold = g.Sum(oi => oi.Quantity),
                                             TotalRevenue = g.Sum(oi => oi.TotalPrice)
                                         })
                .OrderByDescending(x => x.TotalQuantitySold)
                .Take(3)
                .Join(_context.Products,
                    g => g.ProductId,
                    p => p.Id,
                    (g, p) => new TopProductResponse
                    {
                        ProductId = p.Id,
                        ProductName = p.Name,
                        ProductImage = p.Picture,
                        TotalQuantitySold = g.TotalQuantitySold,
                        TotalRevenue = g.TotalRevenue
                    })
                .ToListAsync();

            // Top 3 services used (by number of appointments)
            var top3ServicesUsed = await (from a in _context.Appointments
                                         join s in _context.WellnessServices on a.WellnessServiceId equals s.Id
                                         group new { a, s } by a.WellnessServiceId into g
                                         select new
                                         {
                                             ServiceId = g.Key,
                                             TotalAppointments = g.Count(),
                                             TotalRevenue = g.Sum(x => x.s.Price)
                                         })
                .OrderByDescending(x => x.TotalAppointments)
                .Take(3)
                .Join(_context.WellnessServices,
                    g => g.ServiceId,
                    s => s.Id,
                    (g, s) => new TopServiceResponse
                    {
                        ServiceId = s.Id,
                        ServiceName = s.Name,
                        ServiceImage = s.Image,
                        TotalAppointments = g.TotalAppointments,
                        TotalRevenue = g.TotalRevenue
                    })
                .ToListAsync();

            // Money generated from products (sum of all order items from active orders)
            var moneyGeneratedFromProducts = await (from oi in _context.OrderItems
                                                   join o in _context.Orders on oi.OrderId equals o.Id
                                                   where o.IsActive
                                                   select oi.TotalPrice)
                .SumAsync();

            // Money generated from services (sum of all appointment prices)
            var moneyGeneratedFromServices = await (from a in _context.Appointments
                                                    join s in _context.WellnessServices on a.WellnessServiceId equals s.Id
                                                    select s.Price)
                .SumAsync();

            // Best reviewed service (highest average rating)
            var bestReviewedService = await (from r in _context.Reviews
                                             join a in _context.Appointments on r.AppointmentId equals a.Id
                                             group r by a.WellnessServiceId into g
                                             select new
                                             {
                                                 ServiceId = g.Key,
                                                 AverageRating = g.Average(r => (double)r.Rating),
                                                 ReviewCount = g.Count()
                                             })
                .OrderByDescending(x => x.AverageRating)
                .ThenByDescending(x => x.ReviewCount)
                .FirstOrDefaultAsync();

            BestReviewedServiceResponse? bestReviewedServiceResponse = null;
            if (bestReviewedService != null)
            {
                var service = await _context.WellnessServices
                    .FirstOrDefaultAsync(s => s.Id == bestReviewedService.ServiceId);
                
                if (service != null)
                {
                    bestReviewedServiceResponse = new BestReviewedServiceResponse
                    {
                        ServiceId = service.Id,
                        ServiceName = service.Name,
                        ServiceImage = service.Image,
                        AverageRating = Math.Round(bestReviewedService.AverageRating, 2),
                        ReviewCount = bestReviewedService.ReviewCount
                    };
                }
            }

            // User with most services done (most appointments)
            var userWithMostServices = await _context.Appointments
                .GroupBy(a => a.UserId)
                .Select(g => new
                {
                    UserId = g.Key,
                    TotalServicesCount = g.Count()
                })
                .OrderByDescending(x => x.TotalServicesCount)
                .FirstOrDefaultAsync();

            UserWithMostServicesResponse? userWithMostServicesResponse = null;
            if (userWithMostServices != null)
            {
                var user = await _context.Users
                    .FirstOrDefaultAsync(u => u.Id == userWithMostServices.UserId);
                
                if (user != null)
                {
                    userWithMostServicesResponse = new UserWithMostServicesResponse
                    {
                        UserId = user.Id,
                        UserFullName = $"{user.FirstName} {user.LastName}".Trim(),
                        UserImage = user.Picture,
                        TotalServicesCount = userWithMostServices.TotalServicesCount
                    };
                }
            }

            return new BusinessReportResponse
            {
                Top3SoldProducts = top3SoldProducts,
                Top3ServicesUsed = top3ServicesUsed,
                MoneyGeneratedFromProducts = moneyGeneratedFromProducts,
                MoneyGeneratedFromServices = moneyGeneratedFromServices,
                BestReviewedService = bestReviewedServiceResponse,
                UserWithMostServices = userWithMostServicesResponse
            };
        }
    }
}

