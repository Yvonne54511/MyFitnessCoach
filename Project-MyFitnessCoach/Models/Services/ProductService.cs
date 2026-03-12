using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.Repositories;

namespace Project_MyFitnessCoach.Models.Services
{
	public class ProductService
	{
		private readonly IProductRepository _repository;

		public ProductService(IProductRepository repository)
		{
			_repository = repository;
		}

		public List<ProductDto> GetAllProducts(string? name = null, int? categoryId = null)
		{
			var products = _repository.GetAll();

			if (!string.IsNullOrEmpty(name))
			{
				products = products.Where(p => p.Name.Contains(name, StringComparison.OrdinalIgnoreCase)).ToList();
			}

			if (categoryId.HasValue && categoryId.Value > 0)
			{
				products = products.Where(p => p.CategoryId == categoryId.Value).ToList();
			}

			return products;
		}

		public ProductDto GetProduct(int id)
		{
			return _repository.GetById(id);
		}

		public void CreateProduct(ProductDto dto)
		{
			_repository.Create(dto);
		}

		public void UpdateProduct(ProductDto dto)
		{
			_repository.Update(dto);
		}

		public void DeactivateProduct(int id)
		{
			_repository.Deactivate(id);
		}
	}
}
