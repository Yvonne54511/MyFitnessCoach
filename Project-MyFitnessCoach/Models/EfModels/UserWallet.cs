using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class UserWallet
{
    public int Id { get; set; }

    public int MemberId { get; set; }

    public decimal CurrentBalance { get; set; }

    public DateTime LastUpdated { get; set; }

    public virtual Member Member { get; set; } = null!;

    public virtual ICollection<PointsRecordDetail> PointsRecordDetails { get; set; } = new List<PointsRecordDetail>();
}
