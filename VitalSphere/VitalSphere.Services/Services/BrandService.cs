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
    public class BrandService : BaseCRUDService<BrandResponse, BrandSearchObject, Brand, BrandUpsertRequest, BrandUpsertRequest>, IBrandService
    {
        public BrandService(VitalSphereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Brand> ApplyFilter(IQueryable<Brand> query, BrandSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(b => b.Name.Contains(search.Name));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(b => b.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Brand entity, BrandUpsertRequest request)
        {
            if (await _context.Brands.AnyAsync(b => b.Name == request.Name))
            {
                throw new InvalidOperationException("A brand with this name already exists.");
            }

            entity.CreatedAt = DateTime.UtcNow;
        }

        protected override async Task BeforeUpdate(Brand entity, BrandUpsertRequest request)
        {
            if (await _context.Brands.AnyAsync(b => b.Name == request.Name && b.Id != entity.Id))
            {
                throw new InvalidOperationException("A brand with this name already exists.");
            }
        }
    }
}

