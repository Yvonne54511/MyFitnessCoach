using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class ReservationViewModel
    {
        public int Id { get; set; }
        public string InstructorName { get; set; }
        public string MemberName { get; set; }
        public DateOnly ScheduleDate { get; set; }
        public string TimeSlot { get; set; }
        public string? Target { get; set; }

        [Display(Name = "課程備忘錄")]
        [StringLength(100, ErrorMessage = "備註最多只能輸入 100 個字")]
        public string? Memorandum { get; set; }
    }
}
