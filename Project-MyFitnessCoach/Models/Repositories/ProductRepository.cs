using Microsoft.EntityFrameworkCore;
using MyFitnessCoachDb.Models.EfModels;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Models.Repositories
{

	public interface IProductRepository
	{
		List<ProductDto> GetAll();
		ProductDto GetById(int id);
		void Create(ProductDto dto);
		void Update(ProductDto dto);
		void Deactivate(int id);
		List<ProductCategory> GetCategories();
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

		public ProductDto GetById(int id)
		{
			var product = _context.Products
				.AsNoTracking()
				.Include(p => p.Category)
				.FirstOrDefault(p => p.Id == id);

			return product?.ToDto();
		}

		public void Create(ProductDto dto)
		{
			var product = dto.ToEntity();
			_context.Products.Add(product);
			_context.SaveChanges();
		}

		public void Update(ProductDto dto)
		{
			var product = _context.Products.Find(dto.Id);
			if (product == null) return;

			product.CategoryId = dto.CategoryId;
			product.Name = dto.Name;
			product.ImageUrl = dto.ImageUrl;
			product.OriginalPrice = dto.OriginalPrice;
			product.UnitPrice = dto.UnitPrice;
			product.Description = dto.Description;
			product.SortOrder = dto.SortOrder;
			product.IsActive = dto.IsActive;

			_context.SaveChanges();
		}

		public void Deactivate(int id)
		{
			var product = _context.Products.Find(id);
			if (product == null) return;

			product.IsActive = false;
			_context.SaveChanges();
		}

		public List<ProductCategory> GetCategories()
		{
			return _context.ProductCategories
				.OrderBy(c => c.SortOrder)
				.ToList();
		}
	}
}
