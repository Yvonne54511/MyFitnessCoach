using System;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public class MemberViolationDto
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public string MemberName { get; set; } // Added for display
        public string MemberEmail { get; set; } // Added for display
        public int WarningCount { get; set; }
        public bool IsSuspended { get; set; }
        public DateTime? LastWarningAt { get; set; }
        public DateTime? SuspendedAt { get; set; }
        public string? Reason { get; set; }
    }
}