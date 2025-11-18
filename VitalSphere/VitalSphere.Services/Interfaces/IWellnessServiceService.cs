using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;

namespace VitalSphere.Services.Interfaces
{
    public interface IWellnessServiceService : ICRUDService<WellnessServiceResponse, WellnessServiceSearchObject, WellnessServiceUpsertRequest, WellnessServiceUpsertRequest>
    {
        WellnessServiceResponse RecommendForUser(int userId);
    }
}

