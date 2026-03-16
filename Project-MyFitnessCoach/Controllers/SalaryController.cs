using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;
using Project_MyFitnessCoach.Models.Infra;
using System;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    [Function("view_Salary")]
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

        public async Task<IActionResult> GetSalaryDetail(int instructorId, int? year, int? month, double? monthlyBonusPool, double? annualBonusPool)
        {
            int queryYear = year ?? DateTime.Now.Year;
            int queryMonth = month ?? DateTime.Now.Month;
            double mPool = monthlyBonusPool ?? 0;
            double aPool = annualBonusPool ?? 0;

            var detail = await _salaryService.GetSalaryDetailAsync(instructorId, queryYear, queryMonth, mPool, aPool);
            if (detail == null) return NotFound();

            return PartialView("_SalaryDetailPartial", detail);
        }
    }
}
