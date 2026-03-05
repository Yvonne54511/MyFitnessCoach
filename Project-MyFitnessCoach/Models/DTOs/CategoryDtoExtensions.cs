using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModels;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public static class CategoryDtoExtensions
    {
        public static CategoryDto ToDto(this ProductCategory category)
        {
            return new CategoryDto
            {
                Id = category.Id,
                CategoryName = category.CategoryName,
                SortOrder = category.SortOrder,
                IsActive = category.IsActive
            };
        }

        public static ProductCategory ToEntity(this CategoryDto dto)
        {
            return new ProductCategory
            {
                Id = dto.Id,
                CategoryName = dto.CategoryName,
                SortOrder = dto.SortOrder,
                IsActive = dto.IsActive
            };
        }

        public static CategoryViewModel ToViewModel(this CategoryDto dto)
        {
            return new CategoryViewModel
            {
                Id = dto.Id,
                CategoryName = dto.CategoryName,
                SortOrder = dto.SortOrder,
                IsActive = dto.IsActive
            };
        }
    }
}
