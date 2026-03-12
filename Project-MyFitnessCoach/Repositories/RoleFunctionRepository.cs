using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IRoleFunctionRepository
    {
        Task<List<RoleFunction>> GetAllAsync();
        Task CreateAsync(RoleFunction roleFunction);
        Task DeleteAsync(int id);
        Task<bool> ExistsAsync(int roleId, int functionId);
    }

    public class RoleFunctionRepository : IRoleFunctionRepository
    {
        private readonly MyFitnessCoachDbContext _context;
        public RoleFunctionRepository(MyFitnessCoachDbContext context) => _context = context;

        public async Task<List<RoleFunction>> GetAllAsync() => 
            await _context.RoleFunctions
                .Include(rf => rf.Role)
                .Include(rf => rf.Function)
                .AsNoTracking()
                .ToListAsync();

        public async Task CreateAsync(RoleFunction roleFunction)
        {
            _context.RoleFunctions.Add(roleFunction);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _context.RoleFunctions.FindAsync(id);
            if (entity != null)
            {
                _context.RoleFunctions.Remove(entity);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<bool> ExistsAsync(int roleId, int functionId) => 
            await _context.RoleFunctions.AnyAsync(rf => rf.RoleId == roleId && rf.FunctionId == functionId);
    }
}
