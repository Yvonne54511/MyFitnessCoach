using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class ShiftController : Controller
    {
        private readonly ShiftService _shiftService;
        private readonly IAdminService _adminService;
        private readonly ILogger<ShiftController> _logger;

        public ShiftController(ShiftService shiftService, IAdminService adminService, ILogger<ShiftController> logger)
        {
            _shiftService = shiftService;
            _adminService = adminService;
            _logger = logger;
        }

        // --- Instructor Actions ---

        [Authorize(Roles = "Instructor")]
        public IActionResult Index()
        {
            return View();
        }

        [HttpGet]
        [Authorize(Roles = "Instructor")]
        public async Task<IActionResult> GetBookedSlots()
        {
            var instructorIdClaim = User.FindFirst("InstructorId")?.Value;
            int instructorId = int.Parse(instructorIdClaim ?? "0");

            if (instructorId == 0)
            {
                return BadRequest(new { success = false, message = "無效的講師 ID" });
            }

            var bookedSlots = await _shiftService.GetBookedSlotsForFrontendAsync(instructorId);
            var remainingChances = await _shiftService.GetRemainingChancesAsync(instructorId);

            return Json(new { bookedSlots, remainingChances });
        }

        [HttpPost]
        [Authorize(Roles = "Instructor")]
        public async Task<IActionResult> Submit([FromBody] List<ShiftViewModel> vm)
        {
            var instructorIdClaim = User.FindFirst("InstructorId")?.Value;
            int instructorId = int.Parse(instructorIdClaim ?? "0");

            if (instructorId == 0)
            {
                return BadRequest(new { success = false, message = "無效的講師 ID" });
            }

            var result = await _shiftService.SaveFromViewModelsAsync(vm, instructorId);

            if (result.IsSuccess)
            {
                return Ok(new { success = true, message = "儲存成功" });
            }
            else
            {
                return BadRequest(new { success = false, message = result.ErrorMessage });
            }
        }

        // --- Admin Actions ---

        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AllShifts(ShiftQueryCriteria criteria)
        {
            var shifts = await _adminService.GetAllInstructorShiftsAsync(criteria);
            var instructors = await _adminService.GetInstructorsAsync();
            
            // Map DTOs to ViewModels
            var vms = shifts.Select(s => new AllShiftsViewModel
            {
                Id = s.Id,
                InstructorName = s.InstructorName,
                ScheduleDate = s.ScheduleDate,
                TimeSlot = s.TimeSlot,
                IsBooked = s.IsBooked
            }).ToList();

            ViewBag.Instructors = instructors;
            ViewBag.Criteria = criteria;

            // Check if it's an AJAX request (common way is via X-Requested-With header)
            if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
            {
                return PartialView("_AllShiftsTable", vms);
            }
            
            return View(vms);
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateShiftStatus(int shiftId, bool isBooked)
        {
            var result = await _adminService.UpdateShiftStatusAsync(shiftId, isBooked);
            if (result)
            {
                return Json(new { success = true });
            }
            return Json(new { success = false, message = "更新失敗" });
        }
    }
}
