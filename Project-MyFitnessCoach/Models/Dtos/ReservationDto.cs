using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public class ReservationDto
    {
        public int Id { get; set; } // 這裡通常對應 ShiftId
        public int InstructorId { get; set; }
        public string InstructorName { get; set; }
        public DateOnly ScheduleDate { get; set; }
        public string TimeSlot { get; set; }
        public bool IsBooked { get; set; }
        public int? MemberId { get; set; }
        public string? MemberName { get; set; }
        public string? Target { get; set; }
        
        [StringLength(100, ErrorMessage = "備註最多只能輸入 100 個字")]
        public string? Memorandum { get; set; }
    }

}
