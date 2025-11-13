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
        private const int EarnedStatusId = 1;
        private const int PickedUpStatusId = 2;

        public GiftService(VitalSphereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Gift> ApplyFilter(IQueryable<Gift> query, GiftSearchObject search)
        {
            query = query.Include(g => g.User)
                         .Include(g => g.WellnessBox)
                         .Include(g => g.GiftStatus);

            if (search.UserId.HasValue)
            {
                query = query.Where(g => g.UserId == search.UserId.Value);
            }

            if (search.WellnessBoxId.HasValue)
            {
                query = query.Where(g => g.WellnessBoxId == search.WellnessBoxId.Value);
            }

            if (search.GiftStatusId.HasValue)
            {
                query = query.Where(g => g.GiftStatusId == search.GiftStatusId.Value);
            }

            return query;
        }

        public override async Task<GiftResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Gifts
                .Include(g => g.User)
                .Include(g => g.WellnessBox)
                .Include(g => g.GiftStatus)
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
                GiftedAt = entity.GiftedAt,
                GiftStatusId = entity.GiftStatusId,
                GiftStatusName = entity.GiftStatus?.Name ?? string.Empty
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

            var statusId = request.GiftStatusId ?? EarnedStatusId;
            var status = await _context.GiftStatuses.FindAsync(statusId);

            if (status == null)
            {
                throw new InvalidOperationException("The specified gift status does not exist.");
            }

            entity.GiftStatusId = statusId;
            entity.GiftStatus = status;
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

            if (request.GiftStatusId.HasValue)
            {
                var statusId = request.GiftStatusId.Value;

                var status = await _context.GiftStatuses.FindAsync(statusId);

                if (status == null)
                {
                    throw new InvalidOperationException("The specified gift status does not exist.");
                }

                entity.GiftStatusId = statusId;
                entity.GiftStatus = status;
            }

            entity.GiftedAt = request.GiftedAt ?? entity.GiftedAt;
        }

        public async Task<GiftResponse?> MarkAsPickedUpAsync(int id)
        {
            var entity = await _context.Gifts
                .Include(g => g.User)
                .Include(g => g.WellnessBox)
                .Include(g => g.GiftStatus)
                .FirstOrDefaultAsync(g => g.Id == id);

            if (entity == null)
            {
                return null;
            }

            if (entity.GiftStatusId == PickedUpStatusId)
            {
                return MapToResponse(entity);
            }

            var pickedUpStatus = await _context.GiftStatuses.FindAsync(PickedUpStatusId);

            if (pickedUpStatus == null)
            {
                throw new InvalidOperationException("Picked up gift status is not configured.");
            }

            entity.GiftStatusId = PickedUpStatusId;
            entity.GiftStatus = pickedUpStatus;

            await _context.SaveChangesAsync();

            return MapToResponse(entity);
        }
    }
}

