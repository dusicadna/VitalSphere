using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace VitalSphere.Services.Database
{
    public static class DatabaseConfiguration
    {
        public static void AddDatabaseServices(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<VitalSphereDbContext>(options =>
                options.UseSqlServer(connectionString));
        }

        public static void AddDatabaseVitalSphere(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<VitalSphereDbContext>(options =>
                options.UseSqlServer(connectionString));
        }
    }
}