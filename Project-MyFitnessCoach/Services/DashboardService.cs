using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Repositories;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Services
{
    public interface IDashboardService
    {
        DashboardSummaryViewModel GetSummary();
        IEnumerable<InstructorRatingDto> GetInstructorRatings();
        GlobalRatingDto GetGlobalRating();
        IEnumerable<KeyWordFrequencyDto> GetKeyWordFrequencies();
    }

    public class DashboardService : IDashboardService
    {
        private readonly IDashboardRepository _dashboardRepository;

        public DashboardService(IDashboardRepository dashboardRepository)
        {
            _dashboardRepository = dashboardRepository;
        }

        public DashboardSummaryViewModel GetSummary()
        {
            return new DashboardSummaryViewModel
            {
                TotalUsers = _dashboardRepository.GetTotalUsers(),
                ActiveUsers = _dashboardRepository.GetActiveUsers(),
                PendingUsers = _dashboardRepository.GetPendingUsers(),
                ActiveRoles = _dashboardRepository.GetActiveRoles(),
                ActiveFunctions = _dashboardRepository.GetActiveFunctions(),
                ActiveInstructors = _dashboardRepository.GetActiveInstructors()
            };
        }

        public IEnumerable<InstructorRatingDto> GetInstructorRatings()
        {
            return _dashboardRepository.GetInstructorRatings();
        }

        public GlobalRatingDto GetGlobalRating()
        {
            return _dashboardRepository.GetGlobalRating();
        }

        public IEnumerable<KeyWordFrequencyDto> GetKeyWordFrequencies()
        {
            return _dashboardRepository.GetKeyWordFrequencies();
        }
    }
}
