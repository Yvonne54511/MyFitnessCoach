using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModels;

namespace Project_MyFitnessCoach.Models.DTOs
{
	public static class ProductDtoExtensions
	{
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
				ImageUrl = dto.ImageUrl ?? string.Empty,
				OriginalPrice = dto.OriginalPrice,
				UnitPrice = dto.UnitPrice,
				Description = dto.Description ?? string.Empty,
				SortOrder = dto.SortOrder,
				IsActive = dto.IsActive
			};
		}

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
