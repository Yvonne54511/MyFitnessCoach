using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public class ReviewLeaveService
    {
        private readonly ILeaveRepository _repo;
        private readonly MyFitnessCoachDbContext _db;

        public ReviewLeaveService(ILeaveRepository repo, MyFitnessCoachDbContext db)
        {
            _repo = repo;
            _db = db;
        }

        // ========== 待我審核列表 ==========

        public async Task<PendingReviewListViewModel> GetPendingListAsync(int managerEmployeeId)
        {
            var requests = await _repo.GetPendingByManagerIdAsync(managerEmployeeId);

            var dtos = requests.Select(r => new PendingReviewDto
            {
                Id = r.Id,
                ApplicantName = r.Employee?.User?.UserName,
                DepartmentName = r.Employee?.Department?.Name,
                LeaveTypeName = r.LeaveType?.Name,
                StartDate = r.StartDate,
                EndDate = r.EndDate,
                HoursUsed = r.HoursUsed,
                DaysUsed = r.DaysUsed,
                Reason = r.Reason,
                DelegateName = r.LeaveDelegate?.User?.UserName,
                CreatedAt = r.CreatedAt,
                IsCancelRequest = r.Status == "CancelPending",
                OriginalStatus = r.OriginalStatus,
                CancelReason = r.CancelReason
            }).ToList();

            return new PendingReviewListViewModel
            {
                PendingCount = dtos.Count,
                NewLeaveCount = dtos.Count(d => !d.IsCancelRequest),
                CancelRequestCount = dtos.Count(d => d.IsCancelRequest),
                Requests = dtos
            };
        }

        // ========== 新假單審核 ==========

        public async Task<Result> ApproveAsync(int requestId, int approverEmployeeId)
        {
            var request = await _repo.GetByIdAsync(requestId);
            if (request == null)
                return Result.Failure("找不到此假單");

            if (request.Status != "Pending")
                return Result.Failure("此假單狀態無法核准");

            if (request.Employee?.ManagerId != approverEmployeeId)
                return Result.Failure("您不是此員工的主管，無權審核");

            request.Status = "Approved";
            request.ApprovedBy = approverEmployeeId;
            request.ApprovedAt = DateTime.Now;

            await _repo.UpdateAsync(request);

            return Result.Success(null);
        }

        public async Task<Result> RejectAsync(int requestId, int approverEmployeeId, string rejectReason)
        {
            if (string.IsNullOrWhiteSpace(rejectReason))
                return Result.Failure("駁回原因不可為空");

            var request = await _repo.GetByIdAsync(requestId);
            if (request == null)
                return Result.Failure("找不到此假單");

            if (request.Status != "Pending")
                return Result.Failure("此假單狀態無法駁回");

            if (request.Employee?.ManagerId != approverEmployeeId)
                return Result.Failure("您不是此員工的主管，無權審核");

            request.Status = "Rejected";
            request.ApprovedBy = approverEmployeeId;
            request.ApprovedAt = DateTime.Now;
            request.RejectReason = rejectReason;

            await _repo.UpdateAsync(request);

            // 退還餘額 + 寫入變動紀錄
            var year = request.StartDate.Year;
            var balance = await _db.LeaveBalances
                .FirstOrDefaultAsync(b => b.EmployeeId == request.EmployeeId
                    && b.LeaveTypeId == request.LeaveTypeId
                    && b.Year == year);

            if (balance != null)
            {
                var oldUsed = balance.UsedDays;
                balance.UsedDays -= request.DaysUsed;

                _db.LeaveBalanceHistories.Add(new LeaveBalanceHistory
                {
                    LeaveBalanceId = balance.Id,
                    ChangeType = "Reject",
                    ChangeDays = request.DaysUsed,
                    OldTotalDays = balance.TotalDays,
                    NewTotalDays = balance.TotalDays,
                    OldUsedDays = oldUsed,
                    NewUsedDays = balance.UsedDays,
                    Reason = $"假單駁回退還：{request.LeaveType?.Name ?? ""}",
                    OperatorId = approverEmployeeId,
                    CreatedAt = DateTime.Now
                });

                await _db.SaveChangesAsync();
            }

            return Result.Success(null);
        }

        // ========== 取消請假審核（步驟 4.2-3）==========

        public async Task<Result> ApproveCancelAsync(int requestId, int approverEmployeeId)
        {
            var request = await _repo.GetByIdAsync(requestId);
            if (request == null)
                return Result.Failure("找不到此假單");

            if (request.Status != "CancelPending")
                return Result.Failure("此假單不是取消審核中狀態");

            if (request.Employee?.ManagerId != approverEmployeeId)
                return Result.Failure("您不是此員工的主管，無權審核");

            request.Status = "Cancelled";
            request.ApprovedBy = approverEmployeeId;
            request.ApprovedAt = DateTime.Now;

            await _repo.UpdateAsync(request);

            // 退還餘額 + 寫入變動紀錄
            var year = request.StartDate.Year;
            var balance = await _db.LeaveBalances
                .FirstOrDefaultAsync(b => b.EmployeeId == request.EmployeeId
                    && b.LeaveTypeId == request.LeaveTypeId
                    && b.Year == year);

            if (balance != null)
            {
                var oldUsed = balance.UsedDays;
                balance.UsedDays -= request.DaysUsed;

                _db.LeaveBalanceHistories.Add(new LeaveBalanceHistory
                {
                    LeaveBalanceId = balance.Id,
                    ChangeType = "CancelApproved",
                    ChangeDays = request.DaysUsed,
                    OldTotalDays = balance.TotalDays,
                    NewTotalDays = balance.TotalDays,
                    OldUsedDays = oldUsed,
                    NewUsedDays = balance.UsedDays,
                    Reason = $"取消請假核准退還：{request.LeaveType?.Name ?? ""}",
                    OperatorId = approverEmployeeId,
                    CreatedAt = DateTime.Now
                });

                await _db.SaveChangesAsync();
            }

            return Result.Success(null);
        }

        public async Task<Result> RejectCancelAsync(int requestId, int approverEmployeeId, string rejectReason)
        {
            if (string.IsNullOrWhiteSpace(rejectReason))
                return Result.Failure("駁回原因不可為空");

            var request = await _repo.GetByIdAsync(requestId);
            if (request == null)
                return Result.Failure("找不到此假單");

            if (request.Status != "CancelPending")
                return Result.Failure("此假單不是取消審核中狀態");

            if (request.Employee?.ManagerId != approverEmployeeId)
                return Result.Failure("您不是此員工的主管，無權審核");

            // 恢復原狀態
            request.Status = request.OriginalStatus;
            request.OriginalStatus = null;
            request.CancelRequestedAt = null;
            request.CancelReason = null;
            request.RejectReason = rejectReason;

            await _repo.UpdateAsync(request);

            return Result.Success(null);
        }

        // ========== 取得單筆詳情（供 Detail 頁面使用）==========

        public async Task<LeaveRequestDto> GetDetailAsync(int requestId, int managerEmployeeId)
        {
            var r = await _repo.GetByIdAsync(requestId);
            if (r == null || r.Employee?.ManagerId != managerEmployeeId)
                return null;

            return new LeaveRequestDto
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
                CancelReason = r.CancelReason
            };
        }

        // ========== 部門請假總覽 ==========

        public async Task<DeptLeaveListViewModel> GetDeptOverviewAsync(
            int managerEmployeeId, string monthFilter, string employeeFilter, string statusFilter)
        {
            var manager = await _db.Employees
                .Include(e => e.Department)
                .FirstOrDefaultAsync(e => e.Id == managerEmployeeId);

            if (manager == null) return null;

            var departmentId = manager.DepartmentId;
            var requests = await _repo.GetByDepartmentAsync(departmentId);

            // 篩選
            if (!string.IsNullOrEmpty(monthFilter) && DateTime.TryParse(monthFilter + "-01", out var filterDate))
            {
                requests = requests.Where(r =>
                    r.StartDate.Year == filterDate.Year && r.StartDate.Month == filterDate.Month).ToList();
            }
            if (!string.IsNullOrEmpty(employeeFilter) && int.TryParse(employeeFilter, out var empFilterId))
            {
                requests = requests.Where(r => r.EmployeeId == empFilterId).ToList();
            }
            if (!string.IsNullOrEmpty(statusFilter))
            {
                requests = requests.Where(r => r.Status == statusFilter).ToList();
            }

            // 員工下拉選單
            var employees = await _db.Employees
                .Include(e => e.User)
                .Where(e => e.DepartmentId == departmentId && e.IsActive)
                .ToListAsync();

            var dtos = requests.Select(r => new DeptLeaveOverviewDto
            {
                Id = r.Id,
                EmployeeName = r.Employee?.User?.UserName,
                LeaveTypeName = r.LeaveType?.Name,
                StartDate = r.StartDate,
                EndDate = r.EndDate,
                HoursUsed = r.HoursUsed,
                DaysUsed = r.DaysUsed,
                Status = r.Status,
                DelegateName = r.LeaveDelegate?.User?.UserName
            }).ToList();

            return new DeptLeaveListViewModel
            {
                DepartmentName = manager.Department?.Name,
                MonthFilter = monthFilter,
                EmployeeFilter = employeeFilter,
                StatusFilter = statusFilter,
                TotalApplications = dtos.Count,
                TotalDays = dtos.Sum(d => d.DaysUsed),
                Requests = dtos,
                EmployeeOptions = new List<SelectListItem>
                {
                    new SelectListItem { Value = "", Text = "全部員工" }
                }.Concat(employees.Select(e => new SelectListItem
                {
                    Value = e.Id.ToString(),
                    Text = e.User?.UserName
                })).ToList()
            };
        }
    }
}
