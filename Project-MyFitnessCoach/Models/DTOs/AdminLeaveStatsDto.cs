namespace Project_MyFitnessCoach.Models.DTOs
{
    public class AdminLeaveStatsDto
    {
        public decimal TotalThisMonth { get; set; }
        public int PendingCount { get; set; }
        public int ApprovedCount { get; set; }
        public int RejectedCount { get; set; }
        public int CancelPendingCount { get; set; }
    }
}
