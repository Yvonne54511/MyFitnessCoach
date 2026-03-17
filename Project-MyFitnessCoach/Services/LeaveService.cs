using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public class LeaveService
    {
        private readonly ILeaveRepository _repo;
        private readonly MyFitnessCoachDbContext _db;

        public LeaveService(ILeaveRepository repo, MyFitnessCoachDbContext db)
        {
            _repo = repo;
            _db = db;
        }

        // ========== 我的請假申請 ==========

        public async Task<LeaveListViewModel> GetMyRequestsAsync(int employeeId, string statusFilter, string monthFilter)
        {
            var year = DateTime.Now.Year;
            var stats = await _repo.GetStatsAsync(employeeId, year);
            var requests = await _repo.GetByEmployeeIdAsync(employeeId);

            // 套用篩選
            if (!string.IsNullOrEmpty(statusFilter))
            {
                requests = requests.Where(r => r.Status == statusFilter).ToList();
            }
            if (!string.IsNullOrEmpty(monthFilter) && DateTime.TryParse(monthFilter + "-01", out var filterDate))
            {
                requests = requests.Where(r =>
                    r.StartDate.Year == filterDate.Year && r.StartDate.Month == filterDate.Month).ToList();
            }

            var dtos = requests.Select(r => new LeaveRequestDto
            {
                Id = r.Id,
                EmployeeId = r.EmployeeId,
                EmployeeName = r.Employee?.User?.UserName,
                DepartmentName = r.Employee?.Department?.Name,
                LeaveTypeName = r.LeaveType?.Name,
                StartDate = r.StartDate,
                EndDate = r.EndDate,
                DaysUsed = r.DaysUsed,
                Reason = r.Reason,
                DelegateName = r.LeaveDelegate?.User?.UserName,
                Status = r.Status,
                CreatedAt = r.CreatedAt,
                ApproverName = r.Approver?.User?.UserName,
                ApprovedAt = r.ApprovedAt,
                RejectReason = r.RejectReason
            }).ToList();

            return new LeaveListViewModel
            {
                Stats = stats,
                Requests = dtos,
                StatusFilter = statusFilter,
                MonthFilter = monthFilter
            };
        }

        // ========== 新增請假申請 ==========

        public async Task<AddLeaveViewModel> GetAddViewModelAsync(int employeeId)
        {
            var employee = await _db.Employees
                .Include(e => e.User)
                .Include(e => e.Department)
                .Include(e => e.Manager).ThenInclude(m => m.User)
                .FirstOrDefaultAsync(e => e.Id == employeeId);

            if (employee == null) return null;

            var leaveTypes = await _db.LeaveTypes
                .Where(lt => lt.IsActive)
                .ToListAsync();

            var colleagues = await _db.Employees
                .Include(e => e.User)
                .Where(e => e.DepartmentId == employee.DepartmentId && e.Id != employeeId && e.IsActive)
                .ToListAsync();

            var year = DateTime.Now.Year;
            var balances = await _db.LeaveBalances
                .Include(b => b.LeaveType)
                .Where(b => b.EmployeeId == employeeId && b.Year == year)
                .ToListAsync();

            return new AddLeaveViewModel
            {
                EmployeeName = employee.User?.UserName,
                DepartmentName = employee.Department?.Name,
                ManagerName = employee.Manager?.User?.UserName ?? "無",
                StartDate = DateTime.Today,
                EndDate = DateTime.Today,
                LeaveTypeOptions = leaveTypes.Select(lt => new SelectListItem
                {
                    Value = lt.Id.ToString(),
                    Text = lt.Name
                }).ToList(),
                DelegateOptions = new List<SelectListItem>
                {
                    new SelectListItem { Value = "", Text = "-- 不指定 --" }
                }.Concat(colleagues.Select(c => new SelectListItem
                {
                    Value = c.Id.ToString(),
                    Text = c.User?.UserName
                })).ToList(),
                Balances = balances.Select(b => new LeaveBalanceDto
                {
                    LeaveTypeName = b.LeaveType?.Name,
                    TotalDays = b.TotalDays,
                    UsedDays = b.UsedDays,
                    RemainingDays = b.RemainingDays ?? (b.TotalDays - b.UsedDays)
                }).ToList()
            };
        }

        public async Task<Result> ApplyAsync(AddLeaveRequestDto dto)
        {
            // 驗證日期
            if (dto.StartDate > dto.EndDate)
                return Result.Failure("開始日期不可晚於結束日期");

            // 計算請假天數（排除週末）
            decimal daysUsed = CalculateBusinessDays(dto.StartDate, dto.EndDate);
            if (daysUsed <= 0)
                return Result.Failure("請假天數必須大於 0");

            // 查詢假別
            var leaveType = await _db.LeaveTypes.FindAsync(dto.LeaveTypeId);
            if (leaveType == null)
                return Result.Failure("無效的假別");

            // 驗證餘額
            var year = dto.StartDate.Year;
            var balance = await _db.LeaveBalances
                .FirstOrDefaultAsync(b => b.EmployeeId == dto.EmployeeId
                    && b.LeaveTypeId == dto.LeaveTypeId
                    && b.Year == year);

            if (balance != null)
            {
                var remaining = balance.TotalDays - balance.UsedDays;
                if (daysUsed > remaining)
                    return Result.Failure($"「{leaveType.Name}」剩餘 {remaining} 天，不足以請 {daysUsed} 天");
            }
            else if (leaveType.DaysPerYear > 0)
            {
                // 沒有餘額紀錄但有年度上限，建立一筆
                balance = new LeaveBalance
                {
                    EmployeeId = dto.EmployeeId,
                    LeaveTypeId = dto.LeaveTypeId,
                    Year = year,
                    TotalDays = leaveType.DaysPerYear,
                    UsedDays = 0,
                    RemainingDays = leaveType.DaysPerYear
                };
                _db.LeaveBalances.Add(balance);
                await _db.SaveChangesAsync();

                if (daysUsed > leaveType.DaysPerYear)
                    return Result.Failure($"「{leaveType.Name}」年度額度 {leaveType.DaysPerYear} 天，不足以請 {daysUsed} 天");
            }

            // 新增請假申請
            var leaveRequest = new LeaveRequest
            {
                EmployeeId = dto.EmployeeId,
                LeaveTypeId = dto.LeaveTypeId,
                StartDate = dto.StartDate,
                EndDate = dto.EndDate,
                DaysUsed = daysUsed,
                Reason = dto.Reason,
                LeaveDelegateId = dto.LeaveDelegateId,
                Status = "Pending",
                CreatedAt = DateTime.Now
            };

            await _repo.AddAsync(leaveRequest);

            // 更新餘額
            if (balance != null)
            {
                balance.UsedDays += daysUsed;
                balance.RemainingDays = balance.TotalDays - balance.UsedDays;
                await _db.SaveChangesAsync();
            }

            return Result.Success(null);
        }

        // ========== 代理人設定 ==========

        public async Task<WorkDelegateViewModel> GetWorkDelegateViewModelAsync(int employeeId)
        {
            var employee = await _db.Employees
                .Include(e => e.User)
                .Include(e => e.WorkDelegate).ThenInclude(d => d.User)
                .FirstOrDefaultAsync(e => e.Id == employeeId);

            if (employee == null) return null;

            var colleagues = await _db.Employees
                .Include(e => e.User)
                .Where(e => e.DepartmentId == employee.DepartmentId && e.Id != employeeId && e.IsActive)
                .ToListAsync();

            return new WorkDelegateViewModel
            {
                EmployeeId = employee.Id,
                EmployeeName = employee.User?.UserName,
                CurrentDelegateName = employee.WorkDelegate?.User?.UserName,
                CurrentDelegateId = employee.WorkDelegateId,
                DelegateOptions = new List<SelectListItem>
                {
                    new SelectListItem { Value = "", Text = "-- 請選擇 --" }
                }.Concat(colleagues.Select(c => new SelectListItem
                {
                    Value = c.Id.ToString(),
                    Text = c.User?.UserName
                })).ToList()
            };
        }

        public async Task<Result> SetWorkDelegateAsync(int employeeId, int delegateId)
        {
            if (employeeId == delegateId)
                return Result.Failure("代理人不可為自己");

            var employee = await _db.Employees.FindAsync(employeeId);
            if (employee == null)
                return Result.Failure("找不到員工資料");

            var delegateEmployee = await _db.Employees.FindAsync(delegateId);
            if (delegateEmployee == null)
                return Result.Failure("找不到代理人資料");

            employee.WorkDelegateId = delegateId;
            await _db.SaveChangesAsync();

            return Result.Success(null);
        }

        public async Task<Result> RemoveWorkDelegateAsync(int employeeId)
        {
            var employee = await _db.Employees.FindAsync(employeeId);
            if (employee == null)
                return Result.Failure("找不到員工資料");

            employee.WorkDelegateId = null;
            await _db.SaveChangesAsync();

            return Result.Success(null);
        }

        // ========== 工具方法 ==========

        private static decimal CalculateBusinessDays(DateTime start, DateTime end)
        {
            decimal count = 0;
            for (var date = start.Date; date <= end.Date; date = date.AddDays(1))
            {
                if (date.DayOfWeek != DayOfWeek.Saturday && date.DayOfWeek != DayOfWeek.Sunday)
                    count++;
            }
            return count;
        }
    }
}
