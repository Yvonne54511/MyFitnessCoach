using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IInstructorRepository
    {
        Task<IEnumerable<Instructor>> GetAllAsync();
        Task<Instructor?> GetByIdAsync(int id);
        Task<Instructor?> GetByUserIdAsync(int userId);
        Task CreateAsync(Instructor instructor);
        Task UpdateAsync(Instructor instructor);
        Task DeleteAsync(int id);
        Task<IEnumerable<User>> GetAvailableUsersAsync();
        Task SaveChangesAsync();
    }

    public class InstructorRepository : IInstructorRepository
    {
        private readonly MyFitnessCoachDbContext _db;

        public InstructorRepository(MyFitnessCoachDbContext db)
        {
            _db = db;
        }

        public async Task<IEnumerable<Instructor>> GetAllAsync()
        {
            return await _db.Instructors
                .Include(i => i.User)
                .ToListAsync();
        }

        public async Task<Instructor?> GetByIdAsync(int id)
        {
            return await _db.Instructors
                .Include(i => i.User)
                .FirstOrDefaultAsync(i => i.Id == id);
        }

        public async Task<Instructor?> GetByUserIdAsync(int userId)
        {
            return await _db.Instructors
                .Include(i => i.User)
                .FirstOrDefaultAsync(i => i.UserId == userId);
        }

        public async Task CreateAsync(Instructor instructor)
        {
            _db.Instructors.Add(instructor);
            await SaveChangesAsync();
        }

        public async Task UpdateAsync(Instructor instructor)
        {
            _db.Instructors.Update(instructor);
            await SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var instructor = await _db.Instructors.FindAsync(id);
            if (instructor != null)
            {
                _db.Instructors.Remove(instructor);
                await SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<User>> GetAvailableUsersAsync()
        {
            // 找出帳號存在且尚未加入 Instructor 資料表，且擁有 "Instructor" 角色的 User
            var instructorUserIds = await _db.Instructors.Select(i => i.UserId).ToListAsync();
            
            return await _db.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .Where(u => !instructorUserIds.Contains(u.Id) 
                            && u.IsConfirmed 
                            && u.IsActive
                            && u.UserRoles.Any(ur => ur.Role.RoleName == "Instructor"))
                .ToListAsync();
        }

        public async Task SaveChangesAsync()
        {
            await _db.SaveChangesAsync();
        }
    }
}
