using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IFunctionRepository
    {
        Task<List<Function>> GetAllAsync();
        Task<Function?> GetByIdAsync(int id);
        Task CreateAsync(Function function);
        Task UpdateAsync(Function function);
        Task DeleteAsync(int id);
    }

    public class FunctionRepository : IFunctionRepository
    {
        private readonly MyFitnessCoachDbContext _context;
        public FunctionRepository(MyFitnessCoachDbContext context) => _context = context;

        public async Task<List<Function>> GetAllAsync() => await _context.Functions.AsNoTracking().ToListAsync();

        public async Task<Function?> GetByIdAsync(int id) => await _context.Functions.FindAsync(id);

        public async Task CreateAsync(Function function)
        {
            _context.Functions.Add(function);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Function function)
        {
            _context.Functions.Update(function);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _context.Functions.FindAsync(id);
            if (entity != null)
            {
                _context.Functions.Remove(entity);
                await _context.SaveChangesAsync();
            }
        }
    }
}
