using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class ProductOrder
{
    public int Id { get; set; }

    public int MemberId { get; set; }

    public DateTime CreateAt { get; set; }

    public decimal OriginalAmount { get; set; }

    public decimal DiscountAmount { get; set; }

    public string Receiver { get; set; } = null!;

    public string Address { get; set; } = null!;

    public string Mobile { get; set; } = null!;

    public int? TaxNumber { get; set; }

    public int Status { get; set; }

    public string? Memo { get; set; }

    public virtual Member Member { get; set; } = null!;

    public virtual ICollection<ProductOrderDetail> ProductOrderDetails { get; set; } = new List<ProductOrderDetail>();
}
