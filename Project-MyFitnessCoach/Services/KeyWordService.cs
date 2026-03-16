using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public interface IKeyWordService
    {
        Task<IEnumerable<KeyWordDto>> GetAllAsync();
        Task<KeyWordDto> GetByIdAsync(int id);
        Task CreateAsync(KeyWordDto dto);
        Task UpdateCategoryAsync(int id, int category);
        Task UpdateWeightAsync(int id, int weight);
        Task DeleteAsync(int id);
    }

    public class KeyWordService : IKeyWordService
    {
        private readonly IKeyWordRepository _repository;

        public KeyWordService(IKeyWordRepository repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<KeyWordDto>> GetAllAsync()
        {
            var entities = await _repository.GetAllAsync();
            return entities.Select(e => new KeyWordDto { 
                Id = e.Id, 
                Word = e.Word,
                Category = e.Category,
                Weight = e.Weight
            });
        }

        public async Task<KeyWordDto> GetByIdAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return null;
            return new KeyWordDto { 
                Id = entity.Id, 
                Word = entity.Word,
                Category = entity.Category,
                Weight = entity.Weight
            };
        }

        public async Task CreateAsync(KeyWordDto dto)
        {
            var entity = new KeyWord { 
                Word = dto.Word.Trim(),
                Category = dto.Category,
                Weight = dto.Weight
            };
            await _repository.CreateAsync(entity);
        }

        public async Task UpdateCategoryAsync(int id, int category)
        {
            await _repository.UpdateCategoryAsync(id, category);
        }

        public async Task UpdateWeightAsync(int id, int weight)
        {
            await _repository.UpdateWeightAsync(id, weight);
        }

        public async Task DeleteAsync(int id)
        {
            await _repository.DeleteAsync(id);
        }
    }
}