namespace Project_MyFitnessCoach.Models.DTOs
{
    public class KeyWordFrequencyDto
    {
        public string Word { get; set; }
        public int Count { get; set; }
        public int? Category { get; set; } // 1: 正向, -1: 負向, null: 未分類
        public bool IsUncategorized => !Category.HasValue;
    }
}