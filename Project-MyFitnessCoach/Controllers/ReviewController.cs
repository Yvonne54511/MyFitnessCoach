using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class ReviewController : Controller
    {
        // 講師查看對自己的評論，管理員查看所有評論
        public IActionResult Index()
        {
            if (User.IsInRole("Admin"))
            {
                // 管理員邏輯
                return View("AdminIndex");
            }
            else if (User.IsInRole("Instructor"))
            {
                // 講師邏輯
                return View("InstructorIndex");
            }

            return Forbid();
        }
    }
}
