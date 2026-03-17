using System;
using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class MemberViolationIndexViewModel
    {
        public int Id { get; set; }

        [Display(Name = "會員姓名")]
        public string MemberName { get; set; }

        [Display(Name = "會員帳號")]
        public string MemberEmail { get; set; }

        [Display(Name = "警告次數")]
        public int WarningCount { get; set; }

        [Display(Name = "是否停權")]
        public bool IsSuspended { get; set; }

        [Display(Name = "最後警告時間")]
        public DateTime? LastWarningAt { get; set; }

        [Display(Name = "停權時間")]
        public DateTime? SuspendedAt { get; set; }

        [Display(Name = "原因")]
        public string? Reason { get; set; }
    }

    public class MemberViolationCreateEditViewModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "請選擇會員")]
        [Display(Name = "會員")]
        public int MemberId { get; set; }

        [Display(Name = "警告次數")]
        [Range(0, 100, ErrorMessage = "警告次數必須在 0 到 100 之間")]
        public int WarningCount { get; set; }

        [Display(Name = "是否停權")]
        public bool IsSuspended { get; set; }

        [Display(Name = "最後警告時間")]
        public DateTime? LastWarningAt { get; set; }

        [Display(Name = "停權時間")]
        public DateTime? SuspendedAt { get; set; }

        [Display(Name = "原因")]
        [StringLength(500, ErrorMessage = "原因不能超過 500 個字")]
        public string? Reason { get; set; }
        
        public string? MemberName { get; set; } // For display in Edit mode
    }
}