using Project_MyFitnessCoach.Models.DTOs;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class PendingReviewListViewModel
    {
        public int PendingCount { get; set; }
        public int NewLeaveCount { get; set; }
        public int CancelRequestCount { get; set; }
        public List<PendingReviewDto> Requests { get; set; } = new List<PendingReviewDto>();
        public string TypeFilter { get; set; }
    }
}
