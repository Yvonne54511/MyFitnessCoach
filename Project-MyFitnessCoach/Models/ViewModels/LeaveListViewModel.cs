using Project_MyFitnessCoach.Models.DTOs;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class LeaveListViewModel
    {
        public LeaveStatsDto Stats { get; set; }
        public List<LeaveRequestDto> Requests { get; set; } = new List<LeaveRequestDto>();
        public string StatusFilter { get; set; }
        public string MonthFilter { get; set; }
    }
}
