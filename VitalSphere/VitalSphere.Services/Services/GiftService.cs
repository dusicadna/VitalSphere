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
    public class GiftService : BaseCRUDService<GiftResponse, GiftSearchObject, Gift, GiftUpsertRequest, GiftUpsertRequest>, IGiftService
    {
        public GiftService(VitalSphereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Gift> ApplyFilter(IQueryable<Gift> query, GiftSearchObject search)
        {
            query = query.Include(g => g.User)
                         .Include(g => g.WellnessBox);

            if (search.UserId.HasValue)
            {
                query = query.Where(g => g.UserId == search.UserId.Value);
            }

            if (search.WellnessBoxId.HasValue)
            {
                query = query.Where(g => g.WellnessBoxId == search.WellnessBoxId.Value);
            }

            return query;
        }

        public override async Task<GiftResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Gifts
                .Include(g => g.User)
                .Include(g => g.WellnessBox)
                .FirstOrDefaultAsync(g => g.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override GiftResponse MapToResponse(Gift entity)
        {
            return new GiftResponse
            {
                Id = entity.Id,
                UserId = entity.UserId,
                UserName = $"{entity.User?.FirstName} {entity.User?.LastName}".Trim(),
                WellnessBoxId = entity.WellnessBoxId,
                WellnessBoxName = entity.WellnessBox?.Name ?? string.Empty,
                GiftedAt = entity.GiftedAt
            };
        }

        protected override async Task BeforeInsert(Gift entity, GiftUpsertRequest request)
        {
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("The specified user does not exist.");
            }

            if (!await _context.WellnessBoxes.AnyAsync(wb => wb.Id == request.WellnessBoxId))
            {
                throw new InvalidOperationException("The specified wellness box does not exist.");
            }

            entity.GiftedAt = request.GiftedAt ?? DateTime.UtcNow;
        }

        protected override async Task BeforeUpdate(Gift entity, GiftUpsertRequest request)
        {
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("The specified user does not exist.");
            }

            if (!await _context.WellnessBoxes.AnyAsync(wb => wb.Id == request.WellnessBoxId))
            {
                throw new InvalidOperationException("The specified wellness box does not exist.");
            }

            entity.GiftedAt = request.GiftedAt ?? entity.GiftedAt;
        }
    }
}

