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
    public class ProductSubcategoryService : BaseCRUDService<ProductSubcategoryResponse, ProductSubcategorySearchObject, ProductSubcategory, ProductSubcategoryUpsertRequest, ProductSubcategoryUpsertRequest>, IProductSubcategoryService
    {
        public ProductSubcategoryService(VitalSphereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<ProductSubcategory> ApplyFilter(IQueryable<ProductSubcategory> query, ProductSubcategorySearchObject search)
        {
            query = query.Include(sc => sc.ProductCategory);

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(sc => sc.Name.Contains(search.Name));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(sc => sc.IsActive == search.IsActive.Value);
            }

            if (search.ProductCategoryId.HasValue)
            {
                query = query.Where(sc => sc.ProductCategoryId == search.ProductCategoryId.Value);
            }

            return query;
        }

        public override async Task<ProductSubcategoryResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.ProductSubcategories
                .Include(sc => sc.ProductCategory)
                .FirstOrDefaultAsync(sc => sc.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override ProductSubcategoryResponse MapToResponse(ProductSubcategory entity)
        {
            var response = base.MapToResponse(entity);
            response.ProductCategoryName = entity.ProductCategory?.Name ?? string.Empty;
            return response;
        }

        protected override async Task BeforeInsert(ProductSubcategory entity, ProductSubcategoryUpsertRequest request)
        {
            if (!await _context.ProductCategories.AnyAsync(c => c.Id == request.ProductCategoryId))
            {
                throw new InvalidOperationException("The specified product category does not exist.");
            }

            if (await _context.ProductSubcategories.AnyAsync(sc => sc.Name == request.Name && sc.ProductCategoryId == request.ProductCategoryId))
            {
                throw new InvalidOperationException("A product subcategory with this name already exists in the selected category.");
            }
        }

        protected override async Task BeforeUpdate(ProductSubcategory entity, ProductSubcategoryUpsertRequest request)
        {
            if (!await _context.ProductCategories.AnyAsync(c => c.Id == request.ProductCategoryId))
            {
                throw new InvalidOperationException("The specified product category does not exist.");
            }

            if (await _context.ProductSubcategories.AnyAsync(sc => sc.Name == request.Name && sc.ProductCategoryId == request.ProductCategoryId && sc.Id != entity.Id))
            {
                throw new InvalidOperationException("A product subcategory with this name already exists in the selected category.");
            }
        }
    }
}

