namespace Project_MyFitnessCoach.Models.DTOs
{
    public class LeaveBalanceDto
    {
        public string LeaveTypeName { get; set; }
        public decimal TotalDays { get; set; }
        public decimal UsedDays { get; set; }
        public decimal RemainingDays { get; set; }

        // 步驟 4.3-1 新增
        public string QuotaType { get; set; }
        public int? WarnThresholdDays { get; set; }
    }
}
