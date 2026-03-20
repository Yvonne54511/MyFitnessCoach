using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
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

            // 取得未讀的檢舉類型的通知 (Report1)
            var reports = await _db.Notifications
                .Where(n => n.NotifyType == "Report1" && !n.IsRead)
                .Select(n => new { n.NotifyType, n.Content, n.CreatedAt })
                .OrderBy(n => n.CreatedAt)
                .ToListAsync();

            return entities.Select(e => {
                var report = reports.LastOrDefault(n => n.Content != null && 
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
                    IsAccountActive = e.Member?.User?.IsActive ?? true,
                    IsSuspended = e.Member?.MemberViolation?.IsSuspended ?? false,
                    IsUserActive = (e.Member?.User?.IsActive ?? true) && !(e.Member?.MemberViolation?.IsSuspended ?? false),
                    IsBanned = e.IsBanned,
                    WarningCount = e.Member?.MemberViolation?.WarningCount ?? 0
                };
            });
        }

        public async Task DismissReportAsync(int id)
        {
            var review = await _db.Reviews.FindAsync(id);
            if (review == null) return;

            // 1. 處理留言封鎖與違規次數恢復邏輯
            if (review.IsBanned)
            {
                review.IsBanned = false;

                var violation = await _db.MemberViolations.FirstOrDefaultAsync(v => v.MemberId == review.MemberId);
                if (violation != null)
                {
                    if (violation.WarningCount > 0) violation.WarningCount--;

                    if (violation.WarningCount < 5 && violation.IsSuspended)
                    {
                        violation.IsSuspended = false;
                        violation.SuspendedAt = null;
                        violation.Reason = $"檢舉 (評論ID: {id}) 已被駁回，自動解除停權";
                    }
                }
            }

            // 2. 找出所有與該評論 ID 相關的未讀檢舉通知
            var reports = await _db.Notifications
                .Where(n => n.NotifyType == "Report1" && !n.IsRead && n.Content != null &&
                           (n.Content.Contains($"?id={id}") || n.Content.Contains($"id={id}")))
                .ToListAsync();

            // 3. 收集「不重複」的舉報者資訊，準備發送通知
            // 我們只需要知道誰舉報了，以及舉報的內容（取最後一筆即可）
            var uniqueReporters = reports
                .Where(n => n.SenderId.HasValue)
                .GroupBy(n => n.SenderId.Value)
                .Select(g => g.Last()) // 每個舉報者取一筆
                .ToList();

            // 標記所有相關通知為已讀
            foreach (var report in reports)
            {
                report.IsRead = true;
            }

            // 4. 對每位舉報者發送「一封」完整通知
            foreach (var report in uniqueReporters)
            {
                // 擷取原始檢舉原因
                string originalReason = report.Content ?? "未提供原因";
                int urlIdx = originalReason.IndexOf(" [Url:");
                if (urlIdx >= 0) originalReason = originalReason.Substring(0, urlIdx).Trim();

                // 移除 HTML 標籤（如果有的話，例如 sensitive-toggle）以便在通知中顯示純文字
                string cleanComment = System.Text.RegularExpressions.Regex.Replace(review.Comment ?? "", "<.*?>", string.Empty);
                if (cleanComment.Length > 50) cleanComment = cleanComment.Substring(0, 50) + "...";

                await _notificationService.SendAsync(
                    receiverId: report.SenderId.Value,
                    senderId: null, // 系統發送
                    type: NotifyType.System,
                    message: $"<b>您的檢舉已被駁回</b><br/>" +
                             $"[原評論內容]: {cleanComment}<br/>" +
                             $"[您的檢舉原因]: {originalReason}<br/>" +
                             $"[管理員評估]: 經審核後認為該評論符合規範，故不予封鎖並已恢復顯示。",
                    url: $"/Review/InstructorIndex"
                );
            }

            await _db.SaveChangesAsync();
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

        public async Task<(int NewCount, bool IsSuspended)> BanReviewAsync(int id)
        {
            var review = await _repo.GetReviewByIdAsync(id);
            if (review != null)
            {
                int memberId = review.MemberId;
                await _repo.BanReviewAsync(id);
                int newCount = await _repo.IncrementMemberWarningCountAsync(memberId, "惡意評論被管理員封鎖");
                
                var violation = await _db.MemberViolations.FirstOrDefaultAsync(v => v.MemberId == memberId);
                bool isSuspended = violation?.IsSuspended ?? false;

                return (newCount, isSuspended);
            }
            return (0, false);
        }

        public async Task SuspendMemberAsync(int memberId, string reason)
        {
            await _repo.SuspendMemberAsync(memberId, reason);
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
