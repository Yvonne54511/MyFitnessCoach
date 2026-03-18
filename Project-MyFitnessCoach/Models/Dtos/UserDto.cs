namespace Project_MyFitnessCoach.Models.DTOs
{
	public class UserDto
	{
		public int Id { get; set; }
		public string Account { get; set; }
		public string UserName { get; set; }
		public string Email { get; set; }
		public string HashedPassword { get; set; }
        public string? Password { get; set; } // 保留相容性
        public int? InstructorId { get; set; }
        public int? EmployeeId { get; set; }
        public int? DepartmentId { get; set; }
        public List<string> Roles { get; set; } = new List<string>();
        public List<string> Functions { get; set; } = new List<string>();
	}
}
