using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Repositories;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Services
{
    public interface IDashboardService
    {
        DashboardSummaryViewModel GetSummary(int year, int month);
        IEnumerable<InstructorRatingDto> GetInstructorRatings(int year, int month);
        GlobalRatingDto GetGlobalRating(int year, int month);
        IEnumerable<KeyWordFrequencyDto> GetKeyWordFrequencies(int year, int month);
    }

    public class DashboardService : IDashboardService
    {
        private readonly IDashboardRepository _dashboardRepository;

        public DashboardService(IDashboardRepository dashboardRepository)
        {
            _dashboardRepository = dashboardRepository;
        }

        public DashboardSummaryViewModel GetSummary(int year, int month)
        {
            return new DashboardSummaryViewModel
            {
                TotalUsers = _dashboardRepository.GetTotalUsers(),
                ActiveUsers = _dashboardRepository.GetActiveUsers(),
                PendingUsers = _dashboardRepository.GetPendingUsers(),
                ActiveRoles = _dashboardRepository.GetActiveRoles(),
                ActiveFunctions = _dashboardRepository.GetActiveFunctions(),
                ActiveInstructors = _dashboardRepository.GetActiveInstructors(),
                
                MonthlyOrdersCount = _dashboardRepository.GetMonthlyOrdersCount(year, month),
                MonthlyRevenue = _dashboardRepository.GetMonthlyRevenue(year, month),
                MonthlyReviewsCount = _dashboardRepository.GetMonthlyReviewsCount(year, month),
                MonthlyActiveMembers = _dashboardRepository.GetMonthlyActiveMembers(year, month),

                YearlyOrdersCount = _dashboardRepository.GetMonthlyOrdersCount(year, 0),
                YearlyRevenue = _dashboardRepository.GetMonthlyRevenue(year, 0),
                YearlyReviewsCount = _dashboardRepository.GetMonthlyReviewsCount(year, 0),
                YearlyActiveMembers = _dashboardRepository.GetMonthlyActiveMembers(year, 0),
                
                MonthlyRevenueTrend = _dashboardRepository.GetMonthlyRevenueTrendData(year),
                
                SelectedYear = year,
                SelectedMonth = month
            };
        }

        public IEnumerable<InstructorRatingDto> GetInstructorRatings(int year, int month)
        {
            return _dashboardRepository.GetInstructorRatings(year, month);
        }

        public GlobalRatingDto GetGlobalRating(int year, int month)
        {
            return _dashboardRepository.GetGlobalRating(year, month);
        }

        public IEnumerable<KeyWordFrequencyDto> GetKeyWordFrequencies(int year, int month)
        {
            return _dashboardRepository.GetKeyWordFrequencies(year, month);
        }
    }
}
