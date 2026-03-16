using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.Infra;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    [Function("edit_SensitiveWords")]
    public class SensitiveWordsController : Controller
    {
        private readonly ISensitiveWordService _service;

        public SensitiveWordsController(ISensitiveWordService service)
        {
            _service = service;
        }

        // GET: SensitiveWords
        public async Task<IActionResult> Index()
        {
            var dtos = await _service.GetAllAsync();
            var vms = dtos.Select(d => new SensitiveWordViewModel { Id = d.Id, Word = d.Word });
            return View(vms);
        }

        // GET: SensitiveWords/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: SensitiveWords/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(SensitiveWordViewModel vm)
        {
            if (ModelState.IsValid)
            {
                var dto = new SensitiveWordDto { Word = vm.Word };
                await _service.CreateAsync(dto);
                return RedirectToAction(nameof(Index));
            }
            return View(vm);
        }

        // GET: SensitiveWords/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null) return NotFound();

            var dto = await _service.GetByIdAsync(id.Value);
            if (dto == null) return NotFound();

            var vm = new SensitiveWordViewModel { Id = dto.Id, Word = dto.Word };
            return View(vm);
        }

        // POST: SensitiveWords/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, SensitiveWordViewModel vm)
        {
            if (id != vm.Id) return NotFound();

            if (ModelState.IsValid)
            {
                var dto = new SensitiveWordDto { Id = vm.Id, Word = vm.Word };
                await _service.UpdateAsync(dto);
                return RedirectToAction(nameof(Index));
            }
            return View(vm);
        }

        // POST: SensitiveWords/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            await _service.DeleteAsync(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
