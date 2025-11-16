using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using VitalSphere.Model.Responses;
using VitalSphere.Services.Interfaces;

namespace VitalSphere.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BusinessReportController : ControllerBase
    {
        private readonly IBusinessReportService _businessReportService;

        public BusinessReportController(IBusinessReportService businessReportService)
        {
            _businessReportService = businessReportService;
        }

        [HttpGet]
        public async Task<ActionResult<BusinessReportResponse>> Get()
        {
            var report = await _businessReportService.GetBusinessReportAsync();
            return Ok(report);
        }
    }
}

