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
                HoursUsed = r.HoursUsed,
                DaysUsed = r.DaysUsed,
                Reason = r.Reason,
                DelegateName = r.LeaveDelegate?.User?.UserName,
                Status = r.Status,
                CreatedAt = r.CreatedAt,
                ApproverName = r.Approver?.User?.UserName,
                ApprovedAt = r.ApprovedAt,
                RejectReason = r.RejectReason,
                OriginalStatus = r.OriginalStatus,
                CancelRequestedAt = r.CancelRequestedAt,
                CancelReason = r.CancelReason,
                CanCancel = (r.Status == "Pending" || r.Status == "Approved")
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
                .Include(e => e.WorkDelegate).ThenInclude(d => d.User)
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
                DefaultDelegateId = employee.WorkDelegateId,
                LeaveDelegateId = employee.WorkDelegateId,
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

            // 4.2-2: 以小時為單位，計算天數
            decimal hoursUsed = dto.HoursUsed;
            if (hoursUsed <= 0)
                return Result.Failure("請假小時數必須大於 0");

            decimal daysUsed = Math.Round(hoursUsed / 8.0m, 1);

            // 驗證小時數不超過日期區間工作日上限
            int maxBusinessDays = (int)CalculateBusinessDays(dto.StartDate, dto.EndDate);
            int maxHours = maxBusinessDays * 8;
            if (hoursUsed > maxHours)
                return Result.Failure($"請假小時數 ({hoursUsed}) 超出工作日上限 ({maxHours} 小時 / {maxBusinessDays} 天)");

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
                    return Result.Failure($"「{leaveType.Name}」剩餘 {remaining:N1} 天，不足以請 {daysUsed:N1} 天");
            }
            else if (leaveType.DaysPerYear > 0)
            {
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
                    return Result.Failure($"「{leaveType.Name}」年度額度 {leaveType.DaysPerYear} 天，不足以請 {daysUsed:N1} 天");
            }

            // 新增請假申請
            var leaveRequest = new LeaveRequest
            {
                EmployeeId = dto.EmployeeId,
                LeaveTypeId = dto.LeaveTypeId,
                StartDate = dto.StartDate,
                EndDate = dto.EndDate,
                HoursUsed = hoursUsed,
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

        // ========== 4.2-1 代理人請假判斷 ==========

        public async Task<List<SelectListItem>> GetAvailableDelegatesAsync(
            int employeeId, int departmentId, DateTime startDate, DateTime endDate)
        {
            var onLeaveIds = await _repo.GetEmployeeIdsOnLeaveAsync(departmentId, startDate, endDate);

            var colleagues = await _db.Employees
                .Include(e => e.User)
                .Where(e => e.DepartmentId == departmentId
                    && e.Id != employeeId
                    && e.IsActive
                    && !onLeaveIds.Contains(e.Id))
                .ToListAsync();

            return colleagues.Select(c => new SelectListItem
            {
                Value = c.Id.ToString(),
                Text = c.User?.UserName
            }).ToList();
        }

        public async Task<bool> CheckDelegateOnLeaveAsync(int delegateId, DateTime startDate, DateTime endDate)
        {
            return await _repo.HasOverlappingLeaveAsync(delegateId, startDate, endDate);
        }

        // ========== 4.2-3 取消請假 ==========

        public async Task<Result> RequestCancelAsync(int requestId, int employeeId, string cancelReason)
        {
            var request = await _repo.GetByIdAsync(requestId);
            if (request == null)
                return Result.Failure("找不到此假單");

            if (request.EmployeeId != employeeId)
                return Result.Failure("只能取消自己的假單");

            if (request.Status != "Pending" && request.Status != "Approved")
                return Result.Failure("此假單狀態無法取消");

            // 保存原狀態，供駁回時恢復
            request.OriginalStatus = request.Status;
            request.Status = "CancelPending";
            request.CancelRequestedAt = DateTime.Now;
            request.CancelReason = cancelReason;

            await _repo.UpdateAsync(request);

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
