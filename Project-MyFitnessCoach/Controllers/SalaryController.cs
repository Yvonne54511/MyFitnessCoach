using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;
using Project_MyFitnessCoach.Models.Infra;
using System;
using System.Threading.Tasks;
using Project_MyFitnessCoach.Models;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class SalaryController : Controller
    {
        private readonly ISalaryService _salaryService;
        private readonly IInstructorWalletService _walletService;

        public SalaryController(ISalaryService salaryService, IInstructorWalletService walletService)
        {
            _salaryService = salaryService;
            _walletService = walletService;
        }

        [Function("view_Salary")]
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

        [Function("view_MyWallet")]
        public async Task<IActionResult> MyWallet()
        {
            var instructorIdClaim = User.FindFirst("InstructorId");
            if (instructorIdClaim == null || !int.TryParse(instructorIdClaim.Value, out int instructorId))
            {
                return RedirectToAction("Error", "Home", new { id = 403 });
            }

            var wallet = await _walletService.GetWalletByInstructorIdAsync(instructorId);
            if (wallet == null)
            {
                // 如果錢包不存在，可能需要初始化或顯示錯誤
                return View("Error", new ErrorViewModel { RequestId = "Wallet not found" });
            }

            return View(wallet);
        }

        [Function("view_Salary")]
        public async Task<IActionResult> AllWallets()
        {
            var instructors = await _salaryService.GetInstructorsAsync();
            return View(instructors);
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
