using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class TopUpPlanViewModel
    {
        [Display(Name = "方案編號")]
        public int Id { get; set; }

        [Display(Name = "方案名稱")]
        [Required(ErrorMessage = "{0} 是必填欄位")]
        [StringLength(50)]
        public string PlanName { get; set; }

        [Display(Name = "圖片")]
        public string ImageUrl { get; set; }

        [Display(Name = "上傳圖片")]
        public Microsoft.AspNetCore.Http.IFormFile? ProductImage { get; set; }

        [Display(Name = "價格")]
        [Required(ErrorMessage = "{0} 是必填欄位")]
        public decimal? Price { get; set; }

        [Display(Name = "點數")]
        [Required(ErrorMessage = "{0} 是必填欄位")]
        public int? Points { get; set; }

        [Display(Name = "描述")]
        public string Description { get; set; }

        [Display(Name = "是否上架")]
        public bool IsActive { get; set; }

        [Display(Name = "排序")]
        public int? SortOrder { get; set; }
    }
}
