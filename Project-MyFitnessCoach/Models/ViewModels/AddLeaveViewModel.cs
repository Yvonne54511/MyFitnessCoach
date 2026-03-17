using Microsoft.AspNetCore.Mvc.Rendering;
using Project_MyFitnessCoach.Models.DTOs;
using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class AddLeaveViewModel
    {
        [Required(ErrorMessage = "請選擇假別")]
        [Display(Name = "假別")]
        public int LeaveTypeId { get; set; }

        [Required(ErrorMessage = "請選擇開始日期")]
        [Display(Name = "開始日期")]
        [DataType(DataType.Date)]
        public DateTime StartDate { get; set; }

        [Required(ErrorMessage = "請選擇結束日期")]
        [Display(Name = "結束日期")]
        [DataType(DataType.Date)]
        public DateTime EndDate { get; set; }

        [Required(ErrorMessage = "請填寫請假原因")]
        [Display(Name = "請假原因")]
        [StringLength(500)]
        public string Reason { get; set; }

        [Display(Name = "請假代理人")]
        public int? LeaveDelegateId { get; set; }

        // 唯讀帶入
        public string EmployeeName { get; set; }
        public string DepartmentName { get; set; }
        public string ManagerName { get; set; }

        // 下拉選單
        public List<SelectListItem> LeaveTypeOptions { get; set; } = new List<SelectListItem>();
        public List<SelectListItem> DelegateOptions { get; set; } = new List<SelectListItem>();

        // 假別餘額
        public List<LeaveBalanceDto> Balances { get; set; } = new List<LeaveBalanceDto>();
    }
}
