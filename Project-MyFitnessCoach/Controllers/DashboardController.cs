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
        private readonly Repositories.IKeyWordRepository _keyWordRepo;

        public DashboardController(IDashboardService dashboardService, Repositories.IKeyWordRepository keyWordRepo)
        {
            _dashboardService = dashboardService;
            _keyWordRepo = keyWordRepo;
        }

        public IActionResult Index(int? year, int? month)
        {
            int y = year ?? DateTime.Now.Year;
            int m = month ?? DateTime.Now.Month;
            
            ViewBag.Title = "Dashboard 概覽";
            var summary = _dashboardService.GetSummary(y, m);
            return View(summary);
        }

        public IActionResult Rating(int? year, int? month)
        {
            int y = year ?? DateTime.Now.Year;
            int m = month ?? DateTime.Now.Month;

            ViewBag.Title = "營養師評分統計";
            var ratings = _dashboardService.GetInstructorRatings(y, m);
            var yearlyRatings = _dashboardService.GetInstructorRatings(y, 0); // month = 0 is All Time for the year
            var globalRating = _dashboardService.GetGlobalRating(y, m);
            var viewModel = new InstructorRatingViewModel
            {
                InstructorRatings = ratings,
                YearlyInstructorRatings = yearlyRatings,
                GlobalRating = globalRating,
                SelectedYear = y,
                SelectedMonth = m
            };
            return View(viewModel);
        }

        public IActionResult KeyWordAnalytics(int? year, int? month)
        {
            int y = year ?? DateTime.Now.Year;
            int m = month ?? DateTime.Now.Month;

            ViewBag.Title = "評論關鍵字詞分析";
            var data = _dashboardService.GetKeyWordFrequencies(y, m);
            ViewBag.SelectedYear = y;
            ViewBag.SelectedMonth = m;
            return View(data);
        }

        [HttpPost]
        public async Task<IActionResult> CreateKeyWord(string word, int category, int weight)
        {
            if (string.IsNullOrEmpty(word)) return BadRequest("字詞不能為空");

            var keyWord = new Models.EfModels.KeyWord
            {
                Word = word,
                Category = category,
                Weight = weight
            };

            await _keyWordRepo.CreateAsync(keyWord);
            return Ok(new { success = true, message = $"已成功將「{word}」加入關鍵字庫" });
        }
    }
    }

