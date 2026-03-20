using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.Infra;
using Project_MyFitnessCoach.Services;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class ReviewController : Controller
    {
        private readonly ReviewService _service;

        public ReviewController(ReviewService service)
        {
            _service = service;
        }

        public IActionResult Index()
        {
            if (User.IsInRole("Admin")) return RedirectToAction(nameof(AdminIndex));
            if (User.IsInRole("Instructor")) return RedirectToAction(nameof(InstructorIndex));
            return Forbid();
        }

        [Authorize]
        [Function("edit_Comments_admin")]
        public async Task<IActionResult> AdminIndex()
        {
            var dtos = await _service.GetAdminReviewsAsync();
            
            // 排序邏輯：
            // 0: 有檢舉、未封鎖、未停權 (最優先)
            // 1: 有檢舉、已封鎖、未停權
            // 2: 無檢舉、已封鎖、未停權
            // 3: 無檢舉、未封鎖、未停權 (一般)
            // 4: 其他 (已停權，視為處理完成)
            var sortedDtos = dtos.OrderBy(r => {
                bool hasReport = !string.IsNullOrEmpty(r.ReportMessage);
                if (r.IsSuspended) return 4;
                if (hasReport && !r.IsBanned) return 0;
                if (hasReport && r.IsBanned) return 1;
                if (!hasReport && r.IsBanned) return 2;
                return 3;
            }).ThenByDescending(r => r.CreatedAt);

            return View(sortedDtos);
        }

        [Authorize]
        [Function("edit_Comments_instructor")]
        public async Task<IActionResult> InstructorIndex()
        {
            var instructorIdClaim = User.FindFirst("InstructorId")?.Value;
            if (string.IsNullOrEmpty(instructorIdClaim) || !int.TryParse(instructorIdClaim, out int instructorId))
            {
                return Forbid();
            }

            var dtos = await _service.GetInstructorReviewsAsync(instructorId);
            return View(dtos);
        }

        [HttpPost]
        [Authorize]
		[Function("edit_Comments_admin")]
		[ValidateAntiForgeryToken]
        public async Task<IActionResult> BanReview(int id)
        {
            var (newCount, isSuspended) = await _service.BanReviewAsync(id);
            TempData["SuccessMessage"] = "評論已成功封鎖。";

            if (newCount >= 5 && !isSuspended)
            {
                TempData["StrongWarning"] = $"該學員違規次數已達 {newCount} 次，建議立即進行停權處理！";
            }

            return RedirectToAction(nameof(AdminIndex));
        }
        [HttpPost]
        [Authorize]
		[Function("edit_Comments_admin")]
		[ValidateAntiForgeryToken]
        public async Task<IActionResult> SuspendMember(int memberId, string reason)
        {
            await _service.SuspendMemberAsync(memberId, reason);
            TempData["SuccessMessage"] = "學員帳號已停權。";
            return RedirectToAction(nameof(AdminIndex));
        }

        [HttpPost]
        [Authorize]
		[Function("edit_Comments_instructor")]
		[ValidateAntiForgeryToken]
        public async Task<IActionResult> ReportReview(int id, string reason)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int instructorUserId))
            {
                return Forbid();
            }

            await _service.ReportReviewAsync(id, instructorUserId, reason);
            TempData["SuccessMessage"] = "評論已舉報，管理員將會收到通知。";
            return RedirectToAction(nameof(InstructorIndex));
        }
    }
}
