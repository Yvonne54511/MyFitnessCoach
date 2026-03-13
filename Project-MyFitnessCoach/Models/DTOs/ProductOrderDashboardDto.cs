using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public class ProductOrderDashboardDto
    {
        public int TotalOrdersThisMonth { get; set; }
        public double TotalOrdersChangePercentage { get; set; }
        
        public int PendingShipmentCount { get; set; }
        public double PendingShipmentChangePercentage { get; set; }
        
        public int DisputedCount { get; set; }
        public double DisputedChangePercentage { get; set; }

        public List<OrderTrendDto> OrderTrends { get; set; }
        public List<CityDistributionDto> CityDistributions { get; set; }
    }

    public class OrderTrendDto
    {
        public string Date { get; set; }
        public int Count { get; set; }
    }

    public class CityDistributionDto
    {
        public string City { get; set; }
        public int Count { get; set; }
    }
}
