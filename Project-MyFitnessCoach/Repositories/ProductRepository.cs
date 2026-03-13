using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using System.Collections.Generic;
using System.Linq;

namespace Project_MyFitnessCoach.Repositories
{
	public interface IProductRepository
	{
		List<ProductDto> GetAll();
		ProductDto GetById(int id);
		void Create(ProductDto dto);
		void Update(ProductDto dto);
		void Deactivate(int id);
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
			return _context.Products
				.AsNoTracking()
				.Include(p => p.Category)
				.OrderBy(p => p.Category.SortOrder)
				.Select(p => p.ToDto())
				.ToList();
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
			product.ImageUrl = dto.ImageUrl ?? string.Empty;
			product.OriginalPrice = dto.OriginalPrice;
			product.UnitPrice = dto.UnitPrice;
			product.Description = dto.Description ?? string.Empty;
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
	}
}
