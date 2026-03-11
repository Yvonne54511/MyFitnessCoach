using Project_MyFitnessCoach.Models.Dtos;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public interface IReviewService
    {
        Task<IEnumerable<ReviewDto>> GetAdminReviewsAsync();
        Task<IEnumerable<ReviewDto>> GetInstructorReviewsAsync(int instructorId);
        Task DeleteReviewAsync(int id);
        Task SuspendMemberAsync(int memberId);
        Task ReportReviewAsync(int id);
    }
}
