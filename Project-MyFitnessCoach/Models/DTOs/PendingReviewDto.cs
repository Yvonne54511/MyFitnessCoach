namespace Project_MyFitnessCoach.Models.DTOs
{
    public class PendingReviewDto
    {
        public int Id { get; set; }
        public string ApplicantName { get; set; }
        public string DepartmentName { get; set; }
        public string LeaveTypeName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal HoursUsed { get; set; }
        public decimal DaysUsed { get; set; }
        public string Reason { get; set; }
        public string DelegateName { get; set; }
        public DateTime CreatedAt { get; set; }

        // 取消請求相關（步驟 4.2-3）
        public bool IsCancelRequest { get; set; }
        public string OriginalStatus { get; set; }
        public string CancelReason { get; set; }
    }
}
