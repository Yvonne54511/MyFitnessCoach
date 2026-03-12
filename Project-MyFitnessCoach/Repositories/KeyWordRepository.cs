using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IKeyWordRepository
    {
        Task<IEnumerable<KeyWord>> GetAllAsync();
        Task<KeyWord> GetByIdAsync(int id);
        Task CreateAsync(KeyWord keyWord);
        Task UpdateCategoryAsync(int id, int category);
        Task UpdateWeightAsync(int id, int weight);
        Task DeleteAsync(int id);
    }

    public class KeyWordRepository : IKeyWordRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public KeyWordRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<KeyWord>> GetAllAsync()
        {
            return await _context.KeyWords.ToListAsync();
        }

        public async Task<KeyWord> GetByIdAsync(int id)
        {
            return await _context.KeyWords.FirstOrDefaultAsync(s => s.Id == id);
        }

        public async Task CreateAsync(KeyWord keyWord)
        {
            _context.KeyWords.Add(keyWord);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateCategoryAsync(int id, int category)
        {
            var entity = await _context.KeyWords.FindAsync(id);
            if (entity != null)
            {
                entity.Category = category;
                await _context.SaveChangesAsync();
            }
        }

        public async Task UpdateWeightAsync(int id, int weight)
        {
            var entity = await _context.KeyWords.FindAsync(id);
            if (entity != null)
            {
                entity.Weight = weight;
                await _context.SaveChangesAsync();
            }
        }

        public async Task DeleteAsync(int id)
        {
            var keyWord = await _context.KeyWords.FindAsync(id);
            if (keyWord != null)
            {
                _context.KeyWords.Remove(keyWord);
                await _context.SaveChangesAsync();
            }
        }
    }
}