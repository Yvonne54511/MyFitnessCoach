namespace Project_MyFitnessCoach.Models.ViewModel
{
    public class DashboardSummaryViewModel
    {
        // Monthly Stats (Selected Month)
        public int MonthlyOrdersCount { get; set; }
        public decimal MonthlyRevenue { get; set; }
        public int MonthlyReviewsCount { get; set; }
        public int MonthlyActiveMembers { get; set; }

        // Yearly Stats (Selected Year)
        public int YearlyOrdersCount { get; set; }
        public decimal YearlyRevenue { get; set; }
        public int YearlyReviewsCount { get; set; }
        public int YearlyActiveMembers { get; set; }

        // Monthly Trend (Current Year)
        public decimal[] MonthlyRevenueTrend { get; set; }

        // Global Stats (Contextual)
        public int TotalUsers { get; set; }
        public int ActiveUsers { get; set; }
        public int PendingUsers { get; set; }
        public int ActiveRoles { get; set; }
        public int ActiveFunctions { get; set; }
        public int ActiveInstructors { get; set; }

        // Selection Context
        public int SelectedYear { get; set; }
        public int SelectedMonth { get; set; }
    }
}
