namespace Project_MyFitnessCoach.Models.DTOs
{
    public class DeptLeaveOverviewDto
    {
        public int Id { get; set; }
        public string EmployeeName { get; set; }
        public string LeaveTypeName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal HoursUsed { get; set; }
        public decimal DaysUsed { get; set; }
        public string Status { get; set; }
        public string DelegateName { get; set; }
    }
}
