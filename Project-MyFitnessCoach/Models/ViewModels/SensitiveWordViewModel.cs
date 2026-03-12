using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class SensitiveWordViewModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "請輸入敏感字詞")]
        [StringLength(50, ErrorMessage = "字詞長度不能超過 50 個字")]
        [Display(Name = "敏感字詞")]
        public string Word { get; set; }
    }
}
