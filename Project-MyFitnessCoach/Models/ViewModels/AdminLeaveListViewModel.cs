using Microsoft.AspNetCore.Mvc.Rendering;
using Project_MyFitnessCoach.Models.DTOs;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class AdminLeaveListViewModel
    {
        public AdminLeaveStatsDto Stats { get; set; }
        public string DepartmentFilter { get; set; }
        public string StatusFilter { get; set; }
        public string MonthFilter { get; set; }
        public string SearchKeyword { get; set; }
        public List<AdminLeaveListItemDto> Requests { get; set; } = new List<AdminLeaveListItemDto>();
        public List<SelectListItem> DepartmentOptions { get; set; } = new List<SelectListItem>();
    }
}
