using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;
using VitalSphere.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace VitalSphere.WebAPI.Controllers
{
    public class GiftController : BaseCRUDController<GiftResponse, GiftSearchObject, GiftUpsertRequest, GiftUpsertRequest>
    {
        public GiftController(IGiftService service) : base(service)
        {
        }
    }
}

