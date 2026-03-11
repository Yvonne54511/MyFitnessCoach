namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class AllShiftsViewModel
    {
        public int Id { get; set; }
        public string InstructorName { get; set; }
        public DateOnly ScheduleDate { get; set; }
        public string TimeSlot { get; set; }
        public bool IsBooked { get; set; }
        public bool CanEdit { get; set; } // 新增：是否可編輯狀態
    }
}
