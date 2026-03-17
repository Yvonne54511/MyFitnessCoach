using Microsoft.AspNetCore.Mvc.Rendering;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class WorkDelegateViewModel
    {
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string CurrentDelegateName { get; set; }
        public int? CurrentDelegateId { get; set; }
        public int? NewDelegateId { get; set; }
        public List<SelectListItem> DelegateOptions { get; set; } = new List<SelectListItem>();
    }
}
