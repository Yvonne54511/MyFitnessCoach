using Microsoft.AspNetCore.Identity;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Repositories;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public interface IMemberAccountService
    {
        Task<LoginResultDto> LoginAsync(LoginDto dto);
        Task<ResetPasswordRequestDto> CreateResetPasswordRequestAsync(string email, Func<string, string> resetUrlFactory);
        Task<AccountResultDto> ResetPasswordAsync(ResetPasswordDto dto);
        Task<bool> IsResetPasswordCodeValidAsync(string code);
        Task<AccountResultDto> ChangePasswordAsync(int userId, string oldPassword, string newPassword);

        Task<InstructorDto?> GetInstructorDetailsAsync(int userId);
        Task<AccountResultDto> UpdateInstructorDetailsAsync(InstructorDto dto);
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

        public async Task<InstructorDto?> GetInstructorDetailsAsync(int userId)
        {
            var user = await _accountRepository.GetByIdAsync(userId);
            if (user == null) return null;

            var instructor = await _accountRepository.GetInstructorByUserIdAsync(userId);
            return new InstructorDto
            {
                UserId = user.Id,
                UserName = user.UserName ?? user.Account,
                ImageUrl = instructor?.ImageUrl ?? string.Empty,
                Description = instructor?.Description ?? string.Empty,
                HourWage = instructor?.HourWage ?? 0
            };
        }

        public async Task<AccountResultDto> UpdateInstructorDetailsAsync(InstructorDto dto)
        {
            var instructor = await _accountRepository.GetInstructorByUserIdAsync(dto.UserId);
            if (instructor == null)
            {
                instructor = new Instructor
                {
                    UserId = dto.UserId,
                    ImageUrl = dto.ImageUrl,
                    Description = dto.Description,
                    HourWage = dto.HourWage,
                    IsActive = true
                };
                _accountRepository.AddInstructor(instructor);
            }
            else
            {
                instructor.ImageUrl = dto.ImageUrl;
                instructor.Description = dto.Description;
                instructor.HourWage = dto.HourWage;
                _accountRepository.UpdateInstructor(instructor);
            }

            await _accountRepository.SaveChangesAsync();
            return new AccountResultDto { IsSuccess = true, Message = "資料更新成功" };
        }

        public async Task<AccountResultDto> ChangePasswordAsync(int userId, string oldPassword, string newPassword)
        {
            var user = await _accountRepository.GetByIdAsync(userId);
            if (user == null)
            {
                return new AccountResultDto { IsSuccess = false, Message = "使用者不存在" };
            }

            var verification = _passwordHasher.VerifyHashedPassword(user, user.HashedPassword, oldPassword);
            if (verification == PasswordVerificationResult.Failed)
            {
                return new AccountResultDto { IsSuccess = false, Message = "目前密碼錯誤" };
            }

            user.HashedPassword = _passwordHasher.HashPassword(user, newPassword);
            _accountRepository.Update(user);
            await _accountRepository.SaveChangesAsync();

            return new AccountResultDto { IsSuccess = true, Message = "密碼修改成功" };
        }

        public async Task<LoginResultDto> LoginAsync(LoginDto dto)
        {
            var user = await _accountRepository.GetByAccountAsync(dto.Account);

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

            var instructor = await _accountRepository.GetInstructorByUserIdAsync(user.Id);
            var employee = await _accountRepository.GetEmployeeByUserIdAsync(user.Id);

            return new LoginResultDto
            {
                IsSuccess = true,
                Message = "登入成功",
                User = new UserDto
                {
                    Id = user.Id,
                    Account = user.Account,
                    UserName = user.UserName,
                    Email = user.Email,
                    HashedPassword = user.HashedPassword,
                    InstructorId = instructor?.Id,
                    EmployeeId = employee?.Id,
                    DepartmentId = employee?.DepartmentId,
                    Roles = user.UserRoles.Select(ur => ur.Role.RoleName).ToList(),
                    Functions = user.UserRoles
                        .SelectMany(ur => ur.Role.RoleFunctions)
                        .Select(rf => rf.Function.FunctionName)
                        .Distinct()
                        .ToList()
                }
            };
        }

        public async Task<ResetPasswordRequestDto> CreateResetPasswordRequestAsync(string email, Func<string, string> resetUrlFactory)
        {
            var user = await _accountRepository.GetByEmailAsync(email);
            if (user == null)
            {
                return new ResetPasswordRequestDto 
                { 
                    IsSuccess = false, 
                    Email = email, 
                    EmailSent = false,
                    Message = "找不到帳號，請檢查電子郵件地址並再試一次"
                };
            }

            user.ResetPasswordConfirmCode = Guid.NewGuid().ToString("N");
            user.ResetPasswordConfirmCodeExpiry = DateTime.Now.AddMinutes(30);
            
            _accountRepository.Update(user);
            await _accountRepository.SaveChangesAsync();

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
                IsSuccess = emailSent,
                Email = user.Email,
                EmailSent = emailSent,
                Message = emailSent ? "重設密碼信件已寄出" : "寄送失敗"
            };
        }

        public async Task<bool> IsResetPasswordCodeValidAsync(string code)
        {
            var user = await _accountRepository.GetByResetPasswordCodeAsync(code);
            return user != null
                && user.ResetPasswordConfirmCodeExpiry.HasValue
                && user.ResetPasswordConfirmCodeExpiry.Value >= DateTime.Now;
        }

        public async Task<AccountResultDto> ResetPasswordAsync(ResetPasswordDto dto)
        {
            var user = await _accountRepository.GetByResetPasswordCodeAsync(dto.Code);
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
            await _accountRepository.SaveChangesAsync();

            return new AccountResultDto { IsSuccess = true, Message = "密碼已重設完成，請重新登入" };
        }
    }
}
