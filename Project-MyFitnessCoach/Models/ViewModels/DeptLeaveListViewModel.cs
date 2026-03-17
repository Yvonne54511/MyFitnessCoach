using Microsoft.AspNetCore.Mvc.Rendering;
using Project_MyFitnessCoach.Models.DTOs;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class DeptLeaveListViewModel
    {
        public string DepartmentName { get; set; }
        public string MonthFilter { get; set; }
        public string EmployeeFilter { get; set; }
        public string StatusFilter { get; set; }
        public int TotalApplications { get; set; }
        public decimal TotalDays { get; set; }
        public List<DeptLeaveOverviewDto> Requests { get; set; } = new List<DeptLeaveOverviewDto>();
        public List<SelectListItem> EmployeeOptions { get; set; } = new List<SelectListItem>();
    }
}
