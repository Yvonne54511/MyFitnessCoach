namespace Project_MyFitnessCoach.Models.DTOs
{
    public class LeaveBalanceDto
    {
        public string LeaveTypeName { get; set; }
        public decimal TotalDays { get; set; }
        public decimal UsedDays { get; set; }
        public decimal RemainingDays { get; set; }
    }
}
