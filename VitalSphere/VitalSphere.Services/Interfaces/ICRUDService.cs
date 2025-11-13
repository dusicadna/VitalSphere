using VitalSphere.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using VitalSphere.Model.Responses;
using VitalSphere.Model.Requests;
using VitalSphere.Model.SearchObjects;

namespace VitalSphere.Services.Interfaces
{
    public interface ICRUDService<T, TSearch, TInsert, TUpdate> : IService<T, TSearch> where T : class where TSearch : BaseSearchObject where TInsert : class where TUpdate : class
    {
        Task<T> CreateAsync(TInsert request);
        Task<T?> UpdateAsync(int id, TUpdate request);
        Task<bool> DeleteAsync(int id);
    }
}