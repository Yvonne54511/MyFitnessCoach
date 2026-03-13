using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class ReservationController : Controller
    {
        private readonly ReservationService _reservationService;

        public ReservationController(ReservationService reservationService)
        {
            _reservationService = reservationService;
        }

        // 講師查看自己已被預約的班表
        [Authorize]
        public async Task<IActionResult> Index(DateOnly? startDate, DateOnly? endDate)
        {
            var instructorIdClaim = User.FindFirst("InstructorId")?.Value;
            int instructorId = int.Parse(instructorIdClaim ?? "0");

            if (instructorId == 0) return RedirectToAction("Index", "Login");

            var bookedShifts = await _reservationService.GetBookedShiftsAsync(instructorId, startDate, endDate);
            
            // 將 DTO 轉換為 ViewModel
            var vms = bookedShifts.Select(d => new ReservationViewModel
            {
                Id = d.Id,
                InstructorName = d.InstructorName,
                MemberName = d.MemberName ?? "未知名稱",
                ScheduleDate = d.ScheduleDate,
                TimeSlot = d.TimeSlot,
                Target = d.Target,
                Memorandum = d.Memorandum
            }).ToList();

            ViewBag.StartDate = startDate?.ToString("yyyy-MM-dd");
            ViewBag.EndDate = endDate?.ToString("yyyy-MM-dd");
            
            return View(vms);
        }

        // 檢視並編輯預約詳細資訊 (Memorandum)
        [HttpGet]
        [Authorize]
        public async Task<IActionResult> Edit(int id)
        {
            var booking = await _reservationService.GetBookingDetailsAsync(id);
            if (booking == null) return NotFound();

            var instructorIdClaim = User.FindFirst("InstructorId")?.Value;
            int instructorId = int.Parse(instructorIdClaim ?? "0");
            if (booking.InstructorId != instructorId) return Forbid();

            var vm = new ReservationViewModel
            {
                Id = booking.Id,
                InstructorName = booking.InstructorName,
                MemberName = booking.MemberName ?? "未知名稱",
                ScheduleDate = booking.ScheduleDate,
                TimeSlot = booking.TimeSlot,
                Target = booking.Target,
                Memorandum = booking.Memorandum
            };

            var fiveDaysAgo = DateOnly.FromDateTime(DateTime.Today.AddDays(-5));
            ViewBag.IsEditable = booking.ScheduleDate >= fiveDaysAgo;

            return View(vm);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize]
        public async Task<IActionResult> Edit([Bind("Id,Memorandum")] ReservationViewModel model)
        {
            var booking = await _reservationService.GetBookingDetailsAsync(model.Id);
            if (booking == null) return NotFound();

            var instructorIdClaim = User.FindFirst("InstructorId")?.Value;
            int instructorId = int.Parse(instructorIdClaim ?? "0");
            if (booking.InstructorId != instructorId) return Forbid();

            var fiveDaysAgo = DateOnly.FromDateTime(DateTime.Today.AddDays(-5));
            if (booking.ScheduleDate < fiveDaysAgo)
            {
                ModelState.AddModelError("", "超過五天的紀錄無法修改。");
                ViewBag.IsEditable = false;
                return View(model);
            }

            // 僅保留 Id 與 Memorandum 的驗證
            foreach (var key in ModelState.Keys.ToList())
            {
                if (key != nameof(model.Id) && key != nameof(model.Memorandum))
                {
                    ModelState.Remove(key);
                }
            }

            if (!ModelState.IsValid)
            {
                // 恢復顯示用的資訊
                model.MemberName = booking.MemberName ?? "未知名稱";
                model.Target = booking.Target;
                model.ScheduleDate = booking.ScheduleDate;
                model.TimeSlot = booking.TimeSlot;
                ViewBag.IsEditable = true;
                return View(model);
            }

            var result = await _reservationService.UpdateMemorandumAsync(model.Id, model.Memorandum);
            if (result.IsSuccess)
            {
                TempData["SuccessMessage"] = "變更成功";
                return RedirectToAction("Index");
            }

            ModelState.AddModelError("", result.ErrorMessage);
            ViewBag.IsEditable = true;
            return View(model);
        }
    }
}
