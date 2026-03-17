using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IEmployeeRepository
    {
        Task<List<Employee>> GetAllAsync(string? deptFilter, string? keyword);
        Task<Employee?> GetByIdAsync(int id);
        Task<Employee?> GetByUserIdAsync(int userId);
        Task UpdateAsync(Employee entity);
    }

    public class EmployeeRepository : IEmployeeRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public EmployeeRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public async Task<List<Employee>> GetAllAsync(string? deptFilter, string? keyword)
        {
            var query = _context.Employees
                .Include(e => e.User)
                .Include(e => e.Department)
                .Include(e => e.Manager).ThenInclude(m => m.User)
                .Include(e => e.WorkDelegate).ThenInclude(d => d.User)
                .AsQueryable();

            if (!string.IsNullOrEmpty(deptFilter) && int.TryParse(deptFilter, out var deptId))
            {
                query = query.Where(e => e.DepartmentId == deptId);
            }

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(e =>
                    e.User.UserName.Contains(keyword) ||
                    e.User.Account.Contains(keyword));
            }

            return await query
                .OrderBy(e => e.DepartmentId)
                .ThenBy(e => e.Id)
                .ToListAsync();
        }

        public async Task<Employee?> GetByIdAsync(int id)
        {
            return await _context.Employees
                .Include(e => e.User)
                .Include(e => e.Department)
                .Include(e => e.Manager).ThenInclude(m => m.User)
                .Include(e => e.WorkDelegate).ThenInclude(d => d.User)
                .FirstOrDefaultAsync(e => e.Id == id);
        }

        public async Task<Employee?> GetByUserIdAsync(int userId)
        {
            return await _context.Employees
                .Include(e => e.User)
                .FirstOrDefaultAsync(e => e.UserId == userId);
        }

        public async Task UpdateAsync(Employee entity)
        {
            _context.Entry(entity).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }
    }
}
