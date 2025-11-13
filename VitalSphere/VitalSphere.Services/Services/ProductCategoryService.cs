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
    public class ProductCategoryService : BaseCRUDService<ProductCategoryResponse, ProductCategorySearchObject, ProductCategory, ProductCategoryUpsertRequest, ProductCategoryUpsertRequest>, IProductCategoryService
    {
        public ProductCategoryService(VitalSphereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<ProductCategory> ApplyFilter(IQueryable<ProductCategory> query, ProductCategorySearchObject search)
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

        protected override async Task BeforeInsert(ProductCategory entity, ProductCategoryUpsertRequest request)
        {
            if (await _context.ProductCategories.AnyAsync(c => c.Name == request.Name))
            {
                throw new InvalidOperationException("A product category with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(ProductCategory entity, ProductCategoryUpsertRequest request)
        {
            if (await _context.ProductCategories.AnyAsync(c => c.Name == request.Name && c.Id != entity.Id))
            {
                throw new InvalidOperationException("A product category with this name already exists.");
            }
        }
    }
}

