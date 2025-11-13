using VitalSphere.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using VitalSphere.Model.Responses;
using VitalSphere.Model.Requests;
using VitalSphere.Model.SearchObjects;

namespace VitalSphere.Services.Interfaces
{
    public interface IService<T, TSearch> where T : class where TSearch : BaseSearchObject
    {
        Task<PagedResult<T>> GetAsync(TSearch search);
        Task<T?> GetByIdAsync(int id);
    }
}