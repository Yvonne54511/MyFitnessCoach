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
        public int TotalSalary => HourWage * Shifts.Count;
    }

    public class SalaryShiftViewModel
    {
        public DateOnly Date { get; set; }
        public string TimeSlot { get; set; }
        public bool IsBooked { get; set; }
    }
}
