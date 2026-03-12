using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.Services;
using Project_MyFitnessCoach.Models.ViewModels;

namespace Project_MyFitnessCoach.Controllers
{
	public class ProductsController : Controller
	{
		private readonly ProductService _service;
		private readonly CategoryService _categoryService;
        private readonly IWebHostEnvironment _environment;

		public ProductsController(ProductService service, CategoryService categoryService, IWebHostEnvironment environment)
		{
			_service = service;
			_categoryService = categoryService;
            _environment = environment;
		}

		public IActionResult Index(string? name, int? categoryId)
		{
			var products = _service.GetAllProducts(name, categoryId)
				.Select(p => p.ToViewModel())
				.ToList();

            PrepareCategories();
            ViewBag.CurrentName = name;
            ViewBag.CurrentCategoryId = categoryId;

			return View(products);
		}

		public IActionResult Details(int id)
		{
			var dto = _service.GetProduct(id);
			if (dto == null) return NotFound();

			return View(dto.ToViewModel());
		}

		public IActionResult Create()
		{
			PrepareCategories();
			return View(new ProductIndexItemViewModel { IsActive = true, SortOrder = 0 });
		}

		[HttpPost]
		[ValidateAntiForgeryToken]
		public IActionResult Create(ProductIndexItemViewModel model)
		{
            if (model.UnitPrice > model.OriginalPrice)
            {
                ModelState.AddModelError("UnitPrice", "特價不得大於原價");
            }

			if (ModelState.IsValid)
			{
                // 處理檔案上傳
                if (model.ProductImage != null && model.ProductImage.Length > 0)
                {
                    model.ImageUrl = SaveImage(model.ProductImage);
                }

				var dto = new ProductDto
				{
					CategoryId = model.CategoryId,
					Name = model.Name,
					ImageUrl = model.ImageUrl ?? string.Empty,
					OriginalPrice = model.OriginalPrice,
					UnitPrice = model.UnitPrice,
					Description = model.Description ?? string.Empty,
					SortOrder = model.SortOrder,
					IsActive = model.IsActive
				};
				_service.CreateProduct(dto);
				return RedirectToAction(nameof(Index));
			}

			PrepareCategories();
			return View(model);
		}

		public IActionResult Edit(int id)
		{
			var dto = _service.GetProduct(id);
			if (dto == null) return NotFound();

			PrepareCategories();
			return View(dto.ToViewModel());
		}

		[HttpPost]
		[ValidateAntiForgeryToken]
		public IActionResult Edit(ProductIndexItemViewModel model)
		{
            if (model.UnitPrice > model.OriginalPrice)
            {
                ModelState.AddModelError("UnitPrice", "特價不得大於原價");
            }

			if (ModelState.IsValid)
			{
                var oldProduct = _service.GetProduct(model.Id);
                string? oldImageUrl = oldProduct?.ImageUrl;

                // 處理檔案上傳
                if (model.ProductImage != null && model.ProductImage.Length > 0)
                {
                    // 刪除舊檔案 (如果是本地路徑)
                    if (!string.IsNullOrEmpty(oldImageUrl) && oldImageUrl.StartsWith("/images/products/"))
                    {
                        DeleteImage(oldImageUrl);
                    }
                    model.ImageUrl = SaveImage(model.ProductImage);
                }

				var dto = new ProductDto
				{
					Id = model.Id,
					CategoryId = model.CategoryId,
					Name = model.Name,
					ImageUrl = model.ImageUrl ?? string.Empty,
					OriginalPrice = model.OriginalPrice,
					UnitPrice = model.UnitPrice,
					Description = model.Description ?? string.Empty,
					SortOrder = model.SortOrder,
					IsActive = model.IsActive
				};
				_service.UpdateProduct(dto);
				return RedirectToAction(nameof(Index));
			}

			PrepareCategories();
			return View(model);
		}

		[HttpPost]
		[ValidateAntiForgeryToken]
		public IActionResult Delete(int id)
		{
			_service.DeactivateProduct(id);
			return RedirectToAction(nameof(Index));
		}

		private void PrepareCategories()
		{
			var categories = _categoryService.GetAllCategories();
			ViewBag.Categories = new SelectList(categories, "Id", "CategoryName");
		}

        private string SaveImage(IFormFile imageFile)
        {
            string uploadsFolder = Path.Combine(_environment.WebRootPath, "images", "products");
            if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);

            string uniqueFileName = Guid.NewGuid().ToString() + "_" + imageFile.FileName;
            string filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                imageFile.CopyTo(fileStream);
            }

            return "/images/products/" + uniqueFileName;
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
