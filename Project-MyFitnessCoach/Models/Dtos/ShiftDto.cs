namespace Project_MyFitnessCoach.Models.Dtos
{
	public class ShiftDto
	{
		public int Id { get; set; }
		public int InstructorId { get; set; }
		public string InstructorName { get; set; }
		public DateOnly ScheduleDate { get; set; }
		public string TimeSlot { get; set; }
		public bool IsBooked { get; set; }
	}
}
