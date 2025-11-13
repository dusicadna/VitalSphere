using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;

namespace VitalSphere.Services.Interfaces
{
    public interface IGiftService : ICRUDService<GiftResponse, GiftSearchObject, GiftUpsertRequest, GiftUpsertRequest>
    {
    }
}

