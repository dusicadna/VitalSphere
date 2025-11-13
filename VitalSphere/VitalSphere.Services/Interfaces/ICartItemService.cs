using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;

namespace VitalSphere.Services.Interfaces
{
    public interface ICartItemService : ICRUDService<CartItemResponse, CartItemSearchObject, CartItemUpsertRequest, CartItemUpsertRequest>
    {
    }
}
