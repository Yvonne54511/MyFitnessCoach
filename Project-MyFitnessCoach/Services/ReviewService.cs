using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.Enums;
using Project_MyFitnessCoach.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public class ReviewService : IReviewService
    {
        private readonly IReviewRepository _repo;
        private readonly INotificationService _notificationService;
        private readonly MyFitnessCoachDbContext _db;

        public ReviewService(IReviewRepository repo, INotificationService notificationService, MyFitnessCoachDbContext db)
        {
            _repo = repo;
            _notificationService = notificationService;
            _db = db;
        }

        public async Task<IEnumerable<ReviewDto>> GetAdminReviewsAsync()
        {
            var entities = (await _repo.GetAllReviewsAsync()).ToList();

            // 取得檢舉類型的通知 (Report1)
            var reports = await _db.Notifications
                .Where(n => n.NotifyType == "Report1")
                .ToListAsync();

            return entities.Select(e => {
                // 搜尋包含此 Review ID 的通知。比對方式：包含 "?id=X" 或 "id=X"
                var report = reports.FirstOrDefault(n => n.Content != null && 
                    (n.Content.Contains($"?id={e.Id}") || n.Content.Contains($"id={e.Id}")));
                
                string displayReason = report?.Content;
                if (!string.IsNullOrEmpty(displayReason))
                {
                    // 移除 [Url:...] 標籤，只顯示營養師輸入的 Reason
                    int urlIdx = displayReason.IndexOf(" [Url:");
                    if (urlIdx >= 0)
                    {
                        displayReason = displayReason.Substring(0, urlIdx).Trim();
                    }
                    
                    // 如果 Reason 為空（僅有 URL），給予預設值
                    if (string.IsNullOrEmpty(displayReason)) displayReason = "檢舉人未填寫具體原因";
                }

                return new ReviewDto
                {
                    Id = e.Id,
                    InstructorId = e.InstructorId,
                    InstructorName = e.Instructor?.User?.UserName ?? "未知營養師",
                    MemberId = e.MemberId,
                    MemberName = e.Member?.User?.UserName ?? "未知會員",
                    Rating = e.Rating,
                    Comment = e.Comment,
                    ReportMessage = displayReason, // 這是 Modal 要顯示的重點
                    CreatedAt = e.CreatedAt,
                    IsUserActive = e.Member?.User?.IsActive ?? true
                };
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
                await _repo.DeleteReviewAsync(id);
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

        public async Task ReportReviewAsync(int id, int instructorUserId, string reason)
        {
            var review = await _db.Reviews
                .Include(r => r.Member)
                    .ThenInclude(m => m.User)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (review == null) return;

            var adminUserIds = _db.UserRoles
                .Where(ur => ur.Role.RoleName == "admin")
                .Select(ur => ur.UserId)
                .ToList();

            foreach (var adminId in adminUserIds)
            {
                await _notificationService.SendAsync(
                    receiverId: adminId,
                    senderId: instructorUserId,
                    type: NotifyType.Report1,
                    message: reason,
                    url: $"/Review/AdminIndex?id={id}"
                );
            }
        }
    }
}
