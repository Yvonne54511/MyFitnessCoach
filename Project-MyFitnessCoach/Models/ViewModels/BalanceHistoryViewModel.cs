#nullable disable
using Microsoft.AspNetCore.Mvc.Rendering;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class BalanceHistoryViewModel
    {
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string DepartmentName { get; set; }
        public int Year { get; set; }
        public int? LeaveTypeFilter { get; set; }
        public List<BalanceHistoryItemDto> Items { get; set; } = new List<BalanceHistoryItemDto>();
        public List<SelectListItem> LeaveTypeOptions { get; set; } = new List<SelectListItem>();
    }

    public class BalanceHistoryItemDto
    {
        public int Id { get; set; }
        public string LeaveTypeName { get; set; }
        public string ChangeType { get; set; }
        public string ChangeTypeDisplay { get; set; }
        public decimal ChangeDays { get; set; }
        public decimal OldTotalDays { get; set; }
        public decimal NewTotalDays { get; set; }
        public decimal OldUsedDays { get; set; }
        public decimal NewUsedDays { get; set; }
        public string Reason { get; set; }
        public string OperatorName { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
