using System;

namespace Project_MyFitnessCoach.Models.DTOs
{
    /// <summary>
    /// 單筆身體量測記錄 DTO
    /// Repository → Service → Controller 層間資料傳遞
    /// </summary>
    public class BodyRecordDto
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public string MemberName { get; set; }
        public string MemberTarget { get; set; }
        public double Weight { get; set; }
        public decimal? BodyFat { get; set; }
        public decimal? SkeletalMuscle { get; set; }
        public decimal? WaistCircumference { get; set; }
        public DateTime CreateAt { get; set; }
        public string Note { get; set; }
        public string ImageUrl { get; set; }
    }
}
