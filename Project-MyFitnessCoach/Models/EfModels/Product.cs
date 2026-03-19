using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class Product
{
    public int Id { get; set; }

    public int CategoryId { get; set; }

    public string Name { get; set; } = null!;

    public string? ImageUrl { get; set; }

    public decimal OriginalPrice { get; set; }

    public decimal UnitPrice { get; set; }

    public string? Description { get; set; }

    public int SortOrder { get; set; }

    public bool IsActive { get; set; }

    public virtual ProductCategory Category { get; set; } = null!;

    public virtual ICollection<ProductOrderDetail> ProductOrderDetails { get; set; } = new List<ProductOrderDetail>();
}
