using Microsoft.AspNetCore.Identity;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public interface IAccountService
    {
        (bool Success, string Message, User? User, List<string> Roles, List<string> Functions, int? InstructorId) Login(LoginViewModel model);
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

        public (bool Success, string Message, User? User, List<string> Roles, List<string> Functions, int? InstructorId) Login(LoginViewModel model)
        {
            var user = _accountRepository.GetByAccount(model.Account);

            if (user == null || string.IsNullOrWhiteSpace(user.HashedPassword))
            {
                return (false, "帳號或密碼錯誤", null, new List<string>(), new List<string>(), null);
            }

            string dbPassword = user.HashedPassword.Trim();
            string inputPassword = model.Password.Trim();
            bool isPasswordCorrect = false;

            // 1. 先嘗試明文比對
            if (dbPassword == inputPassword)
            {
                isPasswordCorrect = true;
            }
            // 2. 如果明文失敗，且看起來像是加密字串 (Base64)，則嘗試加密比對
            else if (dbPassword.Length > 20) 
            {
                try
                {
                    var result = _passwordHasher.VerifyHashedPassword(user, dbPassword, inputPassword);
                    if (result != PasswordVerificationResult.Failed)
                    {
                        isPasswordCorrect = true;
                    }
                }
                catch
                {
                    // 如果加密比對報錯 (FormatException)，代表這不是正確的 Base64，忽略即可
                }
            }

            if (!isPasswordCorrect)
            {
                return (false, "帳號或密碼錯誤", null, new List<string>(), new List<string>(), null);
            }

            if (!user.IsConfirmed)
            {
                return (false, "帳號尚未完成驗證程序", null, new List<string>(), new List<string>(), null);
            }

            if (!user.IsActive)
            {
                return (false, "帳號停用中，請聯繫管理員", null, new List<string>(), new List<string>(), null);
            }

            // 抓取角色
            var roles = user.UserRoles?
                .Where(ur => ur.Role != null)
                .Select(ur => ur.Role.RoleName.Trim())
                .ToList() ?? new List<string>();

            // 抓取該角色對應的所有功能清單
            var functions = user.UserRoles?
                .Where(ur => ur.Role != null)
                .SelectMany(ur => ur.Role.RoleFunctions)
                .Where(rf => rf.Function != null)
                .Select(rf => rf.Function.FunctionName.Trim())
                .Distinct() // 去除重複功能
                .ToList() ?? new List<string>();

            int? instructorId = user.Instructors?.FirstOrDefault()?.Id;

            return (true, "登入成功", user, roles, functions, instructorId);
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
                return (false, "���]�K�X�s�����s�b");
            }

            if (!user.ResetPasswordConfirmCodeExpiry.HasValue || user.ResetPasswordConfirmCodeExpiry.Value < DateTime.Now)
            {
                return (false, "���]�K�X�s���w���ġA�Э��s�ӽ�");
            }

            user.HashedPassword = _passwordHasher.HashPassword(user, model.Password);
            user.ResetPasswordConfirmCode = null!;
            user.ResetPasswordConfirmCodeExpiry = null;

            _accountRepository.Update(user);
            _accountRepository.SaveChanges();

            return (true, "�K�X�w���]�����A�Э��s�n�J");
        }
    }
}
