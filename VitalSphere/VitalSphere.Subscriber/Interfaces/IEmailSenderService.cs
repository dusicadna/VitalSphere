using System.Threading.Tasks;

namespace VitalSphere.Subscriber.Interfaces
{
    public interface IEmailSenderService
    {
        Task SendEmailAsync(string email, string subject, string message);
    }
}
