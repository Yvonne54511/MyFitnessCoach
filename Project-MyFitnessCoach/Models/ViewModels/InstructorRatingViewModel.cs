using Project_MyFitnessCoach.Models.DTOs;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class InstructorRatingViewModel
    {
        public IEnumerable<InstructorRatingDto> InstructorRatings { get; set; }
        public GlobalRatingDto GlobalRating { get; set; }
    }
}
