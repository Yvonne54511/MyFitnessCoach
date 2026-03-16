using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class PointOrderViewModel
    {
        [Display(Name = "儲值編號")]
        public int Id { get; set; }

        public int MemberId { get; set; }

        public int TopUpPlanId { get; set; }

        [Display(Name = "會員姓名")]
        public string MemberName { get; set; }

        [Display(Name = "儲值日期")]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd HH:mm}")]
        public DateTime CreateAt { get; set; }

        [Display(Name = "獲得點數")]
        [DisplayFormat(DataFormatString = "{0:N0}")]
        public int PointQty { get; set; }

        [Display(Name = "原始價格")]
        [DisplayFormat(DataFormatString = "{0:C0}")]
        public decimal OriginalPrice { get; set; }

        [Display(Name = "實付金額")]
        [DisplayFormat(DataFormatString = "{0:C0}")]
        public decimal DiscountedPrice { get; set; }

        [Display(Name = "狀態")]
        public int Status { get; set; }

        public string StatusName => Status switch
        {
            0 => "待付款",
            1 => "已完成",
            2 => "爭議中",
            3 => "已取消",
            _ => "未知狀態"
        };

        public List<PointsRecordDetailViewModel> RecordDetails { get; set; } = new List<PointsRecordDetailViewModel>();
    }

    public class PointsRecordDetailViewModel
    {
        public int Id { get; set; }
        public int PointOrderId { get; set; }
        public int UserWalletId { get; set; }

        [Display(Name = "紀錄時間")]
        public DateTime CreateAt { get; set; }

        [Display(Name = "異動點數")]
        public int PointAmount { get; set; }

        [Display(Name = "類別")]
        public string MerchandiseCategory { get; set; }

        public int? ReserveOrderId { get; set; }
    }
}
