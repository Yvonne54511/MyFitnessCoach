using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IAccountRepository
    {
        User? GetByAccount(string account);
        User? GetByEmail(string email);
        User? GetByResetPasswordCode(string code);
        void Update(User user);
        void SaveChanges();
    }

    public class AccountRepository : IAccountRepository
    {
        private readonly MyFitnessCoachDbContext _db;

        public AccountRepository(MyFitnessCoachDbContext db)
        {
            _db = db;
        }

        public User? GetByAccount(string account)
        {
            return _db.Users
                .Include(u => u.Instructors)
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                        .ThenInclude(r => r.RoleFunctions)
                            .ThenInclude(rf => rf.Function)
                .FirstOrDefault(u => u.Account == account);
        }

        public User? GetByEmail(string email)
        {
            return _db.Users.FirstOrDefault(u => u.Email == email);
        }

        public User? GetByResetPasswordCode(string code)
        {
            return _db.Users.FirstOrDefault(u => u.ResetPasswordConfirmCode == code);
        }

        public void Update(User user)
        {
            _db.Users.Update(user);
        }

        public void SaveChanges()
        {
            _db.SaveChanges();
        }
    }
}
