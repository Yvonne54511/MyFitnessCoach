using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.Services;
using Project_MyFitnessCoach.Models.ViewModels;

namespace Project_MyFitnessCoach.Controllers
{
    public class TopUpPlansController : Controller
    {
        private readonly TopUpPlanService _service;
        private readonly IWebHostEnvironment _environment;

        public TopUpPlansController(TopUpPlanService service, IWebHostEnvironment environment)
        {
            _service = service;
            _environment = environment;
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
            return View(new TopUpPlanViewModel { IsActive = true, SortOrder = 0 });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(TopUpPlanViewModel model)
        {
            if (ModelState.IsValid)
            {
                // 處理檔案上傳
                if (model.ProductImage != null && model.ProductImage.Length > 0)
                {
                    model.ImageUrl = SaveImage(model.ProductImage);
                }

                var dto = new TopUpPlanDto
                {
                    PlanName = model.PlanName,
                    ImageUrl = model.ImageUrl,
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
                var oldPlan = _service.GetPlan(model.Id);
                string? currentImageUrl = oldPlan?.ImageUrl;

                // 處理檔案上傳
                if (model.ProductImage != null && model.ProductImage.Length > 0)
                {
                    // 刪除舊檔案 (如果是本地路徑)
                    if (!string.IsNullOrEmpty(currentImageUrl) && currentImageUrl.StartsWith("/images/topupplans/"))
                    {
                        DeleteImage(currentImageUrl);
                    }
                    currentImageUrl = SaveImage(model.ProductImage);
                }
                else if (!string.IsNullOrEmpty(model.ImageUrl))
                {
                    // 如果手動輸入了網址，優先使用網址
                    currentImageUrl = model.ImageUrl;
                }

                var dto = new TopUpPlanDto
                {
                    Id = model.Id,
                    PlanName = model.PlanName,
                    ImageUrl = currentImageUrl,
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

        private string SaveImage(IFormFile imageFile)
        {
            string uploadsFolder = Path.Combine(_environment.WebRootPath, "images", "topupplans");
            if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);

            string uniqueFileName = Guid.NewGuid().ToString() + "_" + imageFile.FileName;
            string filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                imageFile.CopyTo(fileStream);
            }

            return "/images/topupplans/" + uniqueFileName;
        }

        private void DeleteImage(string relativePath)
        {
            try
            {
                string fullPath = Path.Combine(_environment.WebRootPath, relativePath.TrimStart('/'));
                if (System.IO.File.Exists(fullPath))
                {
                    System.IO.File.Delete(fullPath);
                }
            }
            catch (Exception ex)
            {
                // 可選擇記錄 Log
            }
        }
    }
}
