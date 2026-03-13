using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IReviewRepository
    {
        Task<IEnumerable<Review>> GetAllReviewsAsync();
        Task<IEnumerable<Review>> GetReviewsByInstructorIdAsync(int instructorId);
        Task<Review?> GetReviewByIdAsync(int id);
        Task BanReviewAsync(int id);
        Task UpdateUserStatusAsync(int userId, bool isActive);
        Task SuspendMemberAsync(int memberId, string reason);
        Task<int?> GetUserIdByMemberIdAsync(int memberId);
        Task<int> IncrementMemberWarningCountAsync(int memberId, string reason);
    }

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
                .Include(r => r.Member).ThenInclude(m => m.MemberViolation)
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

        public async Task BanReviewAsync(int id)
        {
            var review = await _db.Reviews.FindAsync(id);
            if (review != null)
            {
                review.IsBanned = true;
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
        public async Task SuspendMemberAsync(int memberId, string reason)
        {
            var member = await _db.Members
                .Include(m => m.User)
                .Include(m => m.MemberViolation)
                .FirstOrDefaultAsync(m => m.Id == memberId);

            if (member != null)
            {
                // 2. 更新違規紀錄表 (MemberViolations)，將 IsSuspended 設為 1 (停權)
                if (member.MemberViolation == null)
                {
                    var violation = new MemberViolation
                    {
                        MemberId = memberId,
                        WarningCount = 0,
                        IsSuspended = true,
                        SuspendedAt = DateTime.Now,
                        Reason = string.IsNullOrEmpty(reason) ? "管理員手動停權" : reason
                    };
                    _db.MemberViolations.Add(violation);
                }
                else
                {
                    member.MemberViolation.IsSuspended = true;
                    member.MemberViolation.SuspendedAt = DateTime.Now;
                    member.MemberViolation.Reason = string.IsNullOrEmpty(reason) ? "管理員手動停權" : reason;
                }

                await _db.SaveChangesAsync();
            }
        }
        public async Task<int> IncrementMemberWarningCountAsync(int memberId, string reason)
        {
            var violation = await _db.MemberViolations
                .FirstOrDefaultAsync(v => v.MemberId == memberId);

            int count = 0;
            if (violation == null)
            {
                violation = new MemberViolation
                {
                    MemberId = memberId,
                    WarningCount = 1,
                    Reason = reason,
                    LastWarningAt = DateTime.Now
                };
                _db.MemberViolations.Add(violation);
                count = 1;
            }
            else
            {
                violation.WarningCount++;
                violation.Reason = reason;
                violation.LastWarningAt = DateTime.Now;
                count = violation.WarningCount;
            }

            await _db.SaveChangesAsync();
            return count;
        }
    }
}
