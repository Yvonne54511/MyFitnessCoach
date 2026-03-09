using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
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

		public List<ProductDto> GetAllProducts()
		{
			return _repository.GetAll();
		}

		public List<ProductCategory> GetCategories()
		{
			return _repository.GetCategories();
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
