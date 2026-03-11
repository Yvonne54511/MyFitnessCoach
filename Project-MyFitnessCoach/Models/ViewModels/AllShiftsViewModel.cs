namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class AllShiftsViewModel
    {
        public int Id { get; set; }
        public string InstructorName { get; set; }
        public DateOnly ScheduleDate { get; set; }
        public string TimeSlot { get; set; }
        public bool IsBooked { get; set; }
    }
}
