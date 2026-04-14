using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
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

        // Role Management
        Task<IEnumerable<RoleDto>> GetAllRolesAsync();
        Task<StaffResultDto> CreateRoleAsync(RoleDto dto);
        Task<StaffResultDto> UpdateRoleAsync(RoleDto dto);
        Task<StaffResultDto> DeleteRoleAsync(int id);

        // Function Management
        Task<IEnumerable<FunctionDto>> GetAllFunctionsAsync();
        Task<StaffResultDto> CreateFunctionAsync(FunctionDto dto);
        Task<StaffResultDto> UpdateFunctionAsync(FunctionDto dto);
        Task<StaffResultDto> DeleteFunctionAsync(int id);

        // Role-Function Mapping
        Task<IEnumerable<RoleFunctionDto>> GetRoleFunctionsAsync();
        Task<StaffResultDto> ToggleRoleFunctionAsync(int roleId, int functionId, bool isEnabled);
        Task<StaffResultDto> AddRoleFunctionsAsync(int roleId, IEnumerable<int> functionIds);
    }

    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
        private readonly IEmailService _emailService;
        private readonly EmployeeService _employeeService;
        private readonly MyFitnessCoachDbContext _context;
        private readonly PasswordHasher<User> _passwordHasher;

        public UserService(IUserRepository userRepository, IEmailService emailService,
            EmployeeService employeeService, MyFitnessCoachDbContext context)
        {
            _userRepository = userRepository;
            _emailService = emailService;
            _employeeService = employeeService;
            _context = context;
            _passwordHasher = new PasswordHasher<User>();
        }

        // Existing methods... (skipped for brevity)
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
                NewMemberConfirmCodeExpiry = DateTime.Now.AddDays(7),
                // 透過導覽屬性建立 UserRole，EF Core 在同一筆交易中一起儲存
                UserRoles = dto.RoleIds.Select(roleId => new UserRole { RoleId = roleId }).ToList()
            };

            await _userRepository.CreateUserAsync(user, dto.RoleIds);

            // ── 步驟 3.2：角色為必填，檢查是否需要建立 Employee 記錄 ──
            var roleNames = await _context.Roles
                .Where(r => dto.RoleIds.Contains(r.Id))
                .Select(r => r.RoleName)
                .ToListAsync();
            await _employeeService.EnsureEmployeeExistsAsync(user.Id, roleNames);

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

            // ── 步驟 3.2：角色指派後自動建立/停用 Employee ──
            var newRoleNames = await _context.Roles
                .Where(r => dto.RoleIds.Contains(r.Id))
                .Select(r => r.RoleName)
                .ToListAsync();

            await _employeeService.EnsureEmployeeExistsAsync(dto.Id, newRoleNames);
            await _employeeService.DeactivateEmployeeIfNoEmployeeRolesAsync(dto.Id, newRoleNames);

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

        // --- Role Management ---
        public async Task<IEnumerable<RoleDto>> GetAllRolesAsync()
        {
            var roles = await _userRepository.GetAllRolesIncludeInactiveAsync();
            return roles.Select(r => new RoleDto
            {
                Id = r.Id,
                RoleName = r.RoleName,
                Description = r.Description,
                IsActive = r.IsActive
            });
        }

        public async Task<StaffResultDto> CreateRoleAsync(RoleDto dto)
        {
            await _userRepository.CreateRoleAsync(new Role
            {
                RoleName = dto.RoleName,
                Description = dto.Description,
                IsActive = dto.IsActive
            });
            return new StaffResultDto { IsSuccess = true, Message = "角色建立成功" };
        }

        public async Task<StaffResultDto> UpdateRoleAsync(RoleDto dto)
        {
            await _userRepository.UpdateRoleAsync(new Role
            {
                Id = dto.Id,
                RoleName = dto.RoleName,
                Description = dto.Description,
                IsActive = dto.IsActive
            });
            return new StaffResultDto { IsSuccess = true, Message = "角色更新成功" };
        }

        public async Task<StaffResultDto> DeleteRoleAsync(int id)
        {
            await _userRepository.DeleteRoleAsync(id);
            return new StaffResultDto { IsSuccess = true, Message = "角色刪除成功" };
        }

        // --- Function Management ---
        public async Task<IEnumerable<FunctionDto>> GetAllFunctionsAsync()
        {
            var functions = await _userRepository.GetAllFunctionsAsync();
            return functions.Select(f => new FunctionDto
            {
                Id = f.Id,
                FunctionName = f.FunctionName,
                Description = f.Description,
                ApiPath = f.ApiPath,
                IsActive = f.IsActive
            });
        }

        public async Task<StaffResultDto> CreateFunctionAsync(FunctionDto dto)
        {
            await _userRepository.CreateFunctionAsync(new Function
            {
                FunctionName = dto.FunctionName,
                Description = dto.Description,
                ApiPath = dto.ApiPath,
                IsActive = dto.IsActive
            });
            return new StaffResultDto { IsSuccess = true, Message = "功能建立成功" };
        }

        public async Task<StaffResultDto> UpdateFunctionAsync(FunctionDto dto)
        {
            await _userRepository.UpdateFunctionAsync(new Function
            {
                Id = dto.Id,
                FunctionName = dto.FunctionName,
                Description = dto.Description,
                ApiPath = dto.ApiPath,
                IsActive = dto.IsActive
            });
            return new StaffResultDto { IsSuccess = true, Message = "功能更新成功" };
        }

        public async Task<StaffResultDto> DeleteFunctionAsync(int id)
        {
            await _userRepository.DeleteFunctionAsync(id);
            return new StaffResultDto { IsSuccess = true, Message = "功能刪除成功" };
        }

        // --- Role-Function Mapping ---
        public async Task<IEnumerable<RoleFunctionDto>> GetRoleFunctionsAsync()
        {
            var mappings = await _userRepository.GetRoleFunctionsAsync();
            return mappings.Select(m => new RoleFunctionDto
            {
                RoleId = m.RoleId,
                RoleName = m.Role.RoleName,
                FunctionId = m.FunctionId,
                FunctionName = m.Function.FunctionName,
                IsEnabled = true // If it exists in this table, it's enabled
            });
        }

        public async Task<StaffResultDto> ToggleRoleFunctionAsync(int roleId, int functionId, bool isEnabled)
        {
            await _userRepository.UpdateRoleFunctionStatusAsync(roleId, functionId, isEnabled);
            return new StaffResultDto { IsSuccess = true, Message = "權限更新成功" };
        }

        public async Task<StaffResultDto> AddRoleFunctionsAsync(int roleId, IEnumerable<int> functionIds)
        {
            foreach (var funcId in functionIds)
            {
                await _userRepository.AddRoleFunctionAsync(roleId, funcId);
            }
            return new StaffResultDto { IsSuccess = true, Message = "關聯建立成功" };
        }
    }
}
