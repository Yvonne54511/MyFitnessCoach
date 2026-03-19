using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class ProductOrderDetail
{
    public int Id { get; set; }

    public int ProductOrderId { get; set; }

    public int ProductId { get; set; }

    public decimal UnitPrice { get; set; }

    public int Qty { get; set; }

    public decimal SubTotal { get; set; }

    public decimal DiscountedPrice { get; set; }

    public string ProductName { get; set; } = null!;

    public string? ImageUrl { get; set; }

    public string? Memo { get; set; }

    public virtual Product Product { get; set; } = null!;

    public virtual ProductOrder ProductOrder { get; set; } = null!;
}
