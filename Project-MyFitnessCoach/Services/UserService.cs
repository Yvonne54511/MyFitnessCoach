using Microsoft.AspNetCore.Identity;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Repositories;
using System.Text;
using System.Collections.Generic;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public interface IUserService
    {
        Task<IEnumerable<StaffDto>> GetStaffListAsync(string? name = null, string? role = null, int? id = null);
        Task<StaffDto?> GetStaffByIdAsync(int id);
        Task<StaffResultDto> InviteStaffAsync(StaffInviteDto dto, Func<string, string> generateUrl);
        Task<StaffResultDto> UpdateStaffAsync(StaffUpdateDto dto);
        Task<StaffResultDto> DeleteStaffAsync(int id);
        Task<IEnumerable<Role>> GetActiveRolesAsync();
        Task<StaffResultDto> ActivateAccountAsync(StaffActivateDto dto);
        Task<bool> IsConfirmCodeValidAsync(string code);
        Task<bool> AccountExistsAsync(string account);
    }

    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
        private readonly IEmailService _emailService;
        private readonly PasswordHasher<User> _passwordHasher;

        public UserService(IUserRepository userRepository, IEmailService emailService)
        {
            _userRepository = userRepository;
            _emailService = emailService;
            _passwordHasher = new PasswordHasher<User>();
        }

        public async Task<IEnumerable<StaffDto>> GetStaffListAsync(string? name = null, string? role = null, int? id = null)
        {
            var users = await _userRepository.GetAllUsersAsync();
            
            var query = users.AsQueryable();

            if (!string.IsNullOrWhiteSpace(name))
            {
                query = query.Where(u => u.UserName.Contains(name, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(role))
            {
                query = query.Where(u => u.UserRoles.Any(ur => ur.Role.RoleName == role));
            }

            if (id.HasValue)
            {
                query = query.Where(u => u.Id == id.Value);
            }

            return query.Select(u => new StaffDto
            {
                Id = u.Id,
                UserName = u.UserName,
                Email = u.Email,
                Account = u.Account,
                IsConfirmed = u.IsConfirmed,
                IsActive = u.IsActive,
                Roles = u.UserRoles.Select(ur => ur.Role.RoleName).ToList()
            });
        }

        public async Task<StaffDto?> GetStaffByIdAsync(int id)
        {
            var user = await _userRepository.GetUserByIdAsync(id);
            if (user == null) return null;

            return new StaffDto
            {
                Id = user.Id,
                UserName = user.UserName,
                Email = user.Email,
                IsActive = user.IsActive,
                RoleIds = user.UserRoles.Select(ur => ur.RoleId).ToList()
            };
        }

        public async Task<StaffResultDto> InviteStaffAsync(StaffInviteDto dto, Func<string, string> generateUrl)
        {
            var existingUser = await _userRepository.GetUserByEmailAsync(dto.Email);
            if (existingUser != null)
            {
                return new StaffResultDto { IsSuccess = false, Message = "該 Email 已被註冊" };
            }

            var confirmCode = Guid.NewGuid().ToString();
            var user = new User
            {
                UserName = dto.UserName,
                Email = dto.Email,
                IsConfirmed = false,
                IsActive = true,
                NewMemberConfirmCode = confirmCode,
                NewMemberConfirmCodeExpiry = DateTime.Now.AddDays(7)
            };

            await _userRepository.CreateUserAsync(user, dto.RoleIds);

            var invitationUrl = generateUrl(confirmCode);
            var emailSent = _emailService.SendStaffInvitationEmail(dto.Email, dto.UserName, invitationUrl);

            return new StaffResultDto 
            { 
                IsSuccess = emailSent, 
                Message = emailSent ? "邀請已送出" : "邀請送出失敗，請檢查 SMTP 設定" 
            };
        }

        public async Task<StaffResultDto> UpdateStaffAsync(StaffUpdateDto dto)
        {
            var user = new User
            {
                Id = dto.Id,
                UserName = dto.UserName,
                Email = dto.Email,
                IsActive = dto.IsActive
            };

            await _userRepository.UpdateUserAsync(user, dto.RoleIds);
            return new StaffResultDto { IsSuccess = true, Message = "更新成功" };
        }

        public async Task<StaffResultDto> DeleteStaffAsync(int id)
        {
            await _userRepository.DeleteUserAsync(id);
            return new StaffResultDto { IsSuccess = true, Message = "刪除成功" };
        }

        public async Task<IEnumerable<Role>> GetActiveRolesAsync()
        {
            return await _userRepository.GetAllRolesAsync();
        }

        public async Task<StaffResultDto> ActivateAccountAsync(StaffActivateDto dto)
        {
            var user = await _userRepository.GetUserByConfirmCodeAsync(dto.Code);
            if (user == null || (user.NewMemberConfirmCodeExpiry.HasValue && user.NewMemberConfirmCodeExpiry < DateTime.Now))
            {
                return new StaffResultDto { IsSuccess = false, Message = "啟動連結無效或已過期" };
            }

            user.Account = dto.Account;
            user.HashedPassword = _passwordHasher.HashPassword(user, dto.Password);
            user.IsConfirmed = true;
            user.IsActive = true;

            await _userRepository.UpdateUserAsync(user, null);
            return new StaffResultDto { IsSuccess = true, Message = "帳號啟用成功" };
        }

        public async Task<bool> IsConfirmCodeValidAsync(string code)
        {
            var user = await _userRepository.GetUserByConfirmCodeAsync(code);
            return user != null && (!user.NewMemberConfirmCodeExpiry.HasValue || user.NewMemberConfirmCodeExpiry > DateTime.Now);
        }

        public async Task<bool> AccountExistsAsync(string account)
        {
            return await _userRepository.AccountExistsAsync(account);
        }
    }
}
