using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;

namespace Project_MyFitnessCoach.Repositories
{
    public interface ISensitiveWordRepository
    {
        Task<IEnumerable<SensitiveWord>> GetAllAsync();
        Task<SensitiveWord> GetByIdAsync(int id);
        Task CreateAsync(SensitiveWord sensitiveWord);
        Task UpdateAsync(SensitiveWord sensitiveWord);
        Task DeleteAsync(int id);
    }

    public class SensitiveWordRepository : ISensitiveWordRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public SensitiveWordRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<SensitiveWord>> GetAllAsync()
        {
            return await _context.SensitiveWords.ToListAsync();
        }

        public async Task<SensitiveWord> GetByIdAsync(int id)
        {
            return await _context.SensitiveWords.FirstOrDefaultAsync(s => s.Id == id);
        }

        public async Task CreateAsync(SensitiveWord sensitiveWord)
        {
            _context.SensitiveWords.Add(sensitiveWord);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(SensitiveWord sensitiveWord)
        {
            _context.Entry(sensitiveWord).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var sensitiveWord = await _context.SensitiveWords.FindAsync(id);
            if (sensitiveWord != null)
            {
                _context.SensitiveWords.Remove(sensitiveWord);
                await _context.SaveChangesAsync();
            }
        }
    }
}
