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

		public List<ProductDto> GetAllProducts()
		{
			return _repository.GetAll();
		}
	}
}
