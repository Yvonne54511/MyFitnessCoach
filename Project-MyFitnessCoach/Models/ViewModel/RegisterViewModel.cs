using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModel
{
    public class RegisterViewModel
    {
        [Display(Name = "帳號")]
        [Required(ErrorMessage = "{0}為必填")]
        [StringLength(50, ErrorMessage = "{0}長度不可超過{1}個字元")]
        public string Account { get; set; }

        [Display(Name = "密碼")]
        [Required(ErrorMessage = "{0}為必填")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "{0}長度必須在{2}到{1}個字元之間")]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        [Display(Name = "確認密碼")]
        [Required(ErrorMessage = "{0}為必填")]
        [Compare("Password", ErrorMessage = "密碼與確認密碼不一致")]
        [DataType(DataType.Password)]
        public string ConfirmPassword { get; set; }

        [Display(Name = "姓名")]
        [Required(ErrorMessage = "{0}為必填")]
        [StringLength(30, ErrorMessage = "{0}長度不可超過{1}個字元")]
        public string UserName { get; set; }

        [Display(Name = "電子郵件")]
        [Required(ErrorMessage = "{0}為必填")]
        [EmailAddress(ErrorMessage = "請輸入正確的電子郵件格式")]
        [StringLength(200, ErrorMessage = "{0}長度不可超過{1}個字元")]
        public string Email { get; set; }

        [Display(Name = "手機")]
        [Required(ErrorMessage = "{0}為必填")]
        [StringLength(10, ErrorMessage = "{0}長度不可超過{1}個字元")]
        [RegularExpression(@"^09\d{8}$", ErrorMessage = "手機格式不正確，請輸入09開頭的10位數字")]
        public string? Mobile { get; set; }
    }
}
