using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Services;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class DashboardController : Controller
    {
        private readonly IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        public IActionResult Index()
        {
            ViewBag.Title = "後台管理";
            var model = _dashboardService.GetSummary();
            return View(model);
        }
    }
}
