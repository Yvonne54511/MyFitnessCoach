using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IUserRepository
    {
        IEnumerable<User> GetAllUsers();
        User GetUserById(int id);
        User GetUserByEmail(string email);
        User GetUserByConfirmCode(string code);
        void CreateUser(User user, IEnumerable<int> roleIds);
        void UpdateUser(User user, IEnumerable<int> roleIds);
        void DeleteUser(int id);
        IEnumerable<Role> GetAllRoles();
        void UpdateUserActivation(int id, bool isActive);
        bool AccountExists(string account);
    }

    public class UserRepository : IUserRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public UserRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public IEnumerable<User> GetAllUsers()
        {
            return _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .ToList();
        }

        public User GetUserById(int id)
        {
            return _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefault(u => u.Id == id);
        }

        public User GetUserByEmail(string email)
        {
            return _context.Users.FirstOrDefault(u => u.Email == email);
        }

        public User GetUserByConfirmCode(string code)
        {
            return _context.Users.FirstOrDefault(u => u.NewMemberConfirmCode == code);
        }

        public void CreateUser(User user, IEnumerable<int> roleIds)
        {
            _context.Users.Add(user);
            _context.SaveChanges();

            if (roleIds != null)
            {
                foreach (var roleId in roleIds)
                {
                    _context.UserRoles.Add(new UserRole { UserId = user.Id, RoleId = roleId });
                }
                _context.SaveChanges();
            }
        }

        public void UpdateUser(User user, IEnumerable<int> roleIds)
        {
            var existingUser = _context.Users
                .Include(u => u.UserRoles)
                .FirstOrDefault(u => u.Id == user.Id);

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

                _context.SaveChanges();
            }
        }

        public void DeleteUser(int id)
        {
            var user = _context.Users.Find(id);
            if (user != null)
            {
                // Due to foreign key constraints, we might want to soft delete or handle cascade
                // For now, let's just delete the user roles and then the user
                var roles = _context.UserRoles.Where(ur => ur.UserId == id);
                _context.UserRoles.RemoveRange(roles);
                _context.Users.Remove(user);
                _context.SaveChanges();
            }
        }

        public IEnumerable<Role> GetAllRoles()
        {
            return _context.Roles.Where(r => r.IsActive).ToList();
        }

        public void UpdateUserActivation(int id, bool isActive)
        {
            var user = _context.Users.Find(id);
            if (user != null)
            {
                user.IsActive = isActive;
                _context.SaveChanges();
            }
        }

        public bool AccountExists(string account)
        {
            return _context.Users.Any(u => u.Account == account);
        }
    }
}
