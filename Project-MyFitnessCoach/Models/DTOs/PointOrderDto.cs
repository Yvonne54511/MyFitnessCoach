using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public class PointOrderDto
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public string MemberName { get; set; }
        public DateTime CreateAt { get; set; }
        public int PointQty { get; set; }
        public decimal OriginalPrice { get; set; }
        public decimal DiscountedPrice { get; set; }
        public int Status { get; set; } // 0: 待付款, 1: 已完成, 2: 爭議中, 3: 已取消
        public List<PointsRecordDetailDto> RecordDetails { get; set; }
    }
}
