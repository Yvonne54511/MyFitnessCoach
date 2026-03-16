using System;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public class AverageTicketSizeDto
    {
        public decimal TotalRevenue { get; set; }
        public int TotalOrderCount { get; set; }
        public decimal AverageTicketSize { get; set; }
        public DateTime CalculationDate { get; set; }
    }
}
