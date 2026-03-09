using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.Services;
using Project_MyFitnessCoach.Models.ViewModels;

namespace Project_MyFitnessCoach.Controllers
{
    public class ProductCategoriesController : Controller
    {
        private readonly CategoryService _service;

        public ProductCategoriesController(CategoryService service)
        {
            _service = service;
        }

        public IActionResult Index()
        {
            var categories = _service.GetAllCategories()
                .Select(c => c.ToViewModel())
                .ToList();
            return View(categories);
        }

        public IActionResult Details(int id)
        {
            var dto = _service.GetCategory(id);
            if (dto == null) return NotFound();

            return View(dto.ToViewModel());
        }

        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(CategoryViewModel model)
        {
            if (ModelState.IsValid)
            {
                var dto = new CategoryDto
                {
                    CategoryName = model.CategoryName,
                    SortOrder = model.SortOrder,
                    IsActive = model.IsActive
                };
                _service.CreateCategory(dto);
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        public IActionResult Edit(int id)
        {
            var dto = _service.GetCategory(id);
            if (dto == null) return NotFound();

            return View(dto.ToViewModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Edit(CategoryViewModel model)
        {
            if (ModelState.IsValid)
            {
                var dto = new CategoryDto
                {
                    Id = model.Id,
                    CategoryName = model.CategoryName,
                    SortOrder = model.SortOrder,
                    IsActive = model.IsActive
                };
                _service.UpdateCategory(dto);
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Delete(int id)
        {
            _service.DeactivateCategory(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
