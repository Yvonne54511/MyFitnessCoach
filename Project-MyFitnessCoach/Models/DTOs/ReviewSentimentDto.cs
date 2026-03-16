namespace Project_MyFitnessCoach.Models.DTOs
{
    public class ReviewSentimentDto
    {
        public string Comment { get; set; }
        public int Rating { get; set; }
        public int CalculatedScore { get; set; }
        public string MemberName { get; set; }
        public System.DateTime CreatedAt { get; set; }
    }
}