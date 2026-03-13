using System;

namespace Project_MyFitnessCoach.Models.Dtos
{
    public class ReviewDto
    {
        public int Id { get; set; }
        public int InstructorId { get; set; }
        public string InstructorName { get; set; }
        public int MemberId { get; set; }
        public string MemberName { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; }
        public string ReportMessage { get; set; } // 新增：檢舉內容
        public DateTime CreatedAt { get; set; }
        public bool IsUserActive { get; set; } // 用於判斷會員是否已被停權
    }
}
