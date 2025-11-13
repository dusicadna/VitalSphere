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
    public class WellnessServiceCategoryService : BaseCRUDService<WellnessServiceCategoryResponse, WellnessServiceCategorySearchObject, WellnessServiceCategory, WellnessServiceCategoryUpsertRequest, WellnessServiceCategoryUpsertRequest>, IWellnessServiceCategoryService
    {
        public WellnessServiceCategoryService(VitalSphereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<WellnessServiceCategory> ApplyFilter(IQueryable<WellnessServiceCategory> query, WellnessServiceCategorySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(c => c.Name.Contains(search.Name));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(c => c.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(WellnessServiceCategory entity, WellnessServiceCategoryUpsertRequest request)
        {
            if (await _context.WellnessServiceCategories.AnyAsync(c => c.Name == request.Name))
            {
                throw new InvalidOperationException("A wellness service category with this name already exists.");
            }

            entity.CreatedAt = DateTime.UtcNow;
        }

        protected override async Task BeforeUpdate(WellnessServiceCategory entity, WellnessServiceCategoryUpsertRequest request)
        {
            if (await _context.WellnessServiceCategories.AnyAsync(c => c.Name == request.Name && c.Id != entity.Id))
            {
                throw new InvalidOperationException("A wellness service category with this name already exists.");
            }
        }
    }
}

