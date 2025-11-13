using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;

namespace VitalSphere.Services.Interfaces
{
    public interface IOrderService : ICRUDService<OrderResponse, OrderSearchObject, OrderUpsertRequest, OrderUpsertRequest>
    {
        Task<OrderResponse> CreateOrderFromCartAsync(int userId);
        Task<List<OrderResponse>> GetOrdersByUserAsync(int userId);
    }
}
