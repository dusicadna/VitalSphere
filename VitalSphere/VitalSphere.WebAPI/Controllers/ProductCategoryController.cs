using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;
using VitalSphere.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace VitalSphere.WebAPI.Controllers
{
    public class ProductCategoryController : BaseCRUDController<ProductCategoryResponse, ProductCategorySearchObject, ProductCategoryUpsertRequest, ProductCategoryUpsertRequest>
    {
        public ProductCategoryController(IProductCategoryService service) : base(service)
        {
        }
    }
}

