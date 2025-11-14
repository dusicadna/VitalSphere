using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;
using VitalSphere.Services.Database;
using VitalSphere.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace VitalSphere.Services.Services
{
    public class ReviewService : BaseCRUDService<ReviewResponse, ReviewSearchObject, Review, ReviewUpsertRequest, ReviewUpsertRequest>, IReviewService
    {
        public ReviewService(VitalSphereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewSearchObject search)
        {
            query = query.Include(r => r.User)
                         .Include(r => r.Appointment)
                         .ThenInclude(a => a.WellnessService);

            if (search.UserId.HasValue)
            {
                query = query.Where(r => r.UserId == search.UserId.Value);
            }

            if (search.AppointmentId.HasValue)
            {
                query = query.Where(r => r.AppointmentId == search.AppointmentId.Value);
            }

            if (search.WellnessServiceId.HasValue)
            {
                query = query.Where(r => r.Appointment.WellnessServiceId == search.WellnessServiceId.Value);
            }

            if (search.Rating.HasValue)
            {
                query = query.Where(r => r.Rating == search.Rating.Value);
            }

            return query;
        }

        public override async Task<ReviewResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Appointment)
                .ThenInclude(a => a.WellnessService)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override ReviewResponse MapToResponse(Review entity)
        {
            return new ReviewResponse
            {
                Id = entity.Id,
                UserId = entity.UserId,
                UserFullName = $"{entity.User?.FirstName} {entity.User?.LastName}".Trim(),
                AppointmentId = entity.AppointmentId,
                WellnessServiceId = entity.Appointment?.WellnessServiceId ?? 0,
                WellnessServiceName = entity.Appointment?.WellnessService?.Name ?? string.Empty,
                WellnessServiceImage = entity.Appointment?.WellnessService?.Image,
                Rating = entity.Rating,
                Comment = entity.Comment,
                CreatedAt = entity.CreatedAt
            };
        }

        protected override async Task BeforeInsert(Review entity, ReviewUpsertRequest request)
        {
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("The specified user does not exist.");
            }

            var appointment = await _context.Appointments
                .Include(a => a.Review)
                .FirstOrDefaultAsync(a => a.Id == request.AppointmentId);

            if (appointment == null)
            {
                throw new InvalidOperationException("The specified appointment does not exist.");
            }

            if (appointment.UserId != request.UserId)
            {
                throw new InvalidOperationException("The appointment does not belong to the specified user.");
            }

            if (appointment.Review != null)
            {
                throw new InvalidOperationException("This appointment already has a review.");
            }

            entity.CreatedAt = DateTime.UtcNow;
        }

        protected override async Task BeforeUpdate(Review entity, ReviewUpsertRequest request)
        {
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("The specified user does not exist.");
            }

            var appointment = await _context.Appointments
                .Include(a => a.Review)
                .FirstOrDefaultAsync(a => a.Id == request.AppointmentId);

            if (appointment == null)
            {
                throw new InvalidOperationException("The specified appointment does not exist.");
            }

            if (appointment.UserId != request.UserId)
            {
                throw new InvalidOperationException("The appointment does not belong to the specified user.");
            }

            if (appointment.Review != null && appointment.Review.Id != entity.Id)
            {
                throw new InvalidOperationException("This appointment already has a different review.");
            }
        }
    }
}

