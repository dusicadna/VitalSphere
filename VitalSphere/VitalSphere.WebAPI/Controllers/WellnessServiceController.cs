using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;
using VitalSphere.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace VitalSphere.WebAPI.Controllers
{
    public class WellnessServiceController : BaseCRUDController<WellnessServiceResponse, WellnessServiceSearchObject, WellnessServiceUpsertRequest, WellnessServiceUpsertRequest>
    {
        public WellnessServiceController(IWellnessServiceService service) : base(service)
        {
        }
    }
}

