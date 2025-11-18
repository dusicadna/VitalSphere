using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;
using VitalSphere.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace VitalSphere.WebAPI.Controllers
{
    public class WellnessServiceController : BaseCRUDController<WellnessServiceResponse, WellnessServiceSearchObject, WellnessServiceUpsertRequest, WellnessServiceUpsertRequest>
    {
        private readonly IWellnessServiceService _wellnessServiceService;

        public WellnessServiceController(IWellnessServiceService service) : base(service)
        {
            _wellnessServiceService = service;
        }

        [HttpGet("user/{userId}/recommend")]
        public ActionResult<WellnessServiceResponse> RecommendForUser(int userId)
        {
            try
            {
                var recommendation = _wellnessServiceService.RecommendForUser(userId);
                return Ok(recommendation);
            }
            catch (InvalidOperationException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }
    }
}

