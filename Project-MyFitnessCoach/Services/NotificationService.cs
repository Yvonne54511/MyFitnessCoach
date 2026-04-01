using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.Enums;
using Project_MyFitnessCoach.Repositories;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public class NotificationService
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
                case NotifyType.Salary:
                    title = "薪資入帳通知";
                    break;
                default:
                    title = "通知";
                    break;
            }

            string finalContent = message;
            if (!string.IsNullOrEmpty(url))
            {
                finalContent += $" [Url:{url}]";
            }

            var notification = new Notification
            {
                UserId = receiverId,
                SenderId = senderId,
                Title = title,
                Content = finalContent,
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
