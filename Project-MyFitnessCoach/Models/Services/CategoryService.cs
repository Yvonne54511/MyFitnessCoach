using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.Repositories;

namespace Project_MyFitnessCoach.Models.Services
{
    public class CategoryService
    {
        private readonly ICategoryRepository _repository;

        public CategoryService(ICategoryRepository repository)
        {
            _repository = repository;
        }

        public List<CategoryDto> GetAllCategories()
        {
            return _repository.GetAll();
        }

        public CategoryDto GetCategory(int id)
        {
            return _repository.GetById(id);
        }

        public void CreateCategory(CategoryDto dto)
        {
            _repository.Create(dto);
        }

        public void UpdateCategory(CategoryDto dto)
        {
            _repository.Update(dto);
        }

        public void DeactivateCategory(int id)
        {
            _repository.Deactivate(id);
        }
    }
}
