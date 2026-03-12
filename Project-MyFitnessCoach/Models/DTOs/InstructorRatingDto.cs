namespace Project_MyFitnessCoach.Models.DTOs
{
    public class InstructorRatingDto
    {
        public int InstructorId { get; set; }
        public string InstructorName { get; set; }
        public string ImageUrl { get; set; }
        public double AverageRating { get; set; }
        public int TotalReviews { get; set; }
        public int Star5Count { get; set; }
        public int Star4Count { get; set; }
        public int Star3Count { get; set; }
        public int Star2Count { get; set; }
        public int Star1Count { get; set; }
    }
}
