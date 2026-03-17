using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
	public class LoginViewModel
	{
		[Display(Name = "帳號")]
		[Required(ErrorMessage = "請輸入{0}")]
		public string Account { get; set; }

		[Display(Name = "密碼")]
		[Required(ErrorMessage = "請輸入{0}")]
		[DataType(DataType.Password)]
		public string Password { get; set; }
	}
}
