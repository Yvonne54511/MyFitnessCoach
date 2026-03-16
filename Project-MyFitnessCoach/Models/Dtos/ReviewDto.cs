using System;

namespace Project_MyFitnessCoach.Models.DTOs
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
        public string ReportMessage { get; set; } // ?°å?ï¼šæª¢?‰å…§å®?
        public DateTime CreatedAt { get; set; }
        public bool IsUserActive { get; set; } // ?¨æ–¼?¤æ–·?ƒå“¡?¯å¦å·²è¢«?œæ?
    }
}
