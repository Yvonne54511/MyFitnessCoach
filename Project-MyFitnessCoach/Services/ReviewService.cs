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
    public class ReviewService
    {
        private readonly IReviewRepository _repo;
        private readonly NotificationService _notificationService;
        private readonly MyFitnessCoachDbContext _db;

        public ReviewService(IReviewRepository repo, NotificationService notificationService, MyFitnessCoachDbContext db)
        {
            _repo = repo;
            _notificationService = notificationService;
            _db = db;
        }

        public async Task<IEnumerable<ReviewDto>> GetAdminReviewsAsync()
        {
            var entities = (await _repo.GetAllReviewsAsync()).ToList();
            var sensitiveWords = await _db.KeyWords.Where(k => k.Category == -1).Select(s => s.Word).ToListAsync();

            // 取得檢舉類型的通知 (Report1)
            var reports = await _db.Notifications
                .Where(n => n.NotifyType == "Report1")
                .Select(n => new { n.NotifyType, n.Content })
                .ToListAsync();

            return entities.Select(e => {
                var report = reports.FirstOrDefault(n => n.Content != null && 
                    (n.Content.Contains($"?id={e.Id}") || n.Content.Contains($"id={e.Id}")));
                
                string displayReason = report?.Content;
                if (!string.IsNullOrEmpty(displayReason))
                {
                    int urlIdx = displayReason.IndexOf(" [Url:");
                    if (urlIdx >= 0)
                    {
                        displayReason = displayReason.Substring(0, urlIdx).Trim();
                    }
                    if (string.IsNullOrEmpty(displayReason)) displayReason = "檢舉人未填寫具體原因";
                }

                string maskedComment = e.Comment;
                foreach (var word in sensitiveWords)
                {
                    if (!string.IsNullOrEmpty(maskedComment) && !string.IsNullOrEmpty(word))
                    {
                        string stars = new string('*', word.Length);
                        string replacement = $"<span class='sensitive-toggle text-danger' style='cursor:pointer; font-weight:bold;' data-original='{word}' data-masked='{stars}' title='點擊查看/隱藏'>{stars}</span>";
                        maskedComment = maskedComment.Replace(word, replacement);
                    }
                }

                return new ReviewDto
                {
                    Id = e.Id,
                    InstructorId = e.InstructorId,
                    InstructorName = e.Instructor?.User?.UserName ?? "未知營養師",
                    MemberId = e.MemberId,
                    MemberName = e.Member?.User?.UserName ?? "未知會員",
                    Rating = e.Rating,
                    Comment = maskedComment,
                    ReportMessage = displayReason,
                    CreatedAt = e.CreatedAt,
                    IsUserActive = e.Member?.User?.IsActive ?? true
                };
            });
        }

        public async Task<IEnumerable<ReviewDto>> GetInstructorReviewsAsync(int instructorId)
        {
            var entities = await _repo.GetReviewsByInstructorIdAsync(instructorId);
            var sensitiveWords = await _db.KeyWords.Where(k => k.Category == -1).Select(s => s.Word).ToListAsync();

            return entities.Select(e => {
                string maskedComment = e.Comment;
                foreach (var word in sensitiveWords)
                {
                    if (!string.IsNullOrEmpty(maskedComment) && !string.IsNullOrEmpty(word))
                    {
                        string stars = new string('*', word.Length);
                        string replacement = $"<span class='sensitive-toggle text-danger' style='cursor:pointer; font-weight:bold;' data-original='{word}' data-masked='{stars}' title='點擊查看/隱藏'>{stars}</span>";
                        maskedComment = maskedComment.Replace(word, replacement);
                    }
                }

                return new ReviewDto
                {
                    Id = e.Id,
                    MemberId = e.MemberId,
                    MemberName = e.Member?.User?.UserName ?? "未知會員",
                    Rating = e.Rating,
                    Comment = maskedComment,
                    CreatedAt = e.CreatedAt
                };
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
