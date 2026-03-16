using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class SalaryIndexViewModel
    {
        public List<SalaryInstructorViewModel> Instructors { get; set; } = new List<SalaryInstructorViewModel>();
        public SalaryRankingsViewModel Rankings { get; set; } = new SalaryRankingsViewModel();
    }

    public class SalaryRankingsViewModel
    {
        public List<RankingItemViewModel> TopBooked { get; set; } = new List<RankingItemViewModel>();
        public List<RankingItemViewModel> TopRated { get; set; } = new List<RankingItemViewModel>();
        public List<RankingItemViewModel> MostPositiveReviews { get; set; } = new List<RankingItemViewModel>();
    }

    public class RankingItemViewModel
    {
        public int InstructorId { get; set; }
        public string InstructorName { get; set; }
        public string Value { get; set; } // The metric value to display (e.g. "12次", "4.8分")
    }

    public class SalaryInstructorViewModel
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string ImageUrl { get; set; }
    }

    public class SalaryDetailViewModel
    {
        public int InstructorId { get; set; }
        public string InstructorName { get; set; }
        public int HourWage { get; set; }
        public int Year { get; set; }
        public int Month { get; set; }
        public List<SalaryShiftViewModel> Shifts { get; set; } = new List<SalaryShiftViewModel>();
        public int BaseSalary => HourWage * Shifts.Count;
        
        // 績效指標
        public int BookingCount { get; set; }
        public double AverageRating { get; set; }
        public int PositiveReviewCount { get; set; }
        
        // 分數計算 (預約次數未滿 15 次不予計分)
        public double IndividualTotalScore => BookingCount >= 15 
            ? (BookingCount * 0.5) + (AverageRating * 0.3) + (PositiveReviewCount * 0.4)
            : 0;
        public double GlobalTotalScore { get; set; }
        
        // 獎金池與建議獎金
        public double BonusPool { get; set; } = 0; 
        public double SuggestedBonus => GlobalTotalScore > 0 ? (IndividualTotalScore / GlobalTotalScore) * BonusPool : 0;
        
        public double BonusAmount { get; set; } // 實際發放獎金 (預設為 SuggestedBonus)
        public double FinalTotalSalary => BaseSalary + BonusAmount;
    }

    public class SalaryShiftViewModel
    {
        public DateOnly Date { get; set; }
        public string TimeSlot { get; set; }
        public bool IsBooked { get; set; }
    }
}
