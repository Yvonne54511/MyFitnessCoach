using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.ViewModels;
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
            ViewBag.Title = "x޲z";
            var model = _dashboardService.GetSummary();
            return View(model);
        }

        public IActionResult Rating()
        {
            ViewBag.Title = "營養師評分統計";
            var ratings = _dashboardService.GetInstructorRatings();
            var globalRating = _dashboardService.GetGlobalRating();
            var viewModel = new InstructorRatingViewModel
            {
                InstructorRatings = ratings,
                GlobalRating = globalRating
            };
            return View(viewModel);
        }
    }
}

