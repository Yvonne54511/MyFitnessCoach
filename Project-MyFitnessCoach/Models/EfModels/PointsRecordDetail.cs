using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class PointsRecordDetail
{
    public int Id { get; set; }

    public int PointOrderId { get; set; }

    public int UserWalletId { get; set; }

    public DateTime CreateAt { get; set; }

    public int PointAmount { get; set; }

    public string MerchandiseCategory { get; set; } = null!;

    public int? ReserveOrderId { get; set; }

    public virtual PointOrder PointOrder { get; set; } = null!;

    public virtual ReserveOrder? ReserveOrder { get; set; }

    public virtual UserWallet UserWallet { get; set; } = null!;
}
