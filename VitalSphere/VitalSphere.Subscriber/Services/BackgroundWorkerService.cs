using EasyNetQ;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.Versioning;
using System.Linq;
using VitalSphere.Subscriber.Models;
using VitalSphere.Subscriber.Interfaces;
using System.Net.Sockets;
using System.Net;

namespace VitalSphere.Subscriber.Services
{
    public class BackgroundWorkerService : BackgroundService
    {
        private readonly ILogger<BackgroundWorkerService> _logger;
        private readonly IEmailSenderService _emailSender;
        private readonly string _host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
        private readonly string _username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
        private readonly string _password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
        private readonly string _virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

        public BackgroundWorkerService(
            ILogger<BackgroundWorkerService> logger,
            IEmailSenderService emailSender)
        {
            _logger = logger;
            _emailSender = emailSender;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            // Check internet connectivity to smtp.gmail.com
            try
            {
                var addresses = await Dns.GetHostAddressesAsync("smtp.gmail.com");
                _logger.LogInformation($"smtp.gmail.com resolved to: {string.Join(", ", addresses.Select(a => a.ToString()))}");
                using (var client = new TcpClient())
                {
                    var connectTask = client.ConnectAsync("smtp.gmail.com", 587);
                    var timeoutTask = Task.Delay(5000, stoppingToken);
                    var completed = await Task.WhenAny(connectTask, timeoutTask);
                    if (completed == connectTask && client.Connected)
                    {
                        _logger.LogInformation("Successfully connected to smtp.gmail.com:587");
                    }
                    else
                    {
                        _logger.LogError("Failed to connect to smtp.gmail.com:587 (timeout or error)");
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Internet connectivity check failed: {ex.Message}");
            }

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var bus = RabbitHutch.CreateBus($"host={_host};virtualHost={_virtualhost};username={_username};password={_password}"))
                    {
                        // Subscribe to appointment notifications
                        bus.PubSub.Subscribe<AppointmentNotification>("Appointment_Notifications", HandleAppointmentMessage);

                        _logger.LogInformation("Waiting for appointment notifications...");
                        await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
                    }
                }
                catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Error in RabbitMQ listener: {ex.Message}");
                }
            }
        }

        private async Task HandleAppointmentMessage(AppointmentNotification notification)
        {
            var appointment = notification.Appointment;

            if (string.IsNullOrWhiteSpace(appointment.UserEmail))
            {
                _logger.LogWarning("Appointment notification missing user email.");
                return;
            }

            var subject = "Your wellness appointment is scheduled";
            var formattedDate = appointment.ScheduledAt.ToString("f");
            var serviceName = string.IsNullOrWhiteSpace(appointment.WellnessServiceCategoryName)
                ? appointment.WellnessServiceName
                : $"{appointment.WellnessServiceName} ({appointment.WellnessServiceCategoryName})";

            var message = $"Hello {appointment.UserFullName},\n\n" +
                          $"Your appointment for {serviceName} has been scheduled for {formattedDate}.\n";

            if (!string.IsNullOrWhiteSpace(appointment.Notes))
            {
                message += $"\nAdditional notes: {appointment.Notes}\n";
            }

            message += "\nWe look forward to seeing you!\n\nBest regards,\nVitalSphere Team";

            try
            {
                await _emailSender.SendEmailAsync(appointment.UserEmail, subject, message);
                _logger.LogInformation($"Appointment notification sent to: {appointment.UserEmail}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Failed to send appointment email to {appointment.UserEmail}: {ex.Message}");
            }
        }
    }
}