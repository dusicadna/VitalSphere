using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;
using VitalSphere.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace VitalSphere.WebAPI.Controllers
{
    public class WellnessServiceCategoryController : BaseCRUDController<WellnessServiceCategoryResponse, WellnessServiceCategorySearchObject, WellnessServiceCategoryUpsertRequest, WellnessServiceCategoryUpsertRequest>
    {
        public WellnessServiceCategoryController(IWellnessServiceCategoryService service) : base(service)
        {
        }
    }
}

