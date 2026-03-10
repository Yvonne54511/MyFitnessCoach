using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public interface IMemberAccountService
    {
        LoginResultDto Login(LoginDto dto);
        ResetPasswordRequestDto CreateResetPasswordRequest(string email, Func<string, string> resetUrlFactory);
        AccountResultDto ResetPassword(ResetPasswordDto dto);
        bool IsResetPasswordCodeValid(string code);
    }

    public class MemberAccountService : IMemberAccountService
    {
        private readonly IAccountRepository _accountRepository;
        private readonly IEmailService _emailService;
        private readonly IPasswordHasher<User> _passwordHasher;
        private readonly ILogger<MemberAccountService> _logger;

        public MemberAccountService(
            IAccountRepository accountRepository,
            IEmailService emailService,
            ILogger<MemberAccountService> logger,
            IPasswordHasher<User> passwordHasher)
        {
            _accountRepository = accountRepository;
            _emailService = emailService;
            _logger = logger;
            _passwordHasher = passwordHasher;
        }

        public LoginResultDto Login(LoginDto dto)
        {
            var user = _accountRepository.GetByAccount(dto.Account);

            if (user == null || string.IsNullOrWhiteSpace(user.HashedPassword))
            {
                return new LoginResultDto { IsSuccess = false, Message = "帳號或密碼錯誤" };
            }

            var result = _passwordHasher.VerifyHashedPassword(user, user.HashedPassword, dto.Password);
            if (result == PasswordVerificationResult.Failed)
            {
                return new LoginResultDto { IsSuccess = false, Message = "帳號或密碼錯誤" };
            }

            if (!user.IsConfirmed)
            {
                return new LoginResultDto { IsSuccess = false, Message = "此帳號尚未完成驗證" };
            }

            if (!user.IsActive)
            {
                return new LoginResultDto { IsSuccess = false, Message = "此帳號目前停用中，請洽管理員" };
            }

            return new LoginResultDto
            {
                IsSuccess = true,
                Message = "登入成功",
                Member = new MemberDto
                {
                    Id = user.Id,
                    Account = user.Account,
                    UserName = user.UserName,
                    Email = user.Email,
                    HashedPassword = user.HashedPassword
                }
            };
        }

        public ResetPasswordRequestDto CreateResetPasswordRequest(string email, Func<string, string> resetUrlFactory)
        {
            var user = _accountRepository.GetByEmail(email);
            if (user == null)
            {
                return new ResetPasswordRequestDto { IsSuccess = true, Email = email, EmailSent = false };
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

            return new ResetPasswordRequestDto
            {
                IsSuccess = true,
                Email = user.Email,
                EmailSent = emailSent,
                Message = emailSent ? "重設密碼信件已寄出" : "寄送失敗"
            };
        }

        public bool IsResetPasswordCodeValid(string code)
        {
            var user = _accountRepository.GetByResetPasswordCode(code);
            return user != null
                && user.ResetPasswordConfirmCodeExpiry.HasValue
                && user.ResetPasswordConfirmCodeExpiry.Value >= DateTime.Now;
        }

        public AccountResultDto ResetPassword(ResetPasswordDto dto)
        {
            var user = _accountRepository.GetByResetPasswordCode(dto.Code);
            if (user == null)
            {
                return new AccountResultDto { IsSuccess = false, Message = "重設密碼連結不存在" };
            }

            if (!user.ResetPasswordConfirmCodeExpiry.HasValue || user.ResetPasswordConfirmCodeExpiry.Value < DateTime.Now)
            {
                return new AccountResultDto { IsSuccess = false, Message = "重設密碼連結已過期，請重新申請" };
            }

            user.HashedPassword = _passwordHasher.HashPassword(user, dto.Password);
            user.ResetPasswordConfirmCode = null!;
            user.ResetPasswordConfirmCodeExpiry = null;

            _accountRepository.Update(user);
            _accountRepository.SaveChanges();

            return new AccountResultDto { IsSuccess = true, Message = "密碼已重設完成，請重新登入" };
        }
    }
}
