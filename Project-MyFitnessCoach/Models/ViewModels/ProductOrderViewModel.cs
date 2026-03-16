using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class ProductOrderViewModel
    {
        [Display(Name = "訂單編號")]
        public int Id { get; set; }

        public int MemberId { get; set; }

        [Display(Name = "會員姓名")]
        public string MemberName { get; set; }

        [Display(Name = "訂購日期")]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd HH:mm}")]
        public DateTime CreateAt { get; set; }

        [Display(Name = "原始金額")]
        [DisplayFormat(DataFormatString = "{0:C0}")]
        public decimal OriginalAmount { get; set; }

        [Display(Name = "折扣金額")]
        [DisplayFormat(DataFormatString = "{0:C0}")]
        public decimal DiscountAmount { get; set; }

        [Display(Name = "總金額")]
        [DisplayFormat(DataFormatString = "{0:C0}")]
        public decimal TotalAmount => OriginalAmount - DiscountAmount;

        [Display(Name = "收件人")]
        public string Receiver { get; set; }

        [Display(Name = "配送地址")]
        public string Address { get; set; }

        [Display(Name = "聯絡電話")]
        public string Mobile { get; set; }

        [Display(Name = "統一編號")]
        public string TaxNumber { get; set; }

        [Display(Name = "訂單狀態")]
        public int Status { get; set; }

        public string StatusName => Status switch
        {
            0 => "待處理",
            1 => "已出貨",
            2 => "已送達",
            3 => "已取消",
            4 => "申請退貨",
            5 => "退貨申請中",
            _ => "未知狀態"
        };

        [Display(Name = "備註")]
        public string Memo { get; set; }

        public List<ProductOrderDetailViewModel> OrderDetails { get; set; } = new List<ProductOrderDetailViewModel>();
    }

    public class ProductOrderDetailViewModel
    {
        public int Id { get; set; }
        public int ProductOrderId { get; set; }
        public int ProductId { get; set; }

        [Display(Name = "商品名稱")]
        public string ProductName { get; set; }

        [Display(Name = "單價")]
        [DisplayFormat(DataFormatString = "{0:C0}")]
        public decimal UnitPrice { get; set; }

        [Display(Name = "數量")]
        public int Qty { get; set; }

        [Display(Name = "小計")]
        [DisplayFormat(DataFormatString = "{0:C0}")]
        public decimal SubTotal { get; set; }

        [Display(Name = "折扣後價格")]
        [DisplayFormat(DataFormatString = "{0:C0}")]
        public decimal DiscountedPrice { get; set; }

        public string ImageUrl { get; set; }

        [Display(Name = "備註")]
        public string Memo { get; set; }
    }
}
