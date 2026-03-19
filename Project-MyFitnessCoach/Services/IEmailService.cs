using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public interface IEmailService
    {
        /// <summary>
        /// 發送註冊啟用驗證信
        /// </summary>
        Task<bool> SendActivationEmailAsync(string userEmail, string userName, string activationUrl);

        /// <summary>
        /// 發送重設密碼驗證信
        /// </summary>
        Task<bool> SendResetPwdEmailAsync(string userEmail, string userName, string userAccount, string resetUrl);

        /// <summary>
        /// (相容舊版) 發送重設密碼驗證信
        /// </summary>
        bool SendPasswordResetEmail(string email, string userName, string userAccount, string resetUrl);

        /// <summary>
        /// (相容舊版) 發送員工邀請驗證信
        /// </summary>
        bool SendStaffInvitationEmail(string email, string userName, string invitationUrl);
    }
}
