using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModel
{
    public class ResetPasswordViewModel
    {
        [Required]
        public string Code { get; set; } = string.Empty;

        [Display(Name = "新密碼")]
        [Required(ErrorMessage = "{0}為必填")]
        [DataType(DataType.Password)]
        [StringLength(12, MinimumLength = 6, ErrorMessage = "密碼長度必須在{2}到{1}個字元之間")]
        public string Password { get; set; } = string.Empty;

        [Display(Name = "確認新密碼")]
        [Required(ErrorMessage = "{0}為必填")]
        [DataType(DataType.Password)]
        [Compare(nameof(Password), ErrorMessage = "確認密碼與新密碼不一致")]
        public string ConfirmPassword { get; set; } = string.Empty;
    }
}
