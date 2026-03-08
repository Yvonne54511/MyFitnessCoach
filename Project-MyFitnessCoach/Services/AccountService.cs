using Microsoft.AspNetCore.Identity;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public interface IAccountService
    {
        (bool Success, string Message, User? User) Login(LoginViewModel model);
        (bool Success, string Email, bool EmailSent) CreateResetPasswordRequest(string email, Func<string, string> resetUrlFactory);
        (bool Success, string Message) ResetPassword(ResetPasswordViewModel model);
        bool IsResetPasswordCodeValid(string code);
    }

    public class AccountService : IAccountService
    {
        private readonly IAccountRepository _accountRepository;
        private readonly IEmailService _emailService;
        private readonly PasswordHasher<User> _passwordHasher;
        private readonly ILogger<AccountService> _logger;

        public AccountService(
            IAccountRepository accountRepository,
            IEmailService emailService,
            ILogger<AccountService> logger)
        {
            _accountRepository = accountRepository;
            _emailService = emailService;
            _logger = logger;
            _passwordHasher = new PasswordHasher<User>();
        }

        public (bool Success, string Message, User? User) Login(LoginViewModel model)
        {
            var user = _accountRepository.GetByAccount(model.Account);

            if (user == null || string.IsNullOrWhiteSpace(user.HashedPassword))
            {
                return (false, "帳號或密碼錯誤", null);
            }

            var result = _passwordHasher.VerifyHashedPassword(user, user.HashedPassword, model.Password);
            if (result == PasswordVerificationResult.Failed)
            {
                return (false, "帳號或密碼錯誤", null);
            }

            if (!user.IsConfirmed)
            {
                return (false, "此帳號尚未完成啟用", null);
            }

            if (!user.IsActive)
            {
                return (false, "此帳號目前未啟用，請聯絡管理員", null);
            }

            return (true, "登入成功", user);
        }

        public (bool Success, string Email, bool EmailSent) CreateResetPasswordRequest(string email, Func<string, string> resetUrlFactory)
        {
            var user = _accountRepository.GetByEmail(email);
            if (user == null)
            {
                return (true, email, false);
            }

            user.ResetPasswordConfirmCode = Guid.NewGuid().ToString("N");
            user.ResetPasswordConfirmCodeExpiry = DateTime.Now.AddMinutes(30);
            _accountRepository.Update(user);
            _accountRepository.SaveChanges();

            var resetUrl = resetUrlFactory(user.ResetPasswordConfirmCode);
            var emailSent = false;

            try
            {
                emailSent = _emailService.SendPasswordResetEmail(user.Email, user.UserName, resetUrl);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send reset password email to {Email}", user.Email);
            }

            return (true, user.Email, emailSent);
        }

        public bool IsResetPasswordCodeValid(string code)
        {
            var user = _accountRepository.GetByResetPasswordCode(code);
            return user != null
                && user.ResetPasswordConfirmCodeExpiry.HasValue
                && user.ResetPasswordConfirmCodeExpiry.Value >= DateTime.Now;
        }

        public (bool Success, string Message) ResetPassword(ResetPasswordViewModel model)
        {
            var user = _accountRepository.GetByResetPasswordCode(model.Code);
            if (user == null)
            {
                return (false, "重設密碼連結不存在");
            }

            if (!user.ResetPasswordConfirmCodeExpiry.HasValue || user.ResetPasswordConfirmCodeExpiry.Value < DateTime.Now)
            {
                return (false, "重設密碼連結已失效，請重新申請");
            }

            user.HashedPassword = _passwordHasher.HashPassword(user, model.Password);
            user.ResetPasswordConfirmCode = null!;
            user.ResetPasswordConfirmCodeExpiry = null;

            _accountRepository.Update(user);
            _accountRepository.SaveChanges();

            return (true, "密碼已重設完成，請重新登入");
        }
    }
}
