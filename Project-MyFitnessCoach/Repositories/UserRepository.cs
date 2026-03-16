using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IUserRepository
    {
        Task<IEnumerable<User>> GetAllUsersAsync();
        Task<User?> GetUserByIdAsync(int id);
        Task<User?> GetUserByEmailAsync(string email);
        Task<User?> GetUserByConfirmCodeAsync(string code);
        Task CreateUserAsync(User user, IEnumerable<int> roleIds);
        Task UpdateUserAsync(User user, IEnumerable<int> roleIds);
        Task DeleteUserAsync(int id);
        Task<IEnumerable<Role>> GetAllRolesAsync();
        Task<IEnumerable<Role>> GetAllRolesIncludeInactiveAsync();
        Task CreateRoleAsync(Role role);
        Task UpdateRoleAsync(Role role);
        Task DeleteRoleAsync(int id);

        Task<IEnumerable<Function>> GetAllFunctionsAsync();
        Task CreateFunctionAsync(Function function);
        Task UpdateFunctionAsync(Function function);
        Task DeleteFunctionAsync(int id);

        Task<IEnumerable<RoleFunction>> GetRoleFunctionsAsync();
        Task AddRoleFunctionAsync(int roleId, int functionId);
        Task RemoveRoleFunctionAsync(int roleId, int functionId);
        Task UpdateRoleFunctionStatusAsync(int roleId, int functionId, bool isEnabled);

        Task UpdateUserActivationAsync(int id, bool isActive);
        Task<bool> AccountExistsAsync(string account);
        Task SaveChangesAsync();
    }

    public class UserRepository : IUserRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public UserRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        // Existing User Methods... (skipped for brevity in replace, but kept in file)
        public async Task<IEnumerable<User>> GetAllUsersAsync()
        {
            return await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .ToListAsync();
        }

        public async Task<User?> GetUserByIdAsync(int id)
        {
            return await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == id);
        }

        public async Task<User?> GetUserByEmailAsync(string email)
        {
            return await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
        }

        public async Task<User?> GetUserByConfirmCodeAsync(string code)
        {
            return await _context.Users.FirstOrDefaultAsync(u => u.NewMemberConfirmCode == code);
        }

        public async Task CreateUserAsync(User user, IEnumerable<int> roleIds)
        {
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            if (roleIds != null)
            {
                foreach (var roleId in roleIds)
                {
                    _context.UserRoles.Add(new UserRole { UserId = user.Id, RoleId = roleId });
                }
                await _context.SaveChangesAsync();
            }
        }

        public async Task UpdateUserAsync(User user, IEnumerable<int> roleIds)
        {
            var existingUser = await _context.Users
                .Include(u => u.UserRoles)
                .FirstOrDefaultAsync(u => u.Id == user.Id);

            if (existingUser != null)
            {
                existingUser.UserName = user.UserName;
                existingUser.Email = user.Email;
                existingUser.IsActive = user.IsActive;

                if (user.HashedPassword != null)
                {
                    existingUser.HashedPassword = user.HashedPassword;
                    existingUser.Account = user.Account;
                    existingUser.IsConfirmed = user.IsConfirmed;
                    existingUser.NewMemberConfirmCode = null;
                    existingUser.NewMemberConfirmCodeExpiry = null;
                }

                // Update roles
                _context.UserRoles.RemoveRange(existingUser.UserRoles);
                if (roleIds != null)
                {
                    foreach (var roleId in roleIds)
                    {
                        _context.UserRoles.Add(new UserRole { UserId = user.Id, RoleId = roleId });
                    }
                }

                await _context.SaveChangesAsync();
            }
        }

        public async Task DeleteUserAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user != null)
            {
                var roles = _context.UserRoles.Where(ur => ur.UserId == id);
                _context.UserRoles.RemoveRange(roles);
                _context.Users.Remove(user);
                await _context.SaveChangesAsync();
            }
        }

        // Role Methods
        public async Task<IEnumerable<Role>> GetAllRolesAsync()
        {
            return await _context.Roles.Where(r => r.IsActive).ToListAsync();
        }

        public async Task<IEnumerable<Role>> GetAllRolesIncludeInactiveAsync()
        {
            return await _context.Roles.ToListAsync();
        }

        public async Task CreateRoleAsync(Role role)
        {
            _context.Roles.Add(role);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateRoleAsync(Role role)
        {
            var existing = await _context.Roles.FindAsync(role.Id);
            if (existing != null)
            {
                existing.RoleName = role.RoleName;
                existing.Description = role.Description;
                existing.IsActive = role.IsActive;
                await _context.SaveChangesAsync();
            }
        }

        public async Task DeleteRoleAsync(int id)
        {
            var role = await _context.Roles.FindAsync(id);
            if (role != null)
            {
                _context.Roles.Remove(role);
                await _context.SaveChangesAsync();
            }
        }

        // Function Methods
        public async Task<IEnumerable<Function>> GetAllFunctionsAsync()
        {
            return await _context.Functions.ToListAsync();
        }

        public async Task CreateFunctionAsync(Function function)
        {
            _context.Functions.Add(function);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateFunctionAsync(Function function)
        {
            var existing = await _context.Functions.FindAsync(function.Id);
            if (existing != null)
            {
                existing.FunctionName = function.FunctionName;
                existing.Description = function.Description;
                existing.api_path = function.api_path;
                existing.IsActive = function.IsActive;
                await _context.SaveChangesAsync();
            }
        }

        public async Task DeleteFunctionAsync(int id)
        {
            var function = await _context.Functions.FindAsync(id);
            if (function != null)
            {
                _context.Functions.Remove(function);
                await _context.SaveChangesAsync();
            }
        }

        // RoleFunction Methods
        public async Task<IEnumerable<RoleFunction>> GetRoleFunctionsAsync()
        {
            return await _context.RoleFunctions
                .Include(rf => rf.Role)
                .Include(rf => rf.Function)
                .ToListAsync();
        }

        public async Task AddRoleFunctionAsync(int roleId, int functionId)
        {
            if (!await _context.RoleFunctions.AnyAsync(rf => rf.RoleId == roleId && rf.FunctionId == functionId))
            {
                _context.RoleFunctions.Add(new RoleFunction { RoleId = roleId, FunctionId = functionId });
                await _context.SaveChangesAsync();
            }
        }

        public async Task RemoveRoleFunctionAsync(int roleId, int functionId)
        {
            var rf = await _context.RoleFunctions.FirstOrDefaultAsync(x => x.RoleId == roleId && x.FunctionId == functionId);
            if (rf != null)
            {
                _context.RoleFunctions.Remove(rf);
                await _context.SaveChangesAsync();
            }
        }

        public async Task UpdateRoleFunctionStatusAsync(int roleId, int functionId, bool isEnabled)
        {
            if (isEnabled)
            {
                await AddRoleFunctionAsync(roleId, functionId);
            }
            else
            {
                await RemoveRoleFunctionAsync(roleId, functionId);
            }
        }

        public async Task UpdateUserActivationAsync(int id, bool isActive)
        {
            var user = await _context.Users.FindAsync(id);
            if (user != null)
            {
                user.IsActive = isActive;
                await _context.SaveChangesAsync();
            }
        }

        public async Task<bool> AccountExistsAsync(string account)
        {
            return await _context.Users.AnyAsync(u => u.Account == account);
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
