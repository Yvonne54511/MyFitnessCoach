using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Repositories;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public class ReviewService : IReviewService
    {
        private readonly IReviewRepository _repo;

        public ReviewService(IReviewRepository repo)
        {
            _repo = repo;
        }

        public async Task<IEnumerable<ReviewDto>> GetAdminReviewsAsync()
        {
            var entities = await _repo.GetAllReviewsAsync();
            return entities.Select(e => new ReviewDto
            {
                Id = e.Id,
                InstructorId = e.InstructorId,
                InstructorName = e.Instructor?.User?.UserName ?? "未知營養師",
                MemberId = e.MemberId,
                MemberName = e.Member?.User?.UserName ?? "未知會員",
                Rating = e.Rating,
                Comment = e.Comment,
                CreatedAt = e.CreatedAt,
                IsUserActive = e.Member?.User?.IsActive ?? true
            });
        }

        public async Task<IEnumerable<ReviewDto>> GetInstructorReviewsAsync(int instructorId)
        {
            var entities = await _repo.GetReviewsByInstructorIdAsync(instructorId);
            return entities.Select(e => new ReviewDto
            {
                Id = e.Id,
                MemberId = e.MemberId,
                MemberName = e.Member?.User?.UserName ?? "未知會員",
                Rating = e.Rating,
                Comment = e.Comment,
                CreatedAt = e.CreatedAt
            });
        }

        public async Task DeleteReviewAsync(int id)
        {
            var review = await _repo.GetReviewByIdAsync(id);
            if (review != null)
            {
                int memberId = review.MemberId;
                // 1. 刪除評論
                await _repo.DeleteReviewAsync(id);
                // 2. 增加會員違規次數 (+1)
                await _repo.IncrementMemberWarningCountAsync(memberId, "惡意評論被管理員刪除");
            }
        }

        public async Task SuspendMemberAsync(int memberId)
        {
            var userId = await _repo.GetUserIdByMemberIdAsync(memberId);
            if (userId.HasValue)
            {
                await _repo.UpdateUserStatusAsync(userId.Value, false);
            }
        }

        public async Task ReportReviewAsync(int id)
        {
            // 在此可擴充舉報資料表的寫入
            await Task.CompletedTask;
        }
    }
}
