namespace Project_MyFitnessCoach.Models.DTOs
{
	public class ShiftQueryCriteria
	{
		// 如果為 null，代表查詢「所有」講師 (Admin 模式)
		public int? InstructorId { get; set; }
        public string? InstructorName { get; set; }
		public DateOnly? StartDate { get; set; }
		public DateOnly? EndDate { get; set; }
        public bool? IsBooked { get; set; }
	}
}
