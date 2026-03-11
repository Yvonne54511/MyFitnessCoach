using Project_MyFitnessCoach.Models.EfModels;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IReviewRepository
    {
        Task<IEnumerable<Review>> GetAllReviewsAsync();
        Task<IEnumerable<Review>> GetReviewsByInstructorIdAsync(int instructorId);
        Task<Review?> GetReviewByIdAsync(int id);
        Task DeleteReviewAsync(int id);
        Task UpdateUserStatusAsync(int userId, bool isActive);
        Task<int?> GetUserIdByMemberIdAsync(int memberId);
    }
}
