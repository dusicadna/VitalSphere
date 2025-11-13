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
    public class ProductService : BaseCRUDService<ProductResponse, ProductSearchObject, Product, ProductUpsertRequest, ProductUpsertRequest>, IProductService
    {
        public ProductService(VitalSphereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Product> ApplyFilter(IQueryable<Product> query, ProductSearchObject search)
        {
            query = query.Include(p => p.ProductSubcategory)
                         .ThenInclude(sc => sc.ProductCategory);

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(p => p.Name.Contains(search.Name));
            }

            if (search.MinPrice.HasValue)
            {
                query = query.Where(p => p.Price >= search.MinPrice.Value);
            }

            if (search.MaxPrice.HasValue)
            {
                query = query.Where(p => p.Price <= search.MaxPrice.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(p => p.IsActive == search.IsActive.Value);
            }

            if (search.ProductSubcategoryId.HasValue)
            {
                query = query.Where(p => p.ProductSubcategoryId == search.ProductSubcategoryId.Value);
            }

            if (search.ProductCategoryId.HasValue)
            {
                query = query.Where(p => p.ProductSubcategory.ProductCategoryId == search.ProductCategoryId.Value);
            }

            return query;
        }

        public override async Task<ProductResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Products
                .Include(p => p.ProductSubcategory)
                .ThenInclude(sc => sc.ProductCategory)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override ProductResponse MapToResponse(Product entity)
        {
            var response = base.MapToResponse(entity);
            response.ProductSubcategoryId = entity.ProductSubcategoryId;
            response.ProductSubcategoryName = entity.ProductSubcategory?.Name ?? string.Empty;
            response.ProductCategoryId = entity.ProductSubcategory?.ProductCategoryId ?? 0;
            response.ProductCategoryName = entity.ProductSubcategory?.ProductCategory?.Name ?? string.Empty;
            return response;
        }

        protected override async Task BeforeInsert(Product entity, ProductUpsertRequest request)
        {
            if (await _context.Products.AnyAsync(p => p.Name == request.Name))
            {
                throw new InvalidOperationException("A product with this name already exists.");
            }

            if (!await _context.ProductSubcategories.AnyAsync(sc => sc.Id == request.ProductSubcategoryId))
            {
                throw new InvalidOperationException("The specified product subcategory does not exist.");
            }
        }

        protected override async Task BeforeUpdate(Product entity, ProductUpsertRequest request)
        {
            if (await _context.Products.AnyAsync(p => p.Name == request.Name && p.Id != entity.Id))
            {
                throw new InvalidOperationException("A product with this name already exists.");
            }

            if (!await _context.ProductSubcategories.AnyAsync(sc => sc.Id == request.ProductSubcategoryId))
            {
                throw new InvalidOperationException("The specified product subcategory does not exist.");
            }
        }
    }
}
