#nullable disable
using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class BalanceGrantViewModel
    {
        public int EmployeeId { get; set; }
        public int LeaveTypeId { get; set; }
        public int Year { get; set; }

        // 顯示用
        public string EmployeeName { get; set; }
        public string DepartmentName { get; set; }
        public string LeaveTypeName { get; set; }
        public decimal CurrentTotalDays { get; set; }
        public decimal CurrentUsedDays { get; set; }
        public decimal CurrentRemainingDays { get; set; }

        [Required(ErrorMessage = "給假天數為必填")]
        [Range(0.01, 365, ErrorMessage = "給假天數需大於 0")]
        [Display(Name = "給予天數")]
        public decimal GrantDays { get; set; }

        [Required(ErrorMessage = "原因為必填")]
        [MaxLength(300)]
        [Display(Name = "給假原因")]
        public string Reason { get; set; }
    }
}
