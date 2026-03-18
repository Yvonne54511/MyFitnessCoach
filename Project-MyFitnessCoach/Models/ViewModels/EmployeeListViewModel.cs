using Microsoft.AspNetCore.Mvc.Rendering;
using Project_MyFitnessCoach.Models.DTOs;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class EmployeeListViewModel
    {
        public string DepartmentFilter { get; set; }
        public string SearchKeyword { get; set; }
        public List<AdminEmployeeDto> Employees { get; set; } = new List<AdminEmployeeDto>();
        public List<SelectListItem> DepartmentOptions { get; set; } = new List<SelectListItem>();
    }
}
