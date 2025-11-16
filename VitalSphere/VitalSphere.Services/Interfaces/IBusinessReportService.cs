using System.Threading.Tasks;
using VitalSphere.Model.Responses;

namespace VitalSphere.Services.Interfaces
{
    public interface IBusinessReportService
    {
        Task<BusinessReportResponse> GetBusinessReportAsync();
    }
}

