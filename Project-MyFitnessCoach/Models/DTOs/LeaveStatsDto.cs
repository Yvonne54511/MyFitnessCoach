namespace Project_MyFitnessCoach.Models.DTOs
{
    public class LeaveStatsDto
    {
        public decimal TotalDaysThisYear { get; set; }
        public int PendingCount { get; set; }
        public int ApprovedCount { get; set; }
        public int RejectedCount { get; set; }
    }
}
