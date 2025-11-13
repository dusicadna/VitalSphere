using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;

namespace VitalSphere.Services.Interfaces
{
    public interface IProductService : ICRUDService<ProductResponse, ProductSearchObject, ProductUpsertRequest, ProductUpsertRequest>
    {
    }
}
