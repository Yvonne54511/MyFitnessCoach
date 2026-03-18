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

        [Required(ErrorMessage = "請選擇開始時間")]
        [Display(Name = "開始時間")]
        public DateTime StartDate { get; set; }

        [Required(ErrorMessage = "請選擇結束時間")]
        [Display(Name = "結束時間")]
        public DateTime EndDate { get; set; }

        [Required(ErrorMessage = "請填寫請假原因")]
        [Display(Name = "請假原因")]
        [StringLength(500)]
        public string Reason { get; set; }

        [Display(Name = "請假小時數")]
        public decimal HoursUsed { get; set; }

        [Display(Name = "請假代理人")]
        public int? LeaveDelegateId { get; set; }

        // 步驟 4.3-2: 開始/結束小時（前端下拉選單用）
        public int StartHour { get; set; } = 9;
        public int EndHour { get; set; } = 18;

        // 唯讀帶入
        public string EmployeeName { get; set; }
        public string DepartmentName { get; set; }
        public string ManagerName { get; set; }

        // 代理人判斷（4.2-1）
        public int? DefaultDelegateId { get; set; }
        public bool DelegateOnLeave { get; set; }
        public string DelegateWarningMessage { get; set; }

        // 下拉選單
        public List<SelectListItem> LeaveTypeOptions { get; set; } = new List<SelectListItem>();
        public List<SelectListItem> DelegateOptions { get; set; } = new List<SelectListItem>();

        // 主管代審（步驟 5.2）
        public bool IsManager { get; set; }
        public int? ApprovingDelegateId { get; set; }
        public List<SelectListItem> SubordinateOptions { get; set; } = new List<SelectListItem>();

        // 假別餘額
        public List<LeaveBalanceDto> Balances { get; set; } = new List<LeaveBalanceDto>();

        // 步驟 4.3-2: 國定假日清單（前端 JS 計算用）
        public List<string> Holidays { get; set; } = new List<string>();
    }
}
