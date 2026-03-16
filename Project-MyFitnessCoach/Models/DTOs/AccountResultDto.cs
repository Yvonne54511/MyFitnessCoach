namespace Project_MyFitnessCoach.Models.DTOs
{
	public class LoginDto
	{
		public string Account { get; set; }
		public string Password { get; set; }
	}
	public class AccountResultDto
    {
        public bool IsSuccess { get; set; }
        public string Message { get; set; }
    }

    public class LoginResultDto : AccountResultDto
    {
        public UserDto User { get; set; }
    }

    

    public class ResetPasswordRequestDto : AccountResultDto
    {
        public string Email { get; set; }
        public bool EmailSent { get; set; }
    }

    // 新增輸入用的 DTO
    public class ResetPasswordDto
    {
        public string Code { get; set; }
        public string Password { get; set; }
        public string ConfirmPassword { get; set; }
    }
}
