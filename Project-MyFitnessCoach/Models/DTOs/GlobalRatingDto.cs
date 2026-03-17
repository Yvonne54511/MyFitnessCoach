namespace Project_MyFitnessCoach.Models.DTOs
{
    public class GlobalRatingDto
    {
        public int TotalReviews { get; set; }
        public double AverageRating { get; set; }
        public int Star5Count { get; set; }
        public int Star4Count { get; set; }
        public int Star3Count { get; set; }
        public int Star2Count { get; set; }
        public int Star1Count { get; set; }
    }
}
