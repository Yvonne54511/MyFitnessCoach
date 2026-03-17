namespace Project_MyFitnessCoach.Models.DTOs
{
    public class LeaveRequestDto
    {
        public int Id { get; set; }
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string DepartmentName { get; set; }
        public string LeaveTypeName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal DaysUsed { get; set; }
        public string Reason { get; set; }
        public string DelegateName { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public string ApproverName { get; set; }
        public DateTime? ApprovedAt { get; set; }
        public string RejectReason { get; set; }
    }
}
