using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;
using VitalSphere.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace VitalSphere.WebAPI.Controllers
{
    public class WellnessBoxController : BaseCRUDController<WellnessBoxResponse, WellnessBoxSearchObject, WellnessBoxUpsertRequest, WellnessBoxUpsertRequest>
    {
        public WellnessBoxController(IWellnessBoxService service) : base(service)
        {
        }
    }
}

