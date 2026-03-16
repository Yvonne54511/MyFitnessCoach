using Project_MyFitnessCoach.Models.DTOs;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class InstructorRatingViewModel
    {
        public IEnumerable<InstructorRatingDto> InstructorRatings { get; set; }
        public IEnumerable<InstructorRatingDto> YearlyInstructorRatings { get; set; }
        public GlobalRatingDto GlobalRating { get; set; }
        public int SelectedYear { get; set; }
        public int SelectedMonth { get; set; }
    }
}
