using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Models.Services
{
    public class TopUpPlanService
    {
        private readonly ITopUpPlanRepository _repository;

        public TopUpPlanService(ITopUpPlanRepository repository)
        {
            _repository = repository;
        }

        public List<TopUpPlanDto> GetAllPlans()
        {
            return _repository.GetAll();
        }

        public TopUpPlanDto GetPlan(int id)
        {
            return _repository.GetById(id);
        }

        public void CreatePlan(TopUpPlanDto dto)
        {
            _repository.Create(dto);
        }

        public void UpdatePlan(TopUpPlanDto dto)
        {
            _repository.Update(dto);
        }

        public void DeactivatePlan(int id)
        {
            _repository.Deactivate(id);
        }
    }
}
