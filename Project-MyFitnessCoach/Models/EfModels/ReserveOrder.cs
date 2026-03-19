using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class ReserveOrder
{
    public int Id { get; set; }

    public int MemberId { get; set; }

    public int ShiftId { get; set; }

    public DateTime CreateAt { get; set; }

    public string Status { get; set; } = null!;

    public string PaymentMethod { get; set; } = null!;

    public string? Target { get; set; }

    public int? PointCost { get; set; }

    public decimal? Price { get; set; }

    public string? Memorandum { get; set; }

    public virtual Member Member { get; set; } = null!;

    public virtual ICollection<PointsRecordDetail> PointsRecordDetails { get; set; } = new List<PointsRecordDetail>();

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

    public virtual Shift Shift { get; set; } = null!;
}
