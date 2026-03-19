using Microsoft.AspNetCore.Mvc.Rendering;
using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class EmployeeEditViewModel
    {
        public int Id { get; set; }
        public int UserId { get; set; }

        [Required(ErrorMessage = "請選擇部門")]
        [Display(Name = "部門")]
        public int DepartmentId { get; set; }

        [Display(Name = "直屬主管")]
        public int? ManagerId { get; set; }

        [Display(Name = "職務代理人")]
        public int? WorkDelegateId { get; set; }

        [Display(Name = "啟用狀態")]
        public bool IsActive { get; set; }

        // 唯讀顯示（不參與表單提交，必須標記為 nullable 避免 ModelState 驗證失敗）
        public string? UserName { get; set; }
        public string? Account { get; set; }

        public List<SelectListItem> DepartmentOptions { get; set; } = new List<SelectListItem>();
        public List<SelectListItem> ManagerOptions { get; set; } = new List<SelectListItem>();
        public List<SelectListItem> DelegateOptions { get; set; } = new List<SelectListItem>();
    }
}
