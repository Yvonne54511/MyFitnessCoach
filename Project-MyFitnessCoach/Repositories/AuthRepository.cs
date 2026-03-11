using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IAuthRepository
    {
        bool IsAccountExist(string account);
        bool IsEmailExist(string email);
        void CreateUser(User user);
    }

    public class AuthRepository : IAuthRepository
    {
        private readonly MyFitnessCoachDbContext _db;

        public AuthRepository(MyFitnessCoachDbContext db)
        {
            _db = db;
        }

        public bool IsAccountExist(string account)
        {
            return _db.Users.Any(u => u.Account == account);
        }

        public bool IsEmailExist(string email)
        {
            return _db.Users.Any(u => u.Email == email);
        }

        public void CreateUser(User user)
        {
            _db.Users.Add(user);
            _db.SaveChanges();
        }
    }
}
