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

		public IActionResult Index()
		{
			var products = _service.GetAllProducts()
				.Select(p => p.ToViewModel())
				.ToList();
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
			return View();
		}

		[HttpPost]
		[ValidateAntiForgeryToken]
		public IActionResult Create(ProductIndexItemViewModel model)
		{
			if (ModelState.IsValid)
			{
                // 處理檔案上傳
                if (model.ProductImage != null && model.ProductImage.Length > 0)
                {
                    string uploadsFolder = Path.Combine(_environment.WebRootPath, "images", "products");
                    if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);
                    
                    string uniqueFileName = Guid.NewGuid().ToString() + "_" + model.ProductImage.FileName;
                    string filePath = Path.Combine(uploadsFolder, uniqueFileName);
                    
                    using (var fileStream = new FileStream(filePath, FileMode.Create))
                    {
                        model.ProductImage.CopyTo(fileStream);
                    }
                    
                    model.ImageUrl = "/images/products/" + uniqueFileName;
                }

				var dto = new ProductDto
				{
					CategoryId = model.CategoryId,
					Name = model.Name,
					ImageUrl = model.ImageUrl,
					OriginalPrice = model.OriginalPrice,
					UnitPrice = model.UnitPrice,
					Description = model.Description,
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
			if (ModelState.IsValid)
			{
                // 處理檔案上傳
                if (model.ProductImage != null && model.ProductImage.Length > 0)
                {
                    string uploadsFolder = Path.Combine(_environment.WebRootPath, "images", "products");
                    if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);

                    string uniqueFileName = Guid.NewGuid().ToString() + "_" + model.ProductImage.FileName;
                    string filePath = Path.Combine(uploadsFolder, uniqueFileName);

                    using (var fileStream = new FileStream(filePath, FileMode.Create))
                    {
                        model.ProductImage.CopyTo(fileStream);
                    }

                    model.ImageUrl = "/images/products/" + uniqueFileName;
                }

				var dto = new ProductDto
				{
					Id = model.Id,
					CategoryId = model.CategoryId,
					Name = model.Name,
					ImageUrl = model.ImageUrl,
					OriginalPrice = model.OriginalPrice,
					UnitPrice = model.UnitPrice,
					Description = model.Description,
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
	}
}
