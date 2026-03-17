namespace Project_MyFitnessCoach.Models.DTOs
{
    public class AddLeaveRequestDto
    {
        public int EmployeeId { get; set; }
        public int LeaveTypeId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal DaysUsed { get; set; }
        public string Reason { get; set; }
        public int? LeaveDelegateId { get; set; }
    }
}
