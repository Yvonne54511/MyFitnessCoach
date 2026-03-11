using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.Enums;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public interface INotificationService
    {
        // senderId 為空則代表系統發送
        Task SendAsync(int receiverId, int? senderId, NotifyType type, string message, string url = null);
        Task<List<Notification>> GetUserNotificationsAsync(int userId);
        Task MarkAsReadAsync(int id);
        Task<int> GetUnreadCountAsync(int userId);
    }
}
