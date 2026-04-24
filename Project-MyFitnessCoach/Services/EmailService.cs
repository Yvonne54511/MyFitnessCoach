using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using MimeKit;
using System.Threading.Tasks;
using System;
using Microsoft.Extensions.Logging;

namespace Project_MyFitnessCoach.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<EmailService> _logger;

        public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<bool> SendActivationEmailAsync(string userEmail, string userName, string activationUrl)
        {
            var subject = "MyFitnessCoach 帳號啟用驗證";
            var bodyHtml = $@"
<!DOCTYPE html>
<html lang='zh-Hant'>
<head>
    <meta charset='utf-8' />
    <title>MyFitnessCoach 帳號啟用</title>
</head>
<body style='margin:0;padding:0;background:#fff7e8;font-family:Segoe UI,Microsoft JhengHei,sans-serif;color:#4a3523;'>
    <div style='max-width:640px;margin:32px auto;padding:24px;'>
        <div style='background:#ffffff;border-radius:24px;overflow:hidden;box-shadow:0 20px 45px rgba(209,134,28,.16);'>
            <div style='padding:32px 36px;background:linear-gradient(135deg,#ffd976,#ffb44d);color:#5c3d0f;'>
                <div style='font-size:12px;letter-spacing:.18em;font-weight:700;text-transform:uppercase;'>Account Activation</div>
                <h1 style='margin:14px 0 10px;font-size:30px;'>連結每一份努力，與健康同行</h1>
                <p style='margin:0;font-size:15px;line-height:1.8;'>感謝您加入 MyFitnessCoach！管理員已為您建立帳戶。</p>
            </div>
            <div style='padding:36px;'>
                <p style='margin:0 0 14px;'>Hi {userName}，</p>
                <p style='margin:0 0 24px;line-height:1.8;'>請點擊下方按鈕以啟用您的帳號並設定密碼，完成後即可登入系統。</p>
                <p style='margin:0 0 28px;'>
                    <a href='{activationUrl}' style='display:inline-block;padding:14px 28px;border-radius:999px;background:linear-gradient(135deg,#f2a531,#e47b22);color:#fffaf2;text-decoration:none;font-weight:700;'>立即啟用帳號</a>
                </p>
                <p style='margin:0 0 8px;line-height:1.8;'>如果按鈕無法點擊，請複製並貼上以下連結：</p>
                <p style='margin:0;padding:14px 16px;border-radius:14px;background:#fff5dc;word-break:break-all;'>
                    <a href='{activationUrl}' style='color:#b96410;'>{activationUrl}</a>
                </p>
                <p style='margin:24px 0 0;line-height:1.8;color:#7a614d;'>這封信是由系統自動發出，請勿直接回覆。</p>
            </div>
        </div>
    </div>
</body>
</html>";

            return await SendEmailAsync(userEmail, subject, bodyHtml);
        }

        public async Task<bool> SendResetPwdEmailAsync(string userEmail, string userName, string userAccount, string resetUrl)
        {
            var subject = "MyFitnessCoach 重設密碼請求";
            var bodyHtml = $@"
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
                <p style='margin:0 0 14px;'>Hi {userName}({userAccount})，</p>
                <p style='margin:0 0 24px;line-height:1.8;'>請在 30 分鐘內點擊下方按鈕重新設定您的 MyFitnessCoach 帳戶密碼。</p>
                <p style='margin:0 0 28px;'>
                    <a href='{resetUrl}' style='display:inline-block;padding:14px 28px;border-radius:999px;background:linear-gradient(135deg,#f2a531,#e47b22);color:#fffaf2;text-decoration:none;font-weight:700;'>重設密碼</a>
                </p>
                <p style='margin:0 0 8px;line-height:1.8;'>如果按鈕無法點擊，請複製並貼上以下連結：</p>
                <p style='margin:0;padding:14px 16px;border-radius:14px;background:#fff5dc;word-break:break-all;'>
                    <a href='{resetUrl}' style='color:#b96410;'>{resetUrl}</a>
                </p>
                <p style='margin:24px 0 0;line-height:1.8;color:#7a614d;'>如果您沒有操作，請忽略這封信。</p>
            </div>
        </div>
    </div>
</body>
</html>";

            return await SendEmailAsync(userEmail, subject, bodyHtml);
        }

        public async Task<bool> SendReservationCancelEmailAsync(string userEmail, string userName, string instructorName, string date, string timeSlot)
        {
            var subject = "MyFitnessCoach 預約取消通知";
            var bodyHtml = $@"
<!DOCTYPE html>
<html lang='zh-Hant'>
<head>
    <meta charset='utf-8' />
    <title>MyFitnessCoach 預約取消通知</title>
</head>
<body style='margin:0;padding:0;background:#fff7e8;font-family:Segoe UI,Microsoft JhengHei,sans-serif;color:#4a3523;'>
    <div style='max-width:640px;margin:32px auto;padding:24px;'>
        <div style='background:#ffffff;border-radius:24px;overflow:hidden;box-shadow:0 20px 45px rgba(209,134,28,.16);'>
            <div style='padding:32px 36px;background:linear-gradient(135deg,#ff7676,#ff4d4d);color:#ffffff;'>
                <div style='font-size:12px;letter-spacing:.18em;font-weight:700;text-transform:uppercase;'>Reservation Cancelled</div>
                <h1 style='margin:14px 0 10px;font-size:30px;'>預約取消通知</h1>
                <p style='margin:0;font-size:15px;line-height:1.8;'>很抱歉，您的預約已被管理員取消。</p>
            </div>
            <div style='padding:36px;'>
                <p style='margin:0 0 14px;'>Hi {userName}，</p>
                <p style='margin:0 0 14px;line-height:1.8;'>我們很抱歉地通知您，您原訂於 <strong>{date} {timeSlot}</strong> 與 <strong>{instructorName}</strong> 營養師的諮詢預約已被取消。</p>
                <p style='margin:0 0 14px;line-height:1.8;'>如果您是使用<strong>點數</strong>預約，點數已全數退還至您的電子錢包。您可以登入系統查看您的餘額，並重新安排其他時段。</p>
                <div style='margin:24px 0;padding:20px;background:#fff5dc;border-radius:14px;'>
                    <p style='margin:0 0 8px;font-weight:700;color:#b96410;'>取消預約資訊：</p>
                    <ul style='margin:0;padding-left:20px;line-height:1.8;'>
                        <li>諮詢日期：{date}</li>
                        <li>諮詢時段：{timeSlot}</li>
                        <li>營養師：{instructorName}</li>
                    </ul>
                </div>
                <p style='margin:0 0 28px;line-height:1.8;'>您可以前往系統重新預約：</p>
                <p style='margin:0;'>
                    <a href='http://localhost:5173/AllInstructor' style='display:inline-block;padding:14px 28px;border-radius:999px;background:linear-gradient(135deg,#f2a531,#e47b22);color:#fffaf2;text-decoration:none;font-weight:700;'>前往系統</a>
                </p>
                <p style='margin:20px 0 0;font-size:13px;color:#7a614d;'>如果按鈕無法點擊，請複製以下連結至瀏覽器：</p>
                <p style='margin:5px 0 0;font-size:13px;word-break:break-all;color:#b96410;'>http://localhost:5173/AllInstructor</p>
                <p style='margin:24px 0 0;line-height:1.8;color:#7a614d;'>這封信是由系統自動發出，如有任何疑問，請聯繫客服。</p>
            </div>
        </div>
    </div>
</body>
</html>";

            return await SendEmailAsync(userEmail, subject, bodyHtml);
        }

        private async Task<bool> SendEmailAsync(string toEmail, string subject, string bodyHtml)
        {
            // 從 User Secrets 讀取設定 (如無則回退至 appsettings 或 預設值)
            var emailAccount = _configuration["EmailSettings:Account"] ?? "myfitnesscoach2026";
            // 確保帳號包含 @gmail.com
            if (!emailAccount.Contains("@")) emailAccount += "@gmail.com";
            
            var emailPassword = _configuration["EmailSettings:Password"] ?? "xzkttflwhbdqssej";
            var senderName = _configuration["EmailSettings:SenderName"] ?? "MyFitnessCoach 管理員";
            var smtpServer = _configuration["EmailSettings:SmtpServer"] ?? "smtp.gmail.com";
            var smtpPortStr = _configuration["EmailSettings:SmtpPort"] ?? "587";
            int.TryParse(smtpPortStr, out var smtpPort);

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(senderName, emailAccount));
            message.To.Add(new MailboxAddress("", toEmail));
            message.Subject = subject;

            var bodyBuilder = new BodyBuilder { HtmlBody = bodyHtml };
            message.Body = bodyBuilder.ToMessageBody();

            try
            {
                using var client = new SmtpClient();
                // 忽略伺服器憑證驗證 (僅限開發環境，如正式環境建議移除)
                // client.ServerCertificateValidationCallback = (s, c, h, e) => true;

                await client.ConnectAsync(smtpServer, smtpPort, SecureSocketOptions.StartTls);
                await client.AuthenticateAsync(emailAccount, emailPassword);
                await client.SendAsync(message);
                await client.DisconnectAsync(true);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "MailKit 發送郵件失敗至 {Email}", toEmail);
                return false;
            }
        }

        // 相容舊版介面的實作
        public bool SendPasswordResetEmail(string email, string userName, string userAccount, string resetUrl)
        {
            return Task.Run(() => SendResetPwdEmailAsync(email, userName, userAccount, resetUrl)).Result;
        }

        public bool SendStaffInvitationEmail(string email, string userName, string invitationUrl)
        {
            return Task.Run(() => SendActivationEmailAsync(email, userName, invitationUrl)).Result;
        }
    }
}
