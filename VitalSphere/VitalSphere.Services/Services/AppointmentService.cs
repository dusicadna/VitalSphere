using EasyNetQ;
using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.Messages;
using VitalSphere.Model.SearchObjects;
using VitalSphere.Services.Database;
using VitalSphere.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace VitalSphere.Services.Services
{
    public class AppointmentService : BaseCRUDService<AppointmentResponse, AppointmentSearchObject, Appointment, AppointmentUpsertRequest, AppointmentUpsertRequest>, IAppointmentService
    {
        public AppointmentService(VitalSphereDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Appointment> ApplyFilter(IQueryable<Appointment> query, AppointmentSearchObject search)
        {
            query = query.Include(a => a.User)
                         .Include(a => a.WellnessService);

            if (search.UserId.HasValue)
            {
                query = query.Where(a => a.UserId == search.UserId.Value);
            }

            if (search.WellnessServiceId.HasValue)
            {
                query = query.Where(a => a.WellnessServiceId == search.WellnessServiceId.Value);
            }

            return query;
        }

        public override async Task<AppointmentResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Appointments
                .Include(a => a.User)
                .Include(a => a.WellnessService)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override AppointmentResponse MapToResponse(Appointment entity)
        {
            return new AppointmentResponse
            {
                Id = entity.Id,
                UserId = entity.UserId,
                UserName = $"{entity.User?.FirstName} {entity.User?.LastName}".Trim(),
                WellnessServiceId = entity.WellnessServiceId,
                WellnessServiceName = entity.WellnessService?.Name ?? string.Empty,
                ScheduledAt = entity.ScheduledAt,
                Notes = entity.Notes,
                CreatedAt = entity.CreatedAt
            };
        }

        protected override async Task BeforeInsert(Appointment entity, AppointmentUpsertRequest request)
        {
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("The specified user does not exist.");
            }

            if (!await _context.WellnessServices.AnyAsync(ws => ws.Id == request.WellnessServiceId))
            {
                throw new InvalidOperationException("The specified wellness service does not exist.");
            }

            entity.CreatedAt = DateTime.Now;
        }

        protected override async Task AfterInsert(Appointment entity, AppointmentUpsertRequest request)
        {
            await SendAppointmentNotificationAsync(entity.Id);
            await base.AfterInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Appointment entity, AppointmentUpsertRequest request)
        {
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("The specified user does not exist.");
            }

            if (!await _context.WellnessServices.AnyAsync(ws => ws.Id == request.WellnessServiceId))
            {
                throw new InvalidOperationException("The specified wellness service does not exist.");
            }
        }

        private async Task SendAppointmentNotificationAsync(int appointmentId)
        {
            try
            {
                var appointment = await _context.Appointments
                    .Include(a => a.User)
                    .Include(a => a.WellnessService)
                        .ThenInclude(ws => ws.WellnessServiceCategory)
                    .FirstOrDefaultAsync(a => a.Id == appointmentId);

                if (appointment == null || string.IsNullOrWhiteSpace(appointment.User?.Email))
                {
                    return;
                }

                var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
                var username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
                var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
                var virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

                using var bus = RabbitHutch.CreateBus($"host={host};virtualHost={virtualhost};username={username};password={password}");

                var notification = new AppointmentNotification
                {
                    Appointment = new AppointmentNotificationDto
                    {
                        UserEmail = appointment.User.Email,
                        UserFullName = $"{appointment.User.FirstName} {appointment.User.LastName}".Trim(),
                        WellnessServiceName = appointment.WellnessService?.Name ?? string.Empty,
                        WellnessServiceCategoryName = appointment.WellnessService?.WellnessServiceCategory?.Name ?? string.Empty,
                        ScheduledAt = appointment.ScheduledAt,
                        Notes = appointment.Notes
                    }
                };

                await bus.PubSub.PublishAsync(notification);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to send appointment notification: {ex.Message}");
            }
        }
    }
}

