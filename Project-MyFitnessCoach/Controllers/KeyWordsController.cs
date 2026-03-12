using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize] // [Authorize(Roles = "Admin")]
    public class KeyWordsController : Controller
    {
        private readonly IKeyWordService _service;

        public KeyWordsController(IKeyWordService service)
        {
            _service = service;
        }

        // GET: KeyWords
        public async Task<IActionResult> Index()
        {
            var dtos = await _service.GetAllAsync();
            var vms = dtos.Select(d => new KeyWordViewModel { 
                Id = d.Id, 
                Word = d.Word,
                Category = d.Category,
                Weight = d.Weight
            });
            return View(vms);
        }

        // GET: KeyWords/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: KeyWords/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(KeyWordViewModel vm)
        {
            if (ModelState.IsValid)
            {
                var dto = new KeyWordDto { 
                    Word = vm.Word,
                    Category = vm.Category,
                    Weight = vm.Weight
                };
                await _service.CreateAsync(dto);
                return RedirectToAction(nameof(Index));
            }
            return View(vm);
        }

        // GET: KeyWords/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null) return NotFound();

            var dto = await _service.GetByIdAsync(id.Value);
            if (dto == null) return NotFound();

            var vm = new KeyWordViewModel { 
                Id = dto.Id, 
                Word = dto.Word,
                Category = dto.Category,
                Weight = dto.Weight
            };
            return View(vm);
        }

        // POST: KeyWords/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, KeyWordViewModel vm)
        {
            if (id != vm.Id) return NotFound();

            if (ModelState.IsValid)
            {
                var dto = new KeyWordDto { 
                    Id = vm.Id, 
                    Word = vm.Word,
                    Category = vm.Category,
                    Weight = vm.Weight
                };
                await _service.UpdateAsync(dto);
                return RedirectToAction(nameof(Index));
            }
            return View(vm);
        }

        // POST: KeyWords/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            await _service.DeleteAsync(id);
            return RedirectToAction(nameof(Index));
        }

        // 新增：AJAX 更新類別或權重
        [HttpPost]
        public async Task<IActionResult> UpdateCategory(int id, int category)
        {
            var dto = await _service.GetByIdAsync(id);
            if (dto == null) return NotFound();

            dto.Category = category;
            await _service.UpdateAsync(dto);
            return Ok();
        }

        [HttpPost]
        public async Task<IActionResult> UpdateWeight(int id, int weight)
        {
            var dto = await _service.GetByIdAsync(id);
            if (dto == null) return NotFound();

            dto.Weight = weight;
            await _service.UpdateAsync(dto);
            return Ok();
        }
    }
}