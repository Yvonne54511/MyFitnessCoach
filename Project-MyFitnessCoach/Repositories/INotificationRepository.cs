using Project_MyFitnessCoach.Models.EfModels;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repositories
{
    public interface INotificationRepository
    {
        Task CreateAsync(Notification notification);
        Task<List<Notification>> GetByUserIdAsync(int userId);
        Task MarkAsReadAsync(int id);
        Task<int> GetUnreadCountAsync(int userId);
    }
}
