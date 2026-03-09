using MyFitnessCoachDb.Models.EfModels;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModels;
using System.Linq;

namespace Project_MyFitnessCoach.Models.DTOs
{
	public static class ProductDtoExtensions
	{
		public static IQueryable<ProductDto> ToDto(this IQueryable<Product> product)
		{
			return product.Select(p => new ProductDto
			{
				Id = p.Id,
				CategoryId = p.CategoryId,
				Name = p.Name,
				ImageUrl = p.ImageUrl,
				OriginalPrice = p.OriginalPrice,
				UnitPrice = p.UnitPrice,
				Description = p.Description,
				SortOrder = p.SortOrder,
				IsActive = p.IsActive,
				CategoryName = p.Category.CategoryName
			});
		}

		public static ProductDto ToDto(this Product p)
		{
			return new ProductDto
			{
				Id = p.Id,
				CategoryId = p.CategoryId,
				Name = p.Name,
				ImageUrl = p.ImageUrl,
				OriginalPrice = p.OriginalPrice,
				UnitPrice = p.UnitPrice,
				Description = p.Description,
				SortOrder = p.SortOrder,
				IsActive = p.IsActive,
				CategoryName = p.Category?.CategoryName
			};
		}

		public static Product ToEntity(this ProductDto dto)
		{
			return new Product
			{
				Id = dto.Id,
				CategoryId = dto.CategoryId,
				Name = dto.Name,
				ImageUrl = dto.ImageUrl,
				OriginalPrice = dto.OriginalPrice,
				UnitPrice = dto.UnitPrice,
				Description = dto.Description,
				SortOrder = dto.SortOrder,
				IsActive = dto.IsActive
			};
		}

		//��K�bController���NProductDto�ഫ��ProductIndexItemViewModel
		public static ProductIndexItemViewModel ToViewModel(this ProductDto product)
		{
			return new ProductIndexItemViewModel
			{
				Id = product.Id,
				CategoryId = product.CategoryId,
				Name = product.Name,
				ImageUrl = product.ImageUrl,
				OriginalPrice = product.OriginalPrice,
				UnitPrice = product.UnitPrice,
				Description = product.Description,
				SortOrder = product.SortOrder,
				IsActive = product.IsActive,
				CategoryName = product.CategoryName
			};
		}

	}
}
