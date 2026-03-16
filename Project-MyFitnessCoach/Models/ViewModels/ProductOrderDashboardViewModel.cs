using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class ProductOrderDashboardViewModel
    {
        [Display(Name = "本月總訂單")]
        public int TotalOrdersThisMonth { get; set; }
        public double TotalOrdersChangePercentage { get; set; }

        [Display(Name = "待出貨訂單")]
        public int PendingShipmentCount { get; set; }
        public double PendingShipmentChangePercentage { get; set; }

        [Display(Name = "爭議中訂單")]
        public int DisputedCount { get; set; }
        public double DisputedChangePercentage { get; set; }

        [Display(Name = "待處理訂單")]
        public int PendingActionCount => PendingShipmentCount + DisputedCount;

        // 訂單趨勢數據
        public List<OrderTrendViewModel> OrderTrends { get; set; } = new List<OrderTrendViewModel>();

        // 城市分布數據
        public List<CityDistributionViewModel> CityDistributions { get; set; } = new List<CityDistributionViewModel>();

        // 商品類別排行數據
        public List<CategoryRankingViewModel> CategoryRankings { get; set; } = new List<CategoryRankingViewModel>();
    }

    public class OrderTrendViewModel
    {
        public string Date { get; set; }
        public int Count { get; set; }
    }

    public class CityDistributionViewModel
    {
        public string City { get; set; }
        public int Count { get; set; }
    }

    public class CategoryRankingViewModel
    {
        public string CategoryName { get; set; }
        public int TotalSold { get; set; }
    }
}
