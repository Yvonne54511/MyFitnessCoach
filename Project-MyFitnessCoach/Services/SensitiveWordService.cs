using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public interface ISensitiveWordService
    {
        Task<IEnumerable<SensitiveWordDto>> GetAllAsync();
        Task<SensitiveWordDto> GetByIdAsync(int id);
        Task CreateAsync(SensitiveWordDto dto);
        Task UpdateAsync(SensitiveWordDto dto);
        Task DeleteAsync(int id);
    }

    public class SensitiveWordService : ISensitiveWordService
    {
        private readonly ISensitiveWordRepository _repository;

        public SensitiveWordService(ISensitiveWordRepository repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<SensitiveWordDto>> GetAllAsync()
        {
            var entities = await _repository.GetAllAsync();
            return entities.Select(e => new SensitiveWordDto { Id = e.Id, Word = e.Word });
        }

        public async Task<SensitiveWordDto> GetByIdAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return null;
            return new SensitiveWordDto { Id = entity.Id, Word = entity.Word };
        }

        public async Task CreateAsync(SensitiveWordDto dto)
        {
            var entity = new SensitiveWord { Word = dto.Word.Trim() };
            await _repository.CreateAsync(entity);
        }

        public async Task UpdateAsync(SensitiveWordDto dto)
        {
            var entity = await _repository.GetByIdAsync(dto.Id);
            if (entity != null)
            {
                entity.Word = dto.Word.Trim();
                await _repository.UpdateAsync(entity);
            }
        }

        public async Task DeleteAsync(int id)
        {
            await _repository.DeleteAsync(id);
        }
    }
}
