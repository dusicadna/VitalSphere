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
    public class WellnessServiceService : BaseCRUDService<WellnessServiceResponse, WellnessServiceSearchObject, WellnessService, WellnessServiceUpsertRequest, WellnessServiceUpsertRequest>, IWellnessServiceService
    {
        public WellnessServiceService(VitalSphereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<WellnessService> ApplyFilter(IQueryable<WellnessService> query, WellnessServiceSearchObject search)
        {
            query = query.Include(ws => ws.WellnessServiceCategory);

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(ws => ws.Name.Contains(search.Name));
            }

            if (search.MinPrice.HasValue)
            {
                query = query.Where(ws => ws.Price >= search.MinPrice.Value);
            }

            if (search.MaxPrice.HasValue)
            {
                query = query.Where(ws => ws.Price <= search.MaxPrice.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(ws => ws.IsActive == search.IsActive.Value);
            }

            if (search.WellnessServiceCategoryId.HasValue)
            {
                query = query.Where(ws => ws.WellnessServiceCategoryId == search.WellnessServiceCategoryId.Value);
            }

            return query;
        }

        public override async Task<WellnessServiceResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.WellnessServices
                .Include(ws => ws.WellnessServiceCategory)
                .FirstOrDefaultAsync(ws => ws.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override WellnessServiceResponse MapToResponse(WellnessService entity)
        {
            var response = base.MapToResponse(entity);
            response.WellnessServiceCategoryId = entity.WellnessServiceCategoryId;
            response.WellnessServiceCategoryName = entity.WellnessServiceCategory?.Name ?? string.Empty;
            return response;
        }

        protected override async Task BeforeInsert(WellnessService entity, WellnessServiceUpsertRequest request)
        {
            if (await _context.WellnessServices.AnyAsync(ws => ws.Name == request.Name))
            {
                throw new InvalidOperationException("A wellness service with this name already exists.");
            }

            if (!await _context.WellnessServiceCategories.AnyAsync(c => c.Id == request.WellnessServiceCategoryId))
            {
                throw new InvalidOperationException("The specified wellness service category does not exist.");
            }

            entity.CreatedAt = DateTime.UtcNow;
        }

        protected override async Task BeforeUpdate(WellnessService entity, WellnessServiceUpsertRequest request)
        {
            if (await _context.WellnessServices.AnyAsync(ws => ws.Name == request.Name && ws.Id != entity.Id))
            {
                throw new InvalidOperationException("A wellness service with this name already exists.");
            }

            if (!await _context.WellnessServiceCategories.AnyAsync(c => c.Id == request.WellnessServiceCategoryId))
            {
                throw new InvalidOperationException("The specified wellness service category does not exist.");
            }
        }
    }
}

