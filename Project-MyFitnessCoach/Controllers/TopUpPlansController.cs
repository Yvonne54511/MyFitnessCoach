using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.Infra;
using Project_MyFitnessCoach.Models.Services;
using Project_MyFitnessCoach.Models.ViewModels;

namespace Project_MyFitnessCoach.Controllers
{
    [Function("edit_Plans")]
    public class TopUpPlansController : Controller
    {
        private readonly TopUpPlanService _service;

        public TopUpPlansController(TopUpPlanService service)
        {
            _service = service;
        }

        public IActionResult Index()
        {
            var plans = _service.GetAllPlans()
                .Select(p => p.ToViewModel())
                .ToList();
            return View(plans);
        }

        public IActionResult Details(int id)
        {
            var dto = _service.GetPlan(id);
            if (dto == null) return NotFound();

            return View(dto.ToViewModel());
        }

        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(TopUpPlanViewModel model)
        {
            if (ModelState.IsValid)
            {
                var dto = new TopUpPlanDto
                {
                    PlanName = model.PlanName,
                    Price = model.Price,
                    Points = model.Points,
                    Description = model.Description,
                    IsActive = model.IsActive,
                    SortOrder = model.SortOrder ?? 0
                };
                _service.CreatePlan(dto);
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        public IActionResult Edit(int id)
        {
            var dto = _service.GetPlan(id);
            if (dto == null) return NotFound();

            return View(dto.ToViewModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Edit(TopUpPlanViewModel model)
        {
            if (ModelState.IsValid)
            {
                var dto = new TopUpPlanDto
                {
                    Id = model.Id,
                    PlanName = model.PlanName,
                    Price = model.Price,
                    Points = model.Points,
                    Description = model.Description,
                    IsActive = model.IsActive,
                    SortOrder = model.SortOrder
                };
                _service.UpdatePlan(dto);
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Delete(int id)
        {
            _service.DeactivatePlan(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
