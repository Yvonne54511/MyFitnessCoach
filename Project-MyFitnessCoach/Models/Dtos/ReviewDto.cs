using System;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public class ReviewDto
    {
        public int Id { get; set; }
        public int InstructorId { get; set; }
        public string InstructorName { get; set; }
        public int MemberId { get; set; }
        public string MemberName { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; }
        public string ReportMessage { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsUserActive { get; set; } // Keep for backward compatibility if needed, but we'll use more specific ones
        public bool IsAccountActive { get; set; } // User.IsActive
        public bool IsSuspended { get; set; }     // MemberViolation.IsSuspended
        public bool IsBanned { get; set; }
        public int WarningCount { get; set; }
    }
}
