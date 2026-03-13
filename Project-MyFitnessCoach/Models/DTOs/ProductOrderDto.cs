using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public class ProductOrderDto
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public string MemberName { get; set; } // Join from User.UserName
        public DateTime CreateAt { get; set; }
        public decimal OriginalAmount { get; set; }
        public decimal DiscountAmount { get; set; }
        public string Receiver { get; set; }
        public string Address { get; set; }
        public string Mobile { get; set; }
        public int? TaxNumber { get; set; }
        public int Status { get; set; }
        public string Memo { get; set; }
        public List<ProductOrderDetailDto> OrderDetails { get; set; } = new List<ProductOrderDetailDto>();
    }

    public class ProductOrderDetailDto
    {
        public int Id { get; set; }
        public int ProductOrderId { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public decimal UnitPrice { get; set; }
        public int Qty { get; set; }
        public decimal SubTotal { get; set; }
        public decimal DiscountedPrice { get; set; }
        public string ImageUrl { get; set; }
        public string Memo { get; set; }
    }
}
