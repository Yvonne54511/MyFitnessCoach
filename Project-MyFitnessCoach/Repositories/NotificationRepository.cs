using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repositories
{
    public interface INotificationRepository
    {
        Task CreateAsync(Notification notification);
        Task<List<Notification>> GetByUserIdAsync(int userId);
        Task MarkAsReadAsync(int id);
        Task MarkAllAsReadAsync(int userId);
        Task<int> GetUnreadCountAsync(int userId);
    }

    public class NotificationRepository : INotificationRepository
    {
        private readonly MyFitnessCoachDbContext _db;

        public NotificationRepository(MyFitnessCoachDbContext db)
        {
            _db = db;
        }

        public async Task CreateAsync(Notification notification)
        {
            _db.Notifications.Add(notification);
            await _db.SaveChangesAsync();
        }

        public async Task<List<Notification>> GetByUserIdAsync(int userId)
        {
            return await _db.Notifications
                .Where(n => n.UserId == userId)
                .OrderByDescending(n => n.CreatedAt)
                .ToListAsync();
        }

        public async Task MarkAsReadAsync(int id)
        {
            var notification = await _db.Notifications.FindAsync(id);
            if (notification != null)
            {
                notification.IsRead = true;
                await _db.SaveChangesAsync();
            }
        }

        public async Task MarkAllAsReadAsync(int userId)
        {
            var notifications = await _db.Notifications
                .Where(n => n.UserId == userId && !n.IsRead)
                .ToListAsync();

            foreach (var n in notifications)
            {
                n.IsRead = true;
            }

            await _db.SaveChangesAsync();
        }

        public async Task<int> GetUnreadCountAsync(int userId)
        {
            return await _db.Notifications
                .CountAsync(n => n.UserId == userId && !n.IsRead);
        }
    }
}
