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

        public int TotalScore { get; set; }

        // 情感分析計數 (混合模型)
        public int PositiveCount { get; set; }
        public int NeutralCount { get; set; }
        public int NegativeCount { get; set; }

        // 詳細評論列表 (情感分析用)
        public System.Collections.Generic.List<ReviewSentimentDto> PositiveReviews { get; set; } = new();
        public System.Collections.Generic.List<ReviewSentimentDto> NeutralReviews { get; set; } = new();
        public System.Collections.Generic.List<ReviewSentimentDto> NegativeReviews { get; set; } = new();
    }
}
