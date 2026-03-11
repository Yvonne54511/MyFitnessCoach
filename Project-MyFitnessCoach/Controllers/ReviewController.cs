using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Services;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class ReviewController : Controller
    {
        private readonly IReviewService _service;

        public ReviewController(IReviewService service)
        {
            _service = service;
        }

        public IActionResult Index()
        {
            if (User.IsInRole("Admin")) return RedirectToAction(nameof(AdminIndex));
            if (User.IsInRole("Instructor")) return RedirectToAction(nameof(InstructorIndex));
            return Forbid();
        }

        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AdminIndex()
        {
            var dtos = await _service.GetAdminReviewsAsync();
            return View(dtos);
        }

        [Authorize(Roles = "Instructor")]
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
        [Authorize(Roles = "Admin")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteReview(int id)
        {
            await _service.DeleteReviewAsync(id);
            TempData["SuccessMessage"] = "評論已成功刪除。";
            return RedirectToAction(nameof(AdminIndex));
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SuspendMember(int memberId)
        {
            await _service.SuspendMemberAsync(memberId);
            TempData["SuccessMessage"] = "學員帳號已停權。";
            return RedirectToAction(nameof(AdminIndex));
        }

        [HttpPost]
        [Authorize(Roles = "Instructor")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ReportReview(int id)
        {
            await _service.ReportReviewAsync(id);
            TempData["SuccessMessage"] = "評論已舉報。";
            return RedirectToAction(nameof(InstructorIndex));
        }
    }
}
