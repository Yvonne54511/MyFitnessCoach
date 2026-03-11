using System.Net;
using System.Net.Mail;
using System.Text;
using Microsoft.Extensions.Configuration;

namespace Project_MyFitnessCoach.Services
{
    public interface IEmailService
    {
        bool SendPasswordResetEmail(string email, string userName, string resetUrl);
        bool SendStaffInvitationEmail(string email, string userName, string invitationUrl);
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
            var providerName = _configuration["Smtp:Provider"] ?? "Gmail";
            var providerSection = _configuration.GetSection($"Smtp:Providers:{providerName}");

            var host = providerSection["Host"] ?? _configuration["Smtp:Host"];
            var portText = providerSection["Port"] ?? _configuration["Smtp:Port"];
            var enableSslText = providerSection["EnableSsl"] ?? _configuration["Smtp:EnableSsl"];
            var username = providerSection["Username"] ?? _configuration["Smtp:Username"];
            var password = providerSection["Password"] ?? _configuration["Smtp:Password"];
            var fromEmail = providerSection["FromEmail"] ?? _configuration["Smtp:FromEmail"];
            var fromName = providerSection["FromName"] ?? _configuration["Smtp:FromName"] ?? "MyFitnessCoach";

            if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(fromEmail) || string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
            {
                _logger.LogWarning(
                    "SMTP provider {Provider} is not fully configured. Reset password link for {Email}: {ResetUrl}",
                    providerName,
                    email,
                    resetUrl);
                return false;
            }

            var port = int.TryParse(portText, out var smtpPort) ? smtpPort : 587;
            var enableSsl = bool.TryParse(enableSslText, out var ssl) && ssl;

            var htmlBody = $@"
<!DOCTYPE html>
<html lang='zh-Hant'>
<head>
    <meta charset='utf-8' />
    <title>MyFitnessCoach 密碼重置</title>
</head>
<body style='margin:0;padding:0;background:#fff7e8;font-family:Segoe UI,Microsoft JhengHei,sans-serif;color:#4a3523;'>
    <div style='max-width:640px;margin:32px auto;padding:24px;'>
        <div style='background:#ffffff;border-radius:24px;overflow:hidden;box-shadow:0 20px 45px rgba(209,134,28,.16);'>
            <div style='padding:32px 36px;background:linear-gradient(135deg,#ffd976,#ffb44d);color:#5c3d0f;'>
                <div style='font-size:12px;letter-spacing:.18em;font-weight:700;text-transform:uppercase;'>Password Reset</div>
                <h1 style='margin:14px 0 10px;font-size:30px;'>守護未來，與健康同行</h1>
                <p style='margin:0;font-size:15px;line-height:1.8;'>我們收到了您的密碼重置請求，請點擊下方按鈕重新設置。</p>
            </div>
            <div style='padding:36px;'>
                <p style='margin:0 0 14px;'>Hi {WebUtility.HtmlEncode(userName)}，</p>
                <p style='margin:0 0 24px;line-height:1.8;'>請在 30 分鐘內點擊下方按鈕重新設定您的 MyFitnessCoach 帳戶密碼。</p>
                <p style='margin:0 0 28px;'>
                    <a href='{WebUtility.HtmlEncode(resetUrl)}' style='display:inline-block;padding:14px 28px;border-radius:999px;background:linear-gradient(135deg,#f2a531,#e47b22);color:#fffaf2;text-decoration:none;font-weight:700;'>重設密碼</a>
                </p>
                <p style='margin:0 0 8px;line-height:1.8;'>如果按鈕無法點擊，請複製並貼上以下連結：</p>
                <p style='margin:0;padding:14px 16px;border-radius:14px;background:#fff5dc;word-break:break-all;'>
                    <a href='{WebUtility.HtmlEncode(resetUrl)}' style='color:#b96410;'>{WebUtility.HtmlEncode(resetUrl)}</a>
                </p>
                <p style='margin:24px 0 0;line-height:1.8;color:#7a614d;'>如果您沒有操作，請忽略這封信。</p>
            </div>
        </div>
    </div>
</body>
</html>";

            using var message = new MailMessage
            {
                From = new MailAddress(fromEmail, fromName),
                Subject = "MyFitnessCoach 密碼重置通知",
                Body = htmlBody,
                IsBodyHtml = true,
                SubjectEncoding = Encoding.UTF8,
                BodyEncoding = Encoding.UTF8
            };

            message.To.Add(email);

