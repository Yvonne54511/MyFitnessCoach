using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public class AdminLeaveService
    {
        private readonly IAdminLeaveRepository _repo;
        private readonly MyFitnessCoachDbContext _db;

        public AdminLeaveService(IAdminLeaveRepository repo, MyFitnessCoachDbContext db)
        {
            _repo = repo;
            _db = db;
        }

        public async Task<AdminLeaveListViewModel> GetAllRequestsAsync(
            string? deptFilter, string? statusFilter, string? monthFilter, string? keyword)
        {
            var requests = await _repo.GetAllAsync(deptFilter, statusFilter, monthFilter, keyword);
            var stats = await _repo.GetStatsAsync(monthFilter);

            // 部門下拉選單
            var departments = await _db.Departments
                .OrderBy(d => d.Name)
                .ToListAsync();

            var dtos = requests.Select(r => new AdminLeaveListItemDto
            {
                Id = r.Id,
                ApplicantName = r.Employee?.User?.UserName,
                DepartmentName = r.Employee?.Department?.Name,
                LeaveTypeName = r.LeaveType?.Name,
                StartDate = r.StartDate,
                EndDate = r.EndDate,
                HoursUsed = r.HoursUsed ?? 0,
                DaysUsed = r.DaysUsed ?? 0,
                Status = r.Status,
                ApproverName = r.ApprovedByNavigation?.User?.UserName
            }).ToList();

            return new AdminLeaveListViewModel
            {
                Stats = stats,
                DepartmentFilter = deptFilter,
                StatusFilter = statusFilter,
                MonthFilter = monthFilter,
                SearchKeyword = keyword,
                Requests = dtos,
                DepartmentOptions = new List<SelectListItem>
                {
                    new SelectListItem { Value = "", Text = "全部部門" }
                }.Concat(departments.Select(d => new SelectListItem
                {
                    Value = d.Id.ToString(),
                    Text = d.Name
                })).ToList()
            };
        }

        public async Task<LeaveRequestDto> GetDetailAsync(int id)
        {
            var r = await _repo.GetByIdAsync(id);
            if (r == null) return null;

            return new LeaveRequestDto
            {
                Id = r.Id,
                EmployeeId = r.EmployeeId,
                EmployeeName = r.Employee?.User?.UserName,
                DepartmentName = r.Employee?.Department?.Name,
                LeaveTypeName = r.LeaveType?.Name,
                StartDate = r.StartDate,
                EndDate = r.EndDate,
                HoursUsed = r.HoursUsed ?? 0,
                DaysUsed = r.DaysUsed ?? 0,
                Reason = r.Reason,
                DelegateName = r.LeaveDelegate?.User?.UserName,
                Status = r.Status,
                CreatedAt = r.CreatedAt,
                ApproverName = r.ApprovedByNavigation?.User?.UserName,
                ApprovedAt = r.ApprovedAt,
                RejectReason = r.RejectReason,
                OriginalStatus = r.OriginalStatus,
                CancelRequestedAt = r.CancelRequestedAt,
                CancelReason = r.CancelReason
            };
        }

        // ========== 步驟 4.4：國定假日管理 ==========

        public async Task<HolidayListViewModel> GetHolidayListAsync(int? year)
        {
            var targetYear = year ?? DateTime.Now.Year;

            var holidays = await _db.Holidays
                .Where(h => h.Year == targetYear)
                .OrderBy(h => h.HolidayDate)
                .Select(h => new HolidayItemDto
                {
                    Id = h.Id,
                    HolidayDate = h.HolidayDate.ToDateTime(TimeOnly.MinValue),
                    Name = h.Name,
                    Year = h.Year,
                    IsActive = h.IsActive
                })
                .ToListAsync();

            // 年份下拉選單（前一年 ~ 後兩年）
            var currentYear = DateTime.Now.Year;
            var yearOptions = Enumerable.Range(currentYear - 1, 4)
                .Select(y => new SelectListItem
                {
                    Value = y.ToString(),
                    Text = $"{y} 年",
                    Selected = y == targetYear
                })
                .ToList();

            return new HolidayListViewModel
            {
                YearFilter = targetYear,
                Holidays = holidays,
                YearOptions = yearOptions
            };
        }

        public async Task<HolidayEditViewModel> GetHolidayForEditAsync(int id)
        {
            var h = await _db.Holidays.FindAsync(id);
            if (h == null) return null;

            return new HolidayEditViewModel
            {
                Id = h.Id,
                HolidayDate = h.HolidayDate.ToDateTime(TimeOnly.MinValue),
                Name = h.Name,
                IsActive = h.IsActive
            };
        }

        public async Task<Result> CreateHolidayAsync(HolidayEditViewModel vm)
        {
            // 檢查重複日期
            var dateOnly = DateOnly.FromDateTime(vm.HolidayDate);
            var exists = await _db.Holidays.AnyAsync(h => h.HolidayDate == dateOnly);
            if (exists)
                return Result.Failure($"日期 {vm.HolidayDate:yyyy/MM/dd} 已存在，不可重複新增");

            var holiday = new Holiday
            {
                HolidayDate = dateOnly,
                Name = vm.Name,
                Year = vm.HolidayDate.Year,
                IsActive = vm.IsActive
            };

            _db.Holidays.Add(holiday);
            await _db.SaveChangesAsync();

            return Result.Success(null);
        }

        public async Task<Result> UpdateHolidayAsync(HolidayEditViewModel vm)
        {
            var holiday = await _db.Holidays.FindAsync(vm.Id);
            if (holiday == null)
                return Result.Failure("找不到此假日");

            // 檢查日期重複（排除自身）
            var dateOnly = DateOnly.FromDateTime(vm.HolidayDate);
            var exists = await _db.Holidays.AnyAsync(h => h.HolidayDate == dateOnly && h.Id != vm.Id);
            if (exists)
                return Result.Failure($"日期 {vm.HolidayDate:yyyy/MM/dd} 已被其他假日使用");

            holiday.HolidayDate = dateOnly;
            holiday.Name = vm.Name;
            holiday.Year = vm.HolidayDate.Year;
            holiday.IsActive = vm.IsActive;

            await _db.SaveChangesAsync();

            return Result.Success(null);
        }

        public async Task<Result> DeleteHolidayAsync(int id)
        {
            var holiday = await _db.Holidays.FindAsync(id);
            if (holiday == null)
                return Result.Failure("找不到此假日");

            _db.Holidays.Remove(holiday);
            await _db.SaveChangesAsync();

            return Result.Success(null);
        }

        // ========== 步驟 4.4：假別額度管理 ==========

        public async Task<BalanceListViewModel> GetBalanceListAsync(
            string deptFilter, string search, int? year)
        {
            var targetYear = year ?? DateTime.Now.Year;

            var departments = await _db.Departments.OrderBy(d => d.Name).ToListAsync();
            var leaveTypes = await _db.LeaveTypes.Where(lt => lt.IsActive).OrderBy(lt => lt.Id).ToListAsync();

            // 查詢所有啟用員工
            var empQuery = _db.Employees
                .Include(e => e.User)
                .Include(e => e.Department)
                .Where(e => e.IsActive);

            if (!string.IsNullOrEmpty(deptFilter) && int.TryParse(deptFilter, out var deptId))
                empQuery = empQuery.Where(e => e.DepartmentId == deptId);
            if (!string.IsNullOrEmpty(search))
                empQuery = empQuery.Where(e => e.User.UserName.Contains(search));

            var employees = await empQuery.OrderBy(e => e.DepartmentId).ThenBy(e => e.Id).ToListAsync();

            // 查詢所有餘額
            var balances = await _db.LeaveBalances
                .Where(b => b.Year == targetYear)
                .ToListAsync();

            var items = new List<BalanceListItemDto>();
            foreach (var emp in employees)
            {
                foreach (var lt in leaveTypes)
                {
                    var b = balances.FirstOrDefault(x => x.EmployeeId == emp.Id && x.LeaveTypeId == lt.Id);
                    items.Add(new BalanceListItemDto
                    {
                        EmployeeId = emp.Id,
                        EmployeeName = emp.User?.UserName,
                        DepartmentName = emp.Department?.Name,
                        LeaveTypeId = lt.Id,
                        LeaveTypeName = lt.Name,
                        QuotaType = lt.QuotaType,
                        WarnThresholdDays = lt.WarnThresholdDays,
                        TotalDays = b?.TotalDays ?? (lt.QuotaType == "PreAllocated" ? lt.DaysPerYear : 0),
                        UsedDays = b?.UsedDays ?? 0,
                        RemainingDays = b != null
                            ? (b.RemainingDays ?? (b.TotalDays - b.UsedDays)) ?? 0
                            : (lt.QuotaType == "PreAllocated" ? lt.DaysPerYear : 0),
                        Year = targetYear,
                        BalanceId = b?.Id
                    });
                }
            }

            return new BalanceListViewModel
            {
                YearFilter = targetYear,
                DepartmentFilter = deptFilter,
                SearchKeyword = search,
                Items = items,
                DepartmentOptions = new List<SelectListItem>
                {
                    new SelectListItem { Value = "", Text = "全部部門" }
                }.Concat(departments.Select(d => new SelectListItem
                {
                    Value = d.Id.ToString(),
                    Text = d.Name
                })).ToList()
            };
        }

        public async Task<BalanceGrantViewModel> GetBalanceGrantViewModelAsync(
            int employeeId, int leaveTypeId, int year)
        {
            var emp = await _db.Employees
                .Include(e => e.User)
                .Include(e => e.Department)
                .FirstOrDefaultAsync(e => e.Id == employeeId);
            if (emp == null) return null;

            var lt = await _db.LeaveTypes.FindAsync(leaveTypeId);
            if (lt == null) return null;

            var balance = await _db.LeaveBalances
                .FirstOrDefaultAsync(b => b.EmployeeId == employeeId
                    && b.LeaveTypeId == leaveTypeId && b.Year == year);

            return new BalanceGrantViewModel
            {
                EmployeeId = employeeId,
                LeaveTypeId = leaveTypeId,
                Year = year,
                EmployeeName = emp.User?.UserName,
                DepartmentName = emp.Department?.Name,
                LeaveTypeName = lt.Name,
                CurrentTotalDays = balance?.TotalDays ?? 0,
                CurrentUsedDays = balance?.UsedDays ?? 0,
                CurrentRemainingDays = balance != null
                    ? (balance.RemainingDays ?? (balance.TotalDays - balance.UsedDays)) ?? 0
                    : 0
            };
        }

        public async Task<Result> GrantBalanceAsync(
            int employeeId, int leaveTypeId, int year, decimal grantDays, string reason, int operatorId)
        {
            if (grantDays <= 0)
                return Result.Failure("給假天數必須大於 0");

            var lt = await _db.LeaveTypes.FindAsync(leaveTypeId);
            if (lt == null)
                return Result.Failure("找不到此假別");

            var balance = await _db.LeaveBalances
                .FirstOrDefaultAsync(b => b.EmployeeId == employeeId
                    && b.LeaveTypeId == leaveTypeId && b.Year == year);

            decimal oldTotal = 0;
            decimal oldUsed = 0;

            if (balance == null)
            {
                balance = new LeaveBalance
                {
                    EmployeeId = employeeId,
                    LeaveTypeId = leaveTypeId,
                    Year = year,
                    TotalDays = grantDays,
                    UsedDays = 0
                };
                _db.LeaveBalances.Add(balance);
                await _db.SaveChangesAsync(); // 取得 Id
            }
            else
            {
                oldTotal = balance.TotalDays ?? 0;
                oldUsed = balance.UsedDays ?? 0;
                balance.TotalDays = (balance.TotalDays ?? 0) + grantDays;
            }

            // 寫入變動紀錄
            _db.LeaveBalanceHistories.Add(new LeaveBalanceHistory
            {
                LeaveBalanceId = balance.Id,
                ChangeType = "AdminGrant",
                ChangeDays = grantDays,
                OldTotalDays = oldTotal,
                NewTotalDays = balance.TotalDays ?? 0,
                OldUsedDays = oldUsed,
                NewUsedDays = balance.UsedDays ?? 0,
                Reason = reason,
                OperatorId = operatorId,
                CreatedAt = DateTime.Now
            });

            await _db.SaveChangesAsync();

            return Result.Success(null);
        }

        public async Task<BalanceHistoryViewModel> GetBalanceHistoryAsync(
            int employeeId, int? leaveTypeId, int? year)
        {
            var targetYear = year ?? DateTime.Now.Year;

            var emp = await _db.Employees
                .Include(e => e.User)
                .Include(e => e.Department)
                .FirstOrDefaultAsync(e => e.Id == employeeId);
            if (emp == null) return null;

            var leaveTypes = await _db.LeaveTypes.Where(lt => lt.IsActive).ToListAsync();

            var query = _db.LeaveBalanceHistories
                .Include(h => h.LeaveBalance).ThenInclude(b => b.LeaveType)
                .Include(h => h.Operator).ThenInclude(o => o.User)
                .Where(h => h.LeaveBalance.EmployeeId == employeeId
                    && h.LeaveBalance.Year == targetYear);

            if (leaveTypeId.HasValue)
                query = query.Where(h => h.LeaveBalance.LeaveTypeId == leaveTypeId.Value);

            var histories = await query
                .OrderByDescending(h => h.CreatedAt)
                .ToListAsync();

            var changeTypeMap = new Dictionary<string, string>
            {
                { "AdminGrant",     "管理員給假" },
                { "Apply",          "請假扣除" },
                { "Reject",         "駁回退還" },
                { "CancelApproved", "取消核准退還" }
            };

            var items = histories.Select(h => new BalanceHistoryItemDto
            {
                Id = h.Id,
                LeaveTypeName = h.LeaveBalance?.LeaveType?.Name,
                ChangeType = h.ChangeType,
                ChangeTypeDisplay = changeTypeMap.GetValueOrDefault(h.ChangeType, h.ChangeType),
                ChangeDays = h.ChangeDays,
                OldTotalDays = h.OldTotalDays,
                NewTotalDays = h.NewTotalDays,
                OldUsedDays = h.OldUsedDays,
                NewUsedDays = h.NewUsedDays,
                Reason = h.Reason,
                OperatorName = h.Operator?.User?.UserName,
                CreatedAt = h.CreatedAt
            }).ToList();

            return new BalanceHistoryViewModel
            {
                EmployeeId = employeeId,
                EmployeeName = emp.User?.UserName,
                DepartmentName = emp.Department?.Name,
                Year = targetYear,
                LeaveTypeFilter = leaveTypeId,
                Items = items,
                LeaveTypeOptions = new List<SelectListItem>
                {
                    new SelectListItem { Value = "", Text = "全部假別" }
                }.Concat(leaveTypes.Select(lt => new SelectListItem
                {
                    Value = lt.Id.ToString(),
                    Text = lt.Name
                })).ToList()
            };
        }
    }
}
