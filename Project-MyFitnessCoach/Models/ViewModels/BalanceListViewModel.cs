#nullable disable
using Microsoft.AspNetCore.Mvc.Rendering;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class BalanceListViewModel
    {
        public int YearFilter { get; set; }
        public string DepartmentFilter { get; set; }
        public string SearchKeyword { get; set; }
        public List<BalanceListItemDto> Items { get; set; } = new List<BalanceListItemDto>();
        public List<SelectListItem> DepartmentOptions { get; set; } = new List<SelectListItem>();
    }

    public class BalanceListItemDto
    {
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string DepartmentName { get; set; }
        public int LeaveTypeId { get; set; }
        public string LeaveTypeName { get; set; }
        public string QuotaType { get; set; }
        public int? WarnThresholdDays { get; set; }
        public decimal TotalDays { get; set; }
        public decimal UsedDays { get; set; }
        public decimal RemainingDays { get; set; }
        public int Year { get; set; }
        public int? BalanceId { get; set; }
    }
}
