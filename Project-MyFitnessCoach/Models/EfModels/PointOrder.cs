using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class PointOrder
{
    public int Id { get; set; }

    public int MemberId { get; set; }

    public int TopUpPlanId { get; set; }

    public DateTime CreateAt { get; set; }

    public int PointQty { get; set; }

    public decimal OriginalPrice { get; set; }

    public decimal DiscountedPrice { get; set; }

    public int Status { get; set; }

    public virtual Member Member { get; set; } = null!;

    public virtual ICollection<PointsRecordDetail> PointsRecordDetails { get; set; } = new List<PointsRecordDetail>();

    public virtual TopUpPlan TopUpPlan { get; set; } = null!;
}
