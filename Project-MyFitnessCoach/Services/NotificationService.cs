using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.Enums;
using Project_MyFitnessCoach.Repositories;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public class NotificationService : INotificationService
    {
        private readonly INotificationRepository _repo;

        public NotificationService(INotificationRepository repo)
        {
            _repo = repo;
        }

        public async Task SendAsync(int receiverId, int? senderId, NotifyType type, string message, string url = null)
        {
            string title = "";
            string typeName = type.ToString();

            switch (type)
            {
                case NotifyType.Report1:
                    title = "評論檢舉通知";
                    break;
                case NotifyType.Booking:
                    title = "預約成功通知";
                    break;
                case NotifyType.System:
                    title = "系統通知";
                    break;
                case NotifyType.Alert:
                    title = "緊急提醒";
                    break;
                default:
                    title = "通知";
                    break;
            }

            // 由於資料庫無 Url 欄位，若有 URL，我們將其附加在 Content 結尾，格式為 [Url:...]
            // 這樣 Service 讀取時可以用字串處理來抓取 ReviewId
            string finalContent = message;
            if (!string.IsNullOrEmpty(url))
            {
                finalContent += $" [Url:{url}]";
            }

            var notification = new Notification
            {
                UserId = receiverId, // 改回 UserId
                SenderId = senderId,
                Title = title,
                Content = finalContent, // 改回 Content
                NotifyType = typeName,
                IsRead = false,
                CreatedAt = DateTime.Now
            };

            await _repo.CreateAsync(notification);
        }

        public async Task<List<Notification>> GetUserNotificationsAsync(int userId)
        {
            return await _repo.GetByUserIdAsync(userId);
        }

        public async Task MarkAsReadAsync(int id)
        {
            await _repo.MarkAsReadAsync(id);
        }

        public async Task<int> GetUnreadCountAsync(int userId)
        {
            return await _repo.GetUnreadCountAsync(userId);
        }
    }
}
