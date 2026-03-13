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

        public IActionResult Index()
        {
            ViewBag.Title = "Dashboard 概覽";
            var summary = _dashboardService.GetSummary();
            return View(summary);
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

        public IActionResult KeyWordAnalytics()
        {
            ViewBag.Title = "評論關鍵字詞分析";
            var data = _dashboardService.GetKeyWordFrequencies();
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

