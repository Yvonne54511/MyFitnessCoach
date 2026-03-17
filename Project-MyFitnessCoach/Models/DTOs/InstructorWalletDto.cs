using System;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public class InstructorWalletDto
    {
        public int Id { get; set; }
        public int InstructorId { get; set; }
        public string InstructorName { get; set; }
        public decimal CurrentBalance { get; set; }
        public DateTime LastUpdated { get; set; }
    }
}
