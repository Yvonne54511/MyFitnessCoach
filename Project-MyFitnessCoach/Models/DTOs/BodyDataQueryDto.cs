namespace Project_MyFitnessCoach.Models.DTOs
{
    /// <summary>
    /// 身體數據查詢條件 DTO
    /// Controller → Service 傳遞查詢參數
    /// </summary>
    public class BodyDataQueryDto
    {
        public string SearchName { get; set; }
        public string DateFrom { get; set; }
        public string DateTo { get; set; }
    }
}
