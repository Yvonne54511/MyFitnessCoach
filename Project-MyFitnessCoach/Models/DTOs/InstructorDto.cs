namespace Project_MyFitnessCoach.Models.DTOs
{
    public class InstructorDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string ImageUrl { get; set; } = string.Empty;
        public string Description { get; set; }
        public int HourWage { get; set; }
        public int CancelCount { get; set; }
        public bool IsActive { get; set; }
        
        // 為了相容某些地方可能在使用舊屬性名稱
        public int InstructorId { get => Id; set => Id = value; }
        public string InstructorName { get => UserName; set => UserName = value; }
    }
}
