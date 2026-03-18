namespace Project_MyFitnessCoach.Models.DTOs
{
    public class AdminEmployeeDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string Account { get; set; }
        public string DepartmentName { get; set; }
        public string ManagerName { get; set; }
        public string WorkDelegateName { get; set; }
        public DateOnly HiredDate { get; set; }
        public bool IsActive { get; set; }
    }
}
