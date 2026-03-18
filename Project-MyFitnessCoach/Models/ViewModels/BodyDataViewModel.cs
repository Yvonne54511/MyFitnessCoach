using Project_MyFitnessCoach.Models.DTOs;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    /// <summary>
    /// 客戶身體數據列表 ViewModel
    /// Controller 從 BodyDataResultDto 轉換後傳入 View
    /// </summary>
    public class BodyDataViewModel
    {
        public IEnumerable<BodyRecordDto> Records { get; set; } = new List<BodyRecordDto>();

        // 搜尋條件（保留供 View 顯示）
        public string SearchName { get; set; }
        public string DateFrom { get; set; }
        public string DateTo { get; set; }

        // 統計摘要
        public int TotalRecords { get; set; }
        public int TotalMembers { get; set; }
        public double? AvgWeight { get; set; }
        public double? AvgBodyFat { get; set; }

        // 各會員趨勢圖表資料 (key = MemberId)
        public Dictionary<int, MemberBodyTrendDto> MemberTrends { get; set; } = new();
    }

    /// <summary>
    /// 單一會員身體數據歷史 ViewModel
    /// Controller 從 MemberHistoryDto 轉換後傳入 View
    /// </summary>
    public class MemberHistoryViewModel
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
