using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;

namespace Project_MyFitnessCoach.Services
{
    public interface IEmailService
    {
        bool SendPasswordResetEmail(string email, string userName, string resetUrl);
    }

    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<EmailService> _logger;

        public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public bool SendPasswordResetEmail(string email, string userName, string resetUrl)
        {
            var host = _configuration["Smtp:Host"];
            var fromEmail = _configuration["Smtp:FromEmail"];

            if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(fromEmail))
            {
                _logger.LogWarning(
                    "SMTP is not configured. Reset password link for {Email}: {ResetUrl}",
                    email,
                    resetUrl);
                return false;
            }

            var fromName = _configuration["Smtp:FromName"] ?? "MyFitnessCoach";
            var port = int.TryParse(_configuration["Smtp:Port"], out var smtpPort) ? smtpPort : 25;
            var enableSsl = bool.TryParse(_configuration["Smtp:EnableSsl"], out var ssl) && ssl;
            var username = _configuration["Smtp:Username"];
            var password = _configuration["Smtp:Password"];

            using var message = new MailMessage
            {
                From = new MailAddress(fromEmail, fromName),
                Subject = "MyFitnessCoach 密碼重設通知",
                Body = $"{userName} 您好，\n\n請點選以下連結重設您的密碼：\n{resetUrl}\n\n若這不是您本人操作，請忽略此信件。",
                IsBodyHtml = false
            };

            message.To.Add(email);

            using var client = new SmtpClient(host, port)
            {
                EnableSsl = enableSsl
            };

            if (!string.IsNullOrWhiteSpace(username))
            {
                client.Credentials = new NetworkCredential(username, password);
            }

            client.Send(message);
            return true;
        }
    }
}
