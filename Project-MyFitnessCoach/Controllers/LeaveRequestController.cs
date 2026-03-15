using Microsoft.AspNetCore.Mvc;

namespace Project_MyFitnessCoach.Controllers
{
    public class LeaveRequestController : Controller
    {
        public IActionResult Staff()
        {
            return View();
        }

        public IActionResult Manager()
        {
            return View();
        }

        public IActionResult Admin()
        {
            return View();
        }
    }
}
