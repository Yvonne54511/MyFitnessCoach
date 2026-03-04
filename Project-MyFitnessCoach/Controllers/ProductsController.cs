using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.Services;

namespace Project_MyFitnessCoach.Controllers
{
	public class ProductsController : Controller
	{
		private readonly ProductService _service;

		public ProductsController(ProductService service)
		{
			_service = service;
		}

		public IActionResult Index()
		{
			var products = _service
				.GetAllProducts()
				.Select(p => p.ToViewModel())
				.ToList();

			return View(products);
		}
	}
}
