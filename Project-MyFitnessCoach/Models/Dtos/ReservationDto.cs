using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public class ReservationDto
    {
        public int Id { get; set; } // ?™è£¡?šå¸¸å°æ? ShiftId
        public int InstructorId { get; set; }
        public string InstructorName { get; set; }
        public DateOnly ScheduleDate { get; set; }
        public string TimeSlot { get; set; }
        public bool IsBooked { get; set; }
        public int? MemberId { get; set; }
        public string? MemberName { get; set; }
        public string? Target { get; set; }
        
        [StringLength(100, ErrorMessage = "?™è¨»?€å¤šåª?½è¼¸??100 ?‹å?")]
        public string? Memorandum { get; set; }
    }
}
