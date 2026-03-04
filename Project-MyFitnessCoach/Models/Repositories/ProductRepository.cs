using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Models.Repositories
{

	public interface IProductRepository
	{
		List<ProductDto> GetAll();
	}

	public class ProductRepository : IProductRepository
	{
		private readonly MyFitnessCoachDbContext _context;

		public ProductRepository(MyFitnessCoachDbContext context)
		{
			_context = context;
		}

		public List<ProductDto> GetAll()
		{
			var data = _context.Products
				.AsNoTracking()
				.Include(p => p.Category)
				.OrderBy(p => p.Category.SortOrder)
				.ToDto()
				.ToList();

			return data;
		}
	}
}
