using VitalSphere.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using VitalSphere.Model.Responses;
using VitalSphere.Model.Requests;
using VitalSphere.Model.SearchObjects;
using VitalSphere.Services.Services;

namespace VitalSphere.Services.Interfaces
{
    public interface IUserService : IService<UserResponse, UserSearchObject>
    {
        Task<UserResponse?> AuthenticateAsync(UserLoginRequest request);
        Task<UserResponse> CreateAsync(UserUpsertRequest request);
        Task<UserResponse?> UpdateAsync(int id, UserUpsertRequest request);
        Task<bool> DeleteAsync(int id);
    }
}