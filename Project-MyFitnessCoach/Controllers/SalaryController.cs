using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;
using System;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize(Roles = "Admin")] // Match the existing convention
    public class SalaryController : Controller
    {
        private readonly ISalaryService _salaryService;

        public SalaryController(ISalaryService salaryService)
        {
            _salaryService = salaryService;
        }

        public async Task<IActionResult> Index()
        {
            var instructors = await _salaryService.GetInstructorsAsync();
            var rankings = await _salaryService.GetRankingsAsync();

            var viewModel = new SalaryIndexViewModel
            {
                Instructors = instructors,
                Rankings = rankings
            };

            return View(viewModel);
        }

        public async Task<IActionResult> GetSalaryDetail(int instructorId, int? year, int? month)
        {
            int queryYear = year ?? DateTime.Now.Year;
            int queryMonth = month ?? DateTime.Now.Month;

            var detail = await _salaryService.GetSalaryDetailAsync(instructorId, queryYear, queryMonth);
            if (detail == null) return NotFound();

            return PartialView("_SalaryDetailPartial", detail);
        }
    }
}
