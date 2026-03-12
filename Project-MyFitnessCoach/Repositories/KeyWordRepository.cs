using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IKeyWordRepository
    {
        Task<IEnumerable<KeyWord>> GetAllAsync();
        Task<KeyWord> GetByIdAsync(int id);
        Task CreateAsync(KeyWord keyWord);
        Task UpdateAsync(KeyWord keyWord);
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

        public async Task UpdateAsync(KeyWord keyWord)
        {
            _context.Entry(keyWord).State = EntityState.Modified;
            await _context.SaveChangesAsync();
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