            using var client = new SmtpClient(host, port)
            {
                EnableSsl = enableSsl,
                DeliveryMethod = SmtpDeliveryMethod.Network,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(username, password)
            };

            client.Send(message);
            return true;
        }

        public bool SendStaffInvitationEmail(string email, string userName, string invitationUrl)
        {
            var providerName = _configuration["Smtp:Provider"] ?? "Gmail";
            var providerSection = _configuration.GetSection($"Smtp:Providers:{providerName}");

            var host = providerSection["Host"] ?? _configuration["Smtp:Host"];
            var portText = providerSection["Port"] ?? _configuration["Smtp:Port"];
            var enableSslText = providerSection["EnableSsl"] ?? _configuration["Smtp:EnableSsl"];
            var username = providerSection["Username"] ?? _configuration["Smtp:Username"];
            var password = providerSection["Password"] ?? _configuration["Smtp:Password"];
            var fromEmail = providerSection["FromEmail"] ?? _configuration["Smtp:FromEmail"];
            var fromName = providerSection["FromName"] ?? _configuration["Smtp:FromName"] ?? "MyFitnessCoach";

            if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(fromEmail) || string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
            {
                _logger.LogWarning(
                    "SMTP provider {Provider} is not fully configured. Invitation link for {Email}: {InvitationUrl}",
                    providerName,
                    email,
                    invitationUrl);
                return false;
            }

            var port = int.TryParse(portText, out var smtpPort) ? smtpPort : 587;
            var enableSsl = bool.TryParse(enableSslText, out var ssl) && ssl;

            var htmlBody = $@"
<!DOCTYPE html>
<html lang='zh-Hant'>
<head>
    <meta charset='utf-8' />
    <title>MyFitnessCoach 員工邀請</title>
</head>
<body style='margin:0;padding:0;background:#fff7e8;font-family:Segoe UI,Microsoft JhengHei,sans-serif;color:#4a3523;'>
    <div style='max-width:640px;margin:32px auto;padding:24px;'>
        <div style='background:#ffffff;border-radius:24px;overflow:hidden;box-shadow:0 20px 45px rgba(209,134,28,.16);'>
            <div style='padding:32px 36px;background:linear-gradient(135deg,#ffd976,#ffb44d);color:#5c3d0f;'>
                <div style='font-size:12px;letter-spacing:.18em;font-weight:700;text-transform:uppercase;'>Staff Invitation</div>
                <h1 style='margin:14px 0 10px;font-size:30px;'>歡迎加入 MyFitnessCoach</h1>
                <p style='margin:0;font-size:15px;line-height:1.8;'>管理員已為您建立帳戶，請點擊下方按鈕完成帳號設定。</p>
            </div>
            <div style='padding:36px;'>
                <p style='margin:0 0 14px;'>Hi {WebUtility.HtmlEncode(userName)}，</p>
                <p style='margin:0 0 24px;line-height:1.8;'>請點擊下方按鈕設定您的帳號與密碼，完成後即可登入系統。</p>
                <p style='margin:0 0 28px;'>
                    <a href='{WebUtility.HtmlEncode(invitationUrl)}' style='display:inline-block;padding:14px 28px;border-radius:999px;background:linear-gradient(135deg,#f2a531,#e47b22);color:#fffaf2;text-decoration:none;font-weight:700;'>設定帳號密碼</a>
                </p>
                <p style='margin:0 0 8px;line-height:1.8;'>如果按鈕無法點擊，請複製並貼上以下連結：</p>
                <p style='margin:0;padding:14px 16px;border-radius:14px;background:#fff5dc;word-break:break-all;'>
                    <a href='{WebUtility.HtmlEncode(invitationUrl)}' style='color:#b96410;'>{WebUtility.HtmlEncode(invitationUrl)}</a>
                </p>
                <p style='margin:24px 0 0;line-height:1.8;color:#7a614d;'>這封信是由系統自動發出，請勿直接回覆。</p>
            </div>
        </div>
    </div>
</body>
</html>";

            using var message = new MailMessage
            {
                From = new MailAddress(fromEmail, fromName),
                Subject = "MyFitnessCoach 員工帳號啟用通知",
                Body = htmlBody,
                IsBodyHtml = true,
                SubjectEncoding = Encoding.UTF8,
                BodyEncoding = Encoding.UTF8
            };

            message.To.Add(email);

            using var client = new SmtpClient(host, port)
            {
                EnableSsl = enableSsl,
                DeliveryMethod = SmtpDeliveryMethod.Network,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(username, password)
            };

            client.Send(message);
            return true;
        }
    }
}
