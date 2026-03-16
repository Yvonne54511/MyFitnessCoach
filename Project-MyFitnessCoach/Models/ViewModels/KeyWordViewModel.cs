using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class KeyWordViewModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "請輸入關鍵字詞")]
        [StringLength(50, ErrorMessage = "字詞長度不能超過 50 個字")]
        [Display(Name = "關鍵字詞")]
        public string Word { get; set; }

        [Display(Name = "字詞種類")]
        public int Category { get; set; }

        [Display(Name = "權重")]
        public int Weight { get; set; }
    }
}