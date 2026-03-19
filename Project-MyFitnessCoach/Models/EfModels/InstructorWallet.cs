using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class InstructorWallet
{
    public int Id { get; set; }

    public int InstructorId { get; set; }

    public decimal CurrentBalance { get; set; }

    public DateTime LastUpdated { get; set; }

    public virtual Instructor Instructor { get; set; } = null!;

    public virtual ICollection<InstructorWalletDetail> InstructorWalletDetails { get; set; } = new List<InstructorWalletDetail>();
}
