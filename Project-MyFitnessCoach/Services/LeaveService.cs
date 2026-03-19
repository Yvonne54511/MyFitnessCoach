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

            // 步驟 4.3-1: 為所有啟用假別產生餘額卡片
            var year = DateTime.Now.Year;
            var existingBalances = await _db.LeaveBalances
                .Include(b => b.LeaveType)
                .Where(b => b.EmployeeId == employeeId && b.Year == year)
                .ToListAsync();

            var balanceDtos = new List<LeaveBalanceDto>();
            foreach (var lt in leaveTypes)
            {
                var b = existingBalances.FirstOrDefault(x => x.LeaveTypeId == lt.Id);
                balanceDtos.Add(new LeaveBalanceDto
                {
                    LeaveTypeName = lt.Name,
                    QuotaType = lt.QuotaType,
                    WarnThresholdDays = lt.WarnThresholdDays,
                    TotalDays = b?.TotalDays ?? (lt.QuotaType == "PreAllocated" ? lt.DaysPerYear : 0),
                    UsedDays = b?.UsedDays ?? 0,
                    RemainingDays = b != null
                        ? (b.RemainingDays ?? (b.TotalDays - b.UsedDays)) ?? 0
                        : (lt.QuotaType == "PreAllocated" ? lt.DaysPerYear : 0)
                });
            }

            // 步驟 4.3-2: 載入國定假日清單
            var holidays = await _db.Holidays
                .Where(h => h.Year == year && h.IsActive)
                .Select(h => h.HolidayDate.ToString("yyyy-MM-dd"))
                .ToListAsync();

            // 步驟 5.2: 判斷是否為主管，載入直屬下屬清單
            var isManager = employee.ManagerId == null;
            var subordinateOptions = new List<SelectListItem>();
            if (isManager)
            {
                var subordinates = await _db.Employees
                    .Include(e => e.User)
                    .Where(e => e.ManagerId == employeeId && e.IsActive)
                    .ToListAsync();
                subordinateOptions = subordinates.Select(s => new SelectListItem
                {
                    Value = s.Id.ToString(),
                    Text = s.User?.UserName
                }).ToList();
            }

            return new AddLeaveViewModel
            {
                EmployeeName = employee.User?.UserName,
                DepartmentName = employee.Department?.Name,
                ManagerName = employee.Manager?.User?.UserName ?? "無",
                StartDate = DateTime.Today.AddHours(9),   // 預設 09:00
                EndDate = DateTime.Today.AddHours(18),     // 預設 18:00
                StartHour = 9,
                EndHour = 18,
                DefaultDelegateId = employee.WorkDelegateId,
                LeaveDelegateId = employee.WorkDelegateId,
                IsManager = isManager,
                SubordinateOptions = subordinateOptions,
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
                Balances = balanceDtos,
                Holidays = holidays
            };
        }

        public async Task<Result> ApplyAsync(AddLeaveRequestDto dto)
        {
            // 驗證時間
            if (dto.StartDate >= dto.EndDate)
                return Result.Failure("開始時間必須早於結束時間");

            // 步驟 4.3-2: 驗證整點
            if (dto.StartDate.Minute != 0 || dto.EndDate.Minute != 0)
                return Result.Failure("請假時間必須為整點");

            // 驗證小時範圍
            int startH = dto.StartDate.Hour;
            int endH = dto.EndDate.Hour;
            if (startH < 9 || startH > 17)
                return Result.Failure("開始時間小時需在 09:00 ~ 17:00 之間");
            if (dto.EndDate.TimeOfDay != TimeSpan.Zero) // 若 EndDate 非跨日的 00:00
            {
                if (endH < 10 || endH > 18)
                    return Result.Failure("結束時間小時需在 10:00 ~ 18:00 之間");
            }

            // 步驟 4.3-2: 後端自動計算請假時數（不信任前端）
            var holidays = await GetHolidaysAsync(dto.StartDate.Year);
            decimal hoursUsed = CalculateBusinessHours(dto.StartDate, dto.EndDate, holidays);
            if (hoursUsed < 1)
                return Result.Failure("請假時數不足 1 小時，請確認開始與結束時間");

            // 步驟 4.3: 精度 2 位小數
            decimal daysUsed = Math.Round(hoursUsed / 8.0m, 2);

            // 查詢假別
            var leaveType = await _db.LeaveTypes.FindAsync(dto.LeaveTypeId);
            if (leaveType == null)
                return Result.Failure("無效的假別");

            // 步驟 4.3-1: 依 QuotaType 分流驗證餘額
            var year = dto.StartDate.Year;
            var balance = await _db.LeaveBalances
                .FirstOrDefaultAsync(b => b.EmployeeId == dto.EmployeeId
                    && b.LeaveTypeId == dto.LeaveTypeId
                    && b.Year == year);

            switch (leaveType.QuotaType)
            {
                case "PreAllocated": // 特休
                    if (balance == null)
                    {
                        balance = new LeaveBalance
                        {
                            EmployeeId = dto.EmployeeId,
                            LeaveTypeId = dto.LeaveTypeId,
                            Year = year,
                            TotalDays = leaveType.DaysPerYear,
                            UsedDays = 0
                        };
                        _db.LeaveBalances.Add(balance);
                        await _db.SaveChangesAsync();
                    }
                    var remainingPre = (balance.TotalDays ?? 0) - (balance.UsedDays ?? 0);
                    if (daysUsed > remainingPre)
                        return Result.Failure($"「{leaveType.Name}」剩餘 {remainingPre:N2} 天，不足以請 {daysUsed:N2} 天");
                    break;

                case "Unlimited": // 病假、事假、公假
                    if (balance == null)
                    {
                        balance = new LeaveBalance
                        {
                            EmployeeId = dto.EmployeeId,
                            LeaveTypeId = dto.LeaveTypeId,
                            Year = year,
                            TotalDays = 0,
                            UsedDays = 0
                        };
                        _db.LeaveBalances.Add(balance);
                        await _db.SaveChangesAsync();
                    }
                    // 不做餘額上限檢查，僅追蹤使用量
                    break;

                case "ApprovalRequired": // 婚假、喪假
                    if (balance == null || balance.TotalDays <= 0)
                        return Result.Failure($"「{leaveType.Name}」尚未取得額度，請先提交證明文件並等待管理員核定");
                    var remainingAppr = (balance.TotalDays ?? 0) - (balance.UsedDays ?? 0);
                    if (daysUsed > remainingAppr)
                        return Result.Failure($"「{leaveType.Name}」剩餘 {remainingAppr:N2} 天，不足以請 {daysUsed:N2} 天");
                    break;

                default:
                    return Result.Failure("未知的假別額度類型");
            }

            // 步驟 5.2: 判斷主管身份
            var applicant = await _db.Employees.FindAsync(dto.EmployeeId);
            bool isManager = applicant?.ManagerId == null;

            // 主管必須指定代審人
            if (isManager)
            {
                if (dto.ApprovingDelegateId == null || dto.ApprovingDelegateId == 0)
                    return Result.Failure("主管請假必須指定代審人");

                var isSubordinate = await _db.Employees
                    .AnyAsync(e => e.Id == dto.ApprovingDelegateId && e.ManagerId == dto.EmployeeId && e.IsActive);
                if (!isSubordinate)
                    return Result.Failure("代審人必須為您的直屬下屬");
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
                Status = isManager ? "Approved" : "Pending",
                ApprovedBy = isManager ? dto.EmployeeId : null,
                ApprovedAt = isManager ? DateTime.Now : null,
                CreatedAt = DateTime.Now
            };

            await _repo.AddAsync(leaveRequest);

            // 主管假單：建立代審授權記錄
            if (isManager)
            {
                _db.LeaveApprovalDelegations.Add(new LeaveApprovalDelegation
                {
                    ManagerEmployeeId = dto.EmployeeId,
                    DelegateEmployeeId = dto.ApprovingDelegateId.Value,
                    LeaveRequestId = leaveRequest.Id,
                    StartDate = leaveRequest.StartDate,
                    EndDate = leaveRequest.EndDate,
                    IsActive = true,
                    CreatedAt = DateTime.Now
                });
                await _db.SaveChangesAsync();
            }

            // 更新餘額 + 寫入變動紀錄
            if (balance != null)
            {
                var oldUsed = balance.UsedDays ?? 0;
                balance.UsedDays = (balance.UsedDays ?? 0) + daysUsed;

                // 寫入 LeaveBalanceHistory
                _db.LeaveBalanceHistories.Add(new LeaveBalanceHistory
                {
                    LeaveBalanceId = balance.Id,
                    ChangeType = "Apply",
                    ChangeDays = -daysUsed,
                    OldTotalDays = balance.TotalDays ?? 0,
                    NewTotalDays = balance.TotalDays ?? 0,
                    OldUsedDays = oldUsed,
                    NewUsedDays = balance.UsedDays ?? 0,
                    Reason = $"請假申請：{leaveType.Name} {dto.StartDate:yyyy/MM/dd HH:mm}~{dto.EndDate:yyyy/MM/dd HH:mm}",
                    OperatorId = dto.EmployeeId,
                    CreatedAt = DateTime.Now
                });

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

            // 步驟 5.2: 主管假單（自動核准）取消時直接生效，不進 CancelPending
            bool isManager = request.Employee?.ManagerId == null;
            if (isManager && request.Status == "Approved")
            {
                request.Status = "Cancelled";
                request.CancelRequestedAt = DateTime.Now;
                request.CancelReason = cancelReason;
                await _repo.UpdateAsync(request);

                // 退還餘額
                var year = request.StartDate.Year;
                var balance = await _db.LeaveBalances
                    .FirstOrDefaultAsync(b => b.EmployeeId == request.EmployeeId
                        && b.LeaveTypeId == request.LeaveTypeId
                        && b.Year == year);
                if (balance != null)
                {
                    var oldUsed = balance.UsedDays ?? 0;
                    balance.UsedDays = (balance.UsedDays ?? 0) - (request.DaysUsed ?? 0);
                    _db.LeaveBalanceHistories.Add(new LeaveBalanceHistory
                    {
                        LeaveBalanceId = balance.Id,
                        ChangeType = "CancelApproved",
                        ChangeDays = request.DaysUsed ?? 0,
                        OldTotalDays = balance.TotalDays ?? 0,
                        NewTotalDays = balance.TotalDays ?? 0,
                        OldUsedDays = oldUsed,
                        NewUsedDays = balance.UsedDays ?? 0,
                        Reason = $"主管自行取消假單退還：{request.LeaveType?.Name ?? ""}",
                        OperatorId = employeeId,
                        CreatedAt = DateTime.Now
                    });
                }

                // 停用代審授權
                var delegation = await _db.LeaveApprovalDelegations
                    .FirstOrDefaultAsync(d => d.LeaveRequestId == requestId && d.IsActive);
                if (delegation != null)
                    delegation.IsActive = false;

                await _db.SaveChangesAsync();
                return Result.Success(null);
            }

            // 一般員工：保存原狀態，進入 CancelPending 流程
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

        /// <summary>
        /// 取得指定年度的國定假日集合
        /// </summary>
        public async Task<HashSet<DateTime>> GetHolidaysAsync(int year)
        {
            var dates = await _db.Holidays
                .Where(h => h.Year == year && h.IsActive)
                .Select(h => h.HolidayDate)
                .ToListAsync();
            return new HashSet<DateTime>(dates.Select(d => d.ToDateTime(TimeOnly.MinValue)));
        }

        /// <summary>
        /// 根據精確的開始/結束時間計算有效請假時數
        /// 工作時間：09:00~12:00 (3h) + 13:00~18:00 (5h) = 每天 8 小時
        /// 自動排除週末、午休時間、國定假日
        /// </summary>
        private decimal CalculateBusinessHours(DateTime start, DateTime end, HashSet<DateTime> holidays)
        {
            if (start >= end) return 0;

            decimal totalHours = 0;

            var morningStart = new TimeSpan(9, 0, 0);
            var morningEnd = new TimeSpan(12, 0, 0);
            var afternoonStart = new TimeSpan(13, 0, 0);
            var afternoonEnd = new TimeSpan(18, 0, 0);

            for (var date = start.Date; date <= end.Date; date = date.AddDays(1))
            {
                // 跳過週末
                if (date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday)
                    continue;

                // 跳過國定假日
                if (holidays.Contains(date))
                    continue;

                // 當天的實際起始/結束時間
                var dayStart = (date == start.Date) ? start.TimeOfDay : morningStart;
                var dayEnd = (date == end.Date) ? end.TimeOfDay : afternoonEnd;

                // 計算上午時段的重疊
                var amStart = Max(dayStart, morningStart);
                var amEnd = Min(dayEnd, morningEnd);
                if (amEnd > amStart)
                    totalHours += (decimal)(amEnd - amStart).TotalHours;

                // 計算下午時段的重疊
                var pmStart = Max(dayStart, afternoonStart);
                var pmEnd = Min(dayEnd, afternoonEnd);
                if (pmEnd > pmStart)
                    totalHours += (decimal)(pmEnd - pmStart).TotalHours;
            }

            return totalHours;
        }

        private static TimeSpan Max(TimeSpan a, TimeSpan b) => a > b ? a : b;
        private static TimeSpan Min(TimeSpan a, TimeSpan b) => a < b ? a : b;
    }
}
