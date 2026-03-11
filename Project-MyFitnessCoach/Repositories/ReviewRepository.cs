using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repositories
{
    public class ReviewRepository : IReviewRepository
    {
        private readonly MyFitnessCoachDbContext _db;

        public ReviewRepository(MyFitnessCoachDbContext db)
        {
            _db = db;
        }

        public async Task<IEnumerable<Review>> GetAllReviewsAsync()
        {
            return await _db.Reviews
                .Include(r => r.Instructor).ThenInclude(i => i.User)
                .Include(r => r.Member).ThenInclude(m => m.User)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }

        public async Task<IEnumerable<Review>> GetReviewsByInstructorIdAsync(int instructorId)
        {
            return await _db.Reviews
                .Include(r => r.Member).ThenInclude(m => m.User)
                .Where(r => r.InstructorId == instructorId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }

        public async Task<Review?> GetReviewByIdAsync(int id)
        {
            return await _db.Reviews.FindAsync(id);
        }

        public async Task DeleteReviewAsync(int id)
        {
            var review = await _db.Reviews.FindAsync(id);
            if (review != null)
            {
                _db.Reviews.Remove(review);
                await _db.SaveChangesAsync();
            }
        }

        public async Task<int?> GetUserIdByMemberIdAsync(int memberId)
        {
            var member = await _db.Members.FindAsync(memberId);
            return member?.UserId;
        }

        public async Task UpdateUserStatusAsync(int userId, bool isActive)
        {
            var user = await _db.Users.FindAsync(userId);
            if (user != null)
            {
                user.IsActive = isActive;
                await _db.SaveChangesAsync();
            }
        }

        public async Task IncrementMemberWarningCountAsync(int memberId, string reason)
        {
            var violation = await _db.MemberViolations
                .FirstOrDefaultAsync(v => v.MemberId == memberId);

            if (violation == null)
            {
                // 若尚無紀錄則建立
                violation = new MemberViolation
                {
                    MemberId = memberId,
                    WarningCount = 1,
                    Reason = reason,
                    LastWarningAt = DateTime.Now
                };
                _db.MemberViolations.Add(violation);
            }
            else
            {
                // 已有紀錄則次數 +1
                violation.WarningCount++;
                violation.Reason = reason;
                violation.LastWarningAt = DateTime.Now;
            }

            await _db.SaveChangesAsync();
        }
    }
}
