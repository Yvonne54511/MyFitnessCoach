using Microsoft.AspNetCore.Mvc.Rendering;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class WorkDelegateViewModel
    {
        public int EmployeeId { get; set; }
        // 唯讀顯示（不參與表單提交，標記為 nullable 避免 ModelState 驗證失敗）
        public string? EmployeeName { get; set; }
        public string? CurrentDelegateName { get; set; }
        public int? CurrentDelegateId { get; set; }
        public int? NewDelegateId { get; set; }
        public List<SelectListItem> DelegateOptions { get; set; } = new List<SelectListItem>();
    }
}
