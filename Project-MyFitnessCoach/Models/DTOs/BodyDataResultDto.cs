using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.DTOs
{
    /// <summary>
    /// 身體數據列表查詢結果 DTO
    /// Service → Controller 回傳完整查詢結果（含統計摘要與趨勢資料）
    /// </summary>
    public class BodyDataResultDto
    {
        public List<BodyRecordDto> Records { get; set; } = new();

        // 查詢條件（回傳供 View 保留搜尋狀態）
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
}
