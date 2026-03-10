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

        public async Task<IEnumerable<Role>> GetAllRolesAsync()
        {
            return await _context.Roles.Where(r => r.IsActive).ToListAsync();
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
