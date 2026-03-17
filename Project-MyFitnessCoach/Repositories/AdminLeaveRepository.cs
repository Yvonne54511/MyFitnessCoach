using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IAdminLeaveRepository
    {
        Task<List<LeaveRequest>> GetAllAsync(string? dept, string? status, string? month, string? keyword);
        Task<AdminLeaveStatsDto> GetStatsAsync(string? monthFilter);
        Task<LeaveRequest?> GetByIdAsync(int id);
    }

    public class AdminLeaveRepository : IAdminLeaveRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public AdminLeaveRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public async Task<List<LeaveRequest>> GetAllAsync(string? dept, string? status, string? month, string? keyword)
        {
            var query = _context.LeaveRequests
                .Include(r => r.Employee).ThenInclude(e => e.User)
                .Include(r => r.Employee).ThenInclude(e => e.Department)
                .Include(r => r.LeaveType)
                .Include(r => r.Approver).ThenInclude(a => a.User)
                .AsQueryable();

            // 部門篩選
            if (!string.IsNullOrEmpty(dept) && int.TryParse(dept, out var deptId))
            {
                query = query.Where(r => r.Employee.DepartmentId == deptId);
            }

            // 狀態篩選
            if (!string.IsNullOrEmpty(status))
            {
                query = query.Where(r => r.Status == status);
            }

            // 月份篩選
            if (!string.IsNullOrEmpty(month) && DateTime.TryParse(month + "-01", out var filterDate))
            {
                query = query.Where(r => r.StartDate.Year == filterDate.Year && r.StartDate.Month == filterDate.Month);
            }

            // 關鍵字搜尋（員工姓名、帳號）
            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(r =>
                    r.Employee.User.UserName.Contains(keyword) ||
                    r.Employee.User.Account.Contains(keyword));
            }

            return await query
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }

        public async Task<AdminLeaveStatsDto> GetStatsAsync(string? monthFilter)
        {
            var query = _context.LeaveRequests.AsQueryable();

            // 若有月份篩選，統計該月；否則統計本月
            DateTime targetDate;
            if (!string.IsNullOrEmpty(monthFilter) && DateTime.TryParse(monthFilter + "-01", out var parsed))
            {
                targetDate = parsed;
            }
            else
            {
                targetDate = DateTime.Now;
            }

            var monthRequests = await query
                .Where(r => r.StartDate.Year == targetDate.Year && r.StartDate.Month == targetDate.Month)
                .ToListAsync();

            return new AdminLeaveStatsDto
            {
                TotalThisMonth = monthRequests
                    .Where(r => r.Status == "Approved")
                    .Sum(r => r.DaysUsed),
                PendingCount = monthRequests.Count(r => r.Status == "Pending"),
                ApprovedCount = monthRequests.Count(r => r.Status == "Approved"),
                RejectedCount = monthRequests.Count(r => r.Status == "Rejected"),
                CancelPendingCount = monthRequests.Count(r => r.Status == "CancelPending")
            };
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
    }
}
