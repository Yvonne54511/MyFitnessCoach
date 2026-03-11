using System;

namespace Project_MyFitnessCoach.Models.EfModels
{
    public partial class Notification
    {
        public int Id { get; set; }
        public int UserId { get; set; } // 改回 UserId
        public int? SenderId { get; set; }
        public string Title { get; set; }
        public string Content { get; set; } // 改回 Content
        public string NotifyType { get; set; }
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; }
        
        // 移除 Url 欄位，因為資料庫中無此欄位
    }
}
