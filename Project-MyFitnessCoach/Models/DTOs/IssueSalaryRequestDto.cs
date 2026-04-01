namespace Project_MyFitnessCoach.Models.DTOs
{
	public class IssueSalaryRequest
	{
		public int InstructorId { get; set; }
		public string ReceiverEmail { get; set; }
		public decimal Amount { get; set; }
		public string Note { get; set; }
	}
}
