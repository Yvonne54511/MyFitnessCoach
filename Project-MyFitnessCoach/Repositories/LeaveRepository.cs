using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Repositories
{
    public interface ILeaveRepository
    {
        Task<List<LeaveRequest>> GetByEmployeeIdAsync(int employeeId);
        Task<LeaveRequest?> GetByIdAsync(int id);
        Task<LeaveStatsDto> GetStatsAsync(int employeeId, int year);
        Task AddAsync(LeaveRequest entity);
        Task UpdateAsync(LeaveRequest entity);
    }

    public class LeaveRepository : ILeaveRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public LeaveRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public async Task<List<LeaveRequest>> GetByEmployeeIdAsync(int employeeId)
        {
            return await _context.LeaveRequests
                .Include(r => r.Employee).ThenInclude(e => e.User)
                .Include(r => r.Employee).ThenInclude(e => e.Department)
                .Include(r => r.LeaveType)
                .Include(r => r.LeaveDelegate).ThenInclude(d => d.User)
                .Include(r => r.Approver).ThenInclude(a => a.User)
                .Where(r => r.EmployeeId == employeeId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }

        public async Task<LeaveRequest?> GetByIdAsync(int id)
        {
            return await _context.LeaveRequests
                .Include(r => r.Employee).ThenInclude(e => e.User)
                .Include(r => r.Employee).ThenInclude(e => e.Department)
                .Include(r => r.LeaveType)
                .Include(r => r.LeaveDelegate).ThenInclude(d => d.User)
                .Include(r => r.Approver).ThenInclude(a => a.User)
                .Include(r => r.Attachments)
                .FirstOrDefaultAsync(r => r.Id == id);
        }

        public async Task<LeaveStatsDto> GetStatsAsync(int employeeId, int year)
        {
            var requests = await _context.LeaveRequests
                .Where(r => r.EmployeeId == employeeId && r.CreatedAt.Year == year)
                .ToListAsync();

            return new LeaveStatsDto
            {
                TotalDaysThisYear = requests
                    .Where(r => r.Status == "Approved")
                    .Sum(r => r.DaysUsed),
                PendingCount = requests.Count(r => r.Status == "Pending"),
                ApprovedCount = requests.Count(r => r.Status == "Approved"),
                RejectedCount = requests.Count(r => r.Status == "Rejected")
            };
        }

        public async Task AddAsync(LeaveRequest entity)
        {
            await _context.LeaveRequests.AddAsync(entity);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(LeaveRequest entity)
        {
            _context.Entry(entity).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }
    }
}
