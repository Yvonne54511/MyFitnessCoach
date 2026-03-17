using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModel
{
	public class LoginViewModel
	{
		[Display(Name="帳號")]
		[Required(ErrorMessage ="{0}為必填")]
		[StringLength(50,ErrorMessage ="長度不可超過{1}個字元")]
		public string Account { get; set; }

		[Display(Name = "密碼")]
		[Required(ErrorMessage = "{0}為必填")]
        [DataType(DataType.Password)]
        [StringLength(12, MinimumLength = 6, ErrorMessage = "密碼長度必須在{2}到{1}個字元之間")]
		public string Password { get; set; }
	}
}
