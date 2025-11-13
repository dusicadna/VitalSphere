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
    public class WellnessBoxService : BaseCRUDService<WellnessBoxResponse, WellnessBoxSearchObject, WellnessBox, WellnessBoxUpsertRequest, WellnessBoxUpsertRequest>, IWellnessBoxService
    {
        public WellnessBoxService(VitalSphereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<WellnessBox> ApplyFilter(IQueryable<WellnessBox> query, WellnessBoxSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(wb => wb.Name.Contains(search.Name));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(wb => wb.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(WellnessBox entity, WellnessBoxUpsertRequest request)
        {
            if (await _context.WellnessBoxes.AnyAsync(wb => wb.Name == request.Name))
            {
                throw new InvalidOperationException("A wellness box with this name already exists.");
            }

            entity.CreatedAt = DateTime.UtcNow;
        }

        protected override async Task BeforeUpdate(WellnessBox entity, WellnessBoxUpsertRequest request)
        {
            if (await _context.WellnessBoxes.AnyAsync(wb => wb.Name == request.Name && wb.Id != entity.Id))
            {
                throw new InvalidOperationException("A wellness box with this name already exists.");
            }
        }
    }
}

