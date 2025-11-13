using System.Threading.Tasks;
using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;
using VitalSphere.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace VitalSphere.WebAPI.Controllers
{
    public class GiftController : BaseCRUDController<GiftResponse, GiftSearchObject, GiftUpsertRequest, GiftUpsertRequest>
    {
        private readonly IGiftService _giftService;

        public GiftController(IGiftService service) : base(service)
        {
            _giftService = service;
        }

        [HttpPost("{id}/pickup")]
        public async Task<IActionResult> MarkAsPickedUp(int id)
        {
            var response = await _giftService.MarkAsPickedUpAsync(id);

            if (response == null)
            {
                return NotFound();
            }

            return Ok(response);
        }
    }
}
