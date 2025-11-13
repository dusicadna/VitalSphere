using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;
using VitalSphere.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace VitalSphere.WebAPI.Controllers
{
    public class ProductSubcategoryController : BaseCRUDController<ProductSubcategoryResponse, ProductSubcategorySearchObject, ProductSubcategoryUpsertRequest, ProductSubcategoryUpsertRequest>
    {
        public ProductSubcategoryController(IProductSubcategoryService service) : base(service)
        {
        }
    }
}

