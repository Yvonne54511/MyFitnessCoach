using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.DTOs
{
    /// <summary>
    /// 會員身體數據趨勢圖表 DTO
    /// 用於前端 Chart.js 圖表資料渲染
    /// </summary>
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
