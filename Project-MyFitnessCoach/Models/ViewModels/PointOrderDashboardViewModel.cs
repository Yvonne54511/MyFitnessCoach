using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class PointOrderDashboardViewModel
    {
        [Display(Name = "今日營收")]
        [DisplayFormat(DataFormatString = "{0:C0}")]
        public decimal TodayRevenue { get; set; }

        [Display(Name = "營收趨勢")]
        public double RevenueTrend { get; set; }

        [Display(Name = "本月儲值總計")]
        [DisplayFormat(DataFormatString = "{0:C0}")]
        public decimal MonthTotal { get; set; }

        [Display(Name = "月營收比較")]
        public double MonthComparison { get; set; }

        [Display(Name = "總流通點數")]
        [DisplayFormat(DataFormatString = "{0:N0}")]
        public int TotalCirculatingPoints { get; set; }

        // 儲值趨勢圖表數據
        public List<string> TrendLabels { get; set; } = new List<string>();
        public List<decimal> ActualPaymentData { get; set; } = new List<decimal>();
        public List<int> BonusPointsData { get; set; } = new List<int>();

        // 熱門方案圖表數據
        public List<string> PlanNames { get; set; } = new List<string>();
        public List<int> PlanSales { get; set; } = new List<int>();
    }
}
