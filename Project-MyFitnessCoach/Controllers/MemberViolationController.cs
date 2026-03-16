using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;
using System.Linq;

namespace Project_MyFitnessCoach.Controllers
{
    public class MemberViolationController : Controller
    {
        private readonly IMemberViolationService _service;

        public MemberViolationController(IMemberViolationService service)
        {
            _service = service;
        }

        public IActionResult Index()
        {
            var dtos = _service.GetAll();
            var viewModels = dtos.Select(d => new MemberViolationIndexViewModel
            {
                Id = d.Id,
                MemberName = d.MemberName,
                MemberEmail = d.MemberEmail,
                WarningCount = d.WarningCount,
                IsSuspended = d.IsSuspended,
                LastWarningAt = d.LastWarningAt,
                SuspendedAt = d.SuspendedAt,
                Reason = d.Reason
            }).ToList();

            return View(viewModels);
        }

        public IActionResult Create()
        {
            var availableMembers = _service.GetMembersAvailableForViolation();
            ViewBag.Members = new SelectList(availableMembers.Select(m => new
            {
                m.Id,
                DisplayName = $"{m.User.UserName} ({m.User.Email})"
            }), "Id", "DisplayName");

            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(MemberViolationCreateEditViewModel viewModel)
        {
            if (ModelState.IsValid)
            {
                var dto = new MemberViolationDto
                {
                    MemberId = viewModel.MemberId,
                    WarningCount = viewModel.WarningCount,
                    IsSuspended = viewModel.IsSuspended,
                    LastWarningAt = viewModel.LastWarningAt,
                    SuspendedAt = viewModel.SuspendedAt,
                    Reason = viewModel.Reason
                };

                _service.Create(dto);
                return RedirectToAction(nameof(Index));
            }

            var availableMembers = _service.GetMembersAvailableForViolation();
            ViewBag.Members = new SelectList(availableMembers.Select(m => new
            {
                m.Id,
                DisplayName = $"{m.User.UserName} ({m.User.Email})"
            }), "Id", "DisplayName");

            return View(viewModel);
        }

        public IActionResult Edit(int id)
        {
            var dto = _service.GetById(id);
            if (dto == null) return NotFound();

            var viewModel = new MemberViolationCreateEditViewModel
            {
                Id = dto.Id,
                MemberId = dto.MemberId,
                MemberName = dto.MemberName,
                WarningCount = dto.WarningCount,
                IsSuspended = dto.IsSuspended,
                LastWarningAt = dto.LastWarningAt,
                SuspendedAt = dto.SuspendedAt,
                Reason = dto.Reason
            };

            return View(viewModel);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Edit(MemberViolationCreateEditViewModel viewModel)
        {
            if (ModelState.IsValid)
            {
                var dto = new MemberViolationDto
                {
                    Id = viewModel.Id,
                    MemberId = viewModel.MemberId,
                    WarningCount = viewModel.WarningCount,
                    IsSuspended = viewModel.IsSuspended,
                    LastWarningAt = viewModel.LastWarningAt,
                    SuspendedAt = viewModel.SuspendedAt,
                    Reason = viewModel.Reason
                };

                _service.Update(dto);
                return RedirectToAction(nameof(Index));
            }

            // If we got here, something went wrong, re-fetch member name for display
            var existingDto = _service.GetById(viewModel.Id);
            if (existingDto != null)
            {
                viewModel.MemberName = existingDto.MemberName;
            }

            return View(viewModel);
        }

        [HttpPost]
        public IActionResult Delete(int id)
        {
            _service.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}