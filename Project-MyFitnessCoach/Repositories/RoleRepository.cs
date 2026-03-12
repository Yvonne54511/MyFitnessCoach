using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IRoleRepository
    {
        Task<List<Role>> GetAllAsync();
        Task<Role?> GetByIdAsync(int id);
        Task CreateAsync(Role role);
        Task UpdateAsync(Role role);
        Task DeleteAsync(int id);
    }

    public class RoleRepository : IRoleRepository
    {
        private readonly MyFitnessCoachDbContext _context;
        public RoleRepository(MyFitnessCoachDbContext context) => _context = context;

        public async Task<List<Role>> GetAllAsync() => await _context.Roles.AsNoTracking().ToListAsync();

        public async Task<Role?> GetByIdAsync(int id) => await _context.Roles.FindAsync(id);

        public async Task CreateAsync(Role role)
        {
            _context.Roles.Add(role);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Role role)
        {
            _context.Roles.Update(role);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _context.Roles.FindAsync(id);
            if (entity != null)
            {
                _context.Roles.Remove(entity);
                await _context.SaveChangesAsync();
            }
        }
    }
}
