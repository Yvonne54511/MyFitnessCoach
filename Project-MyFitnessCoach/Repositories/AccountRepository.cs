using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IAccountRepository
    {
        Task<User?> GetByIdAsync(int id);
        Task<User?> GetByAccountAsync(string account);
        Task<User?> GetByEmailAsync(string email);
        Task<User?> GetByResetPasswordCodeAsync(string code);
        void Update(User user);
        Task SaveChangesAsync();

        Task<Instructor?> GetInstructorByUserIdAsync(int userId);
        void AddInstructor(Instructor instructor);
        void UpdateInstructor(Instructor instructor);
    }

    public class AccountRepository : IAccountRepository
    {
        private readonly MyFitnessCoachDbContext _db;

        public AccountRepository(MyFitnessCoachDbContext db)
        {
            _db = db;
        }

        public async Task<User?> GetByIdAsync(int id)
        {
            return await _db.Users.FindAsync(id);
        }

        public async Task<User?> GetByAccountAsync(string account)
        {
            return await _db.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .AsNoTracking()
                .FirstOrDefaultAsync(u => u.Account == account);
        }

        public async Task<User?> GetByEmailAsync(string email)
        {
            return await _db.Users.FirstOrDefaultAsync(u => u.Email == email);
        }

        public async Task<User?> GetByResetPasswordCodeAsync(string code)
        {
            return await _db.Users.FirstOrDefaultAsync(u => u.ResetPasswordConfirmCode == code);
        }

        public void Update(User user)
        {
            _db.Users.Update(user);
        }

        public async Task SaveChangesAsync()
        {
            await _db.SaveChangesAsync();
        }

        public async Task<Instructor?> GetInstructorByUserIdAsync(int userId)
        {
            return await _db.Instructors
                .Include(i => i.User)
                .FirstOrDefaultAsync(i => i.UserId == userId);
        }

        public void AddInstructor(Instructor instructor)
        {
            _db.Instructors.Add(instructor);
        }

        public void UpdateInstructor(Instructor instructor)
        {
            _db.Instructors.Update(instructor);
        }
    }
}
