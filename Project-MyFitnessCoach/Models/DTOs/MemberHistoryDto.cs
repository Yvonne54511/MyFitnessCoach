using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.DTOs
{
    /// <summary>
    /// 單一會員身體數據歷史 DTO
    /// Service → Controller 回傳單一會員完整歷史資料
    /// </summary>
    public class MemberHistoryDto
    {
        // 會員基本資料
        public int MemberId { get; set; }
        public string MemberName { get; set; }
        public string Gender { get; set; }
        public double? Height { get; set; }
        public string Target { get; set; }
        public string ActivityLevel { get; set; }

        // 歷史量測記錄（降冪排序）
        public List<BodyRecordDto> Records { get; set; } = new();

        // 最新一筆數值
        public double? LatestWeight { get; set; }
        public double? LatestBodyFat { get; set; }
        public double? LatestSkeletalMuscle { get; set; }
        public double? LatestWaist { get; set; }

        // 與第一筆相比的變化量
        public double? WeightChange { get; set; }
        public double? BodyFatChange { get; set; }
        public double? SkeletalMuscleChange { get; set; }
        public double? WaistChange { get; set; }

        // Chart.js 圖表資料（升冪排序）
        public List<string> Dates { get; set; } = new();
        public List<double> Weights { get; set; } = new();
        public List<double?> BodyFats { get; set; } = new();
        public List<double?> SkeletalMuscles { get; set; } = new();
        public List<double?> Waists { get; set; } = new();
    }
}
