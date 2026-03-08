using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModel
{
    public class ForgetPasswordViewModel
    {
        [Display(Name = "電子信箱")]
        [Required(ErrorMessage = "{0}為必填")]
        [EmailAddress(ErrorMessage = "請輸入正確的電子信箱格式")]
        [StringLength(200, ErrorMessage = "{0}長度不可超過{1}個字元")]
        public string Email { get; set; } = string.Empty;
    }
}
