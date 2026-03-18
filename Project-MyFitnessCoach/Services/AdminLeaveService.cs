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
                HoursUsed = r.HoursUsed,
                DaysUsed = r.DaysUsed,
                Status = r.Status,
                ApproverName = r.Approver?.User?.UserName
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
    }
}
