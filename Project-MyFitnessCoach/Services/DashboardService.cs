using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public interface IDashboardService
    {
        DashboardSummaryViewModel GetSummary();
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
    }
}
