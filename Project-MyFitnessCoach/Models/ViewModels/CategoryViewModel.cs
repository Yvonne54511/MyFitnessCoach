using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class CategoryViewModel
    {
        [Display(Name = "編號")]
        public int Id { get; set; }

        [Display(Name = "類別名稱")]
        [Required(ErrorMessage = "{0} 是必填欄位")]
        [StringLength(50)]
        public string CategoryName { get; set; }

        [Display(Name = "排序")]
        [Required(ErrorMessage = "{0} 是必填欄位")]
        public int SortOrder { get; set; }

        [Display(Name = "是否啟用")]
        public bool IsActive { get; set; }
    }
}
