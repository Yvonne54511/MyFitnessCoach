using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;

using Project_MyFitnessCoach.Models.Infra;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    [Function("view_KeyWords")]
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
            // 只顯示正向 (1) 和 負向 (-1) 的關鍵字，忽略類別 0
            var vms = dtos.Where(d => d.Category != 0).Select(d => new KeyWordViewModel { 
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
		[Function("create_KeyWords")]
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

        // POST: KeyWords/Delete/5
        [HttpPost, ActionName("Delete")]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            await _service.DeleteAsync(id);
            return Ok(new { success = true });
        }

        // AJAX 更新類別
        [HttpPost]
		[Function("edit_KeyWords")]
		public async Task<IActionResult> UpdateCategory(int id, int category)
        {
            if (category == 0)
            {
                await _service.DeleteAsync(id);
                return Ok(new { deleted = true });
            }
            await _service.UpdateCategoryAsync(id, category);
            return Ok(new { deleted = false });
        }

        // AJAX 更新權重
        [HttpPost]
        [Function("edit_KeyWords")]
		public async Task<IActionResult> UpdateWeight(int id, int weight)
        {
            await _service.UpdateWeightAsync(id, weight);
            return Ok();
        }
    }
}