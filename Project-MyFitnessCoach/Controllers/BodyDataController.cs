using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class BodyDataController : Controller
    {
        private readonly IBodyDataService _bodyDataService;

        public BodyDataController(IBodyDataService bodyDataService)
        {
            _bodyDataService = bodyDataService;
        }

        /// <summary>客戶身體數據列表（含搜尋與統計）</summary>
        public IActionResult Index(string searchName, string dateFrom, string dateTo)
        {
            ViewBag.Title = "客戶身體數據";

            // 組裝查詢 DTO 傳入 Service
            var query = new BodyDataQueryDto
            {
                SearchName = searchName,
                DateFrom   = dateFrom,
                DateTo     = dateTo
            };

            // Service 回傳 BodyDataResultDto
            var dto = _bodyDataService.GetBodyData(query);

            // Controller 將 DTO 對應至 ViewModel
            var vm = new BodyDataViewModel
            {
                Records      = dto.Records,
                SearchName   = dto.SearchName,
                DateFrom     = dto.DateFrom,
                DateTo       = dto.DateTo,
                TotalRecords = dto.TotalRecords,
                TotalMembers = dto.TotalMembers,
                AvgWeight    = dto.AvgWeight,
                AvgBodyFat   = dto.AvgBodyFat,
                MemberTrends = dto.MemberTrends
            };

            return View(vm);
        }

        /// <summary>單一會員身體數據歷史</summary>
        public IActionResult History(int memberId)
        {
            ViewBag.Title = "會員身體數據歷史";

            // Service 回傳 MemberHistoryDto
            var dto = _bodyDataService.GetMemberHistory(memberId);
            if (dto == null) return RedirectToAction(nameof(Index));

            // Controller 將 DTO 對應至 ViewModel
            var vm = new MemberHistoryViewModel
            {
                MemberId             = dto.MemberId,
                MemberName           = dto.MemberName,
                Gender               = dto.Gender,
                Height               = dto.Height,
                Target               = dto.Target,
                ActivityLevel        = dto.ActivityLevel,
                Records              = dto.Records,
                LatestWeight         = dto.LatestWeight,
                LatestBodyFat        = dto.LatestBodyFat,
                LatestSkeletalMuscle = dto.LatestSkeletalMuscle,
                LatestWaist          = dto.LatestWaist,
                WeightChange         = dto.WeightChange,
                BodyFatChange        = dto.BodyFatChange,
                SkeletalMuscleChange = dto.SkeletalMuscleChange,
                WaistChange          = dto.WaistChange,
                Dates                = dto.Dates,
                Weights              = dto.Weights,
                BodyFats             = dto.BodyFats,
                SkeletalMuscles      = dto.SkeletalMuscles,
                Waists               = dto.Waists
            };

            return View(vm);
        }
    }
}
