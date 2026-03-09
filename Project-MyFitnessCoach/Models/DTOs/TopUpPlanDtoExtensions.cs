using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModels;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public static class TopUpPlanDtoExtensions
    {
        public static TopUpPlanDto ToDto(this TopUpPlan plan)
        {
            return new TopUpPlanDto
            {
                Id = plan.Id,
                PlanName = plan.PlanName,
                Price = plan.Price,
                Points = plan.Points,
                Description = plan.Description,
                IsActive = plan.IsActive,
                SortOrder = plan.SortOrder
            };
        }

        public static TopUpPlan ToEntity(this TopUpPlanDto dto)
        {
            return new TopUpPlan
            {
                Id = dto.Id,
                PlanName = dto.PlanName,
                Price = dto.Price,
                Points = dto.Points,
                Description = dto.Description,
                IsActive = dto.IsActive,
                SortOrder = dto.SortOrder
            };
        }

        public static TopUpPlanViewModel ToViewModel(this TopUpPlanDto dto)
        {
            return new TopUpPlanViewModel
            {
                Id = dto.Id,
                PlanName = dto.PlanName,
                Price = dto.Price,
                Points = dto.Points,
                Description = dto.Description,
                IsActive = dto.IsActive,
                SortOrder = dto.SortOrder
            };
        }
    }
}
