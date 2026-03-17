using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class BodyDataViewModel
    {
        public IEnumerable<BodyRecordRowDto> Records { get; set; } = new List<BodyRecordRowDto>();

        // 搜尋條件
        public string SearchName { get; set; }
        public string DateFrom { get; set; }
        public string DateTo { get; set; }

        // 統計摘要
        public int TotalRecords { get; set; }
        public int TotalMembers { get; set; }
        public double? AvgWeight { get; set; }
        public double? AvgBodyFat { get; set; }

        // 各會員趨勢資料 (key = MemberId)
        public Dictionary<int, MemberBodyTrendDto> MemberTrends { get; set; } = new();
    }

    public class BodyRecordRowDto
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

    public class MemberHistoryViewModel
    {
        public int MemberId { get; set; }
        public string MemberName { get; set; }
        public string Gender { get; set; }
        public double? Height { get; set; }
        public string Target { get; set; }
        public string ActivityLevel { get; set; }

        public List<BodyRecordRowDto> Records { get; set; } = new();

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

        // 圖表資料
        public List<string> Dates { get; set; } = new();
        public List<double> Weights { get; set; } = new();
        public List<double?> BodyFats { get; set; } = new();
        public List<double?> SkeletalMuscles { get; set; } = new();
        public List<double?> Waists { get; set; } = new();
    }

    public class MemberBodyTrendDto
    {
        public int MemberId { get; set; }
        public string MemberName { get; set; }
        public List<string> Dates { get; set; } = new();
        public List<double> Weights { get; set; } = new();
        public List<double?> BodyFats { get; set; } = new();
        public List<double?> SkeletalMuscles { get; set; } = new();
    }
}
