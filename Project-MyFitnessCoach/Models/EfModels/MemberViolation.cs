using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class MemberViolation
{
    public int Id { get; set; }

    public int MemberId { get; set; }

    public int WarningCount { get; set; }

    public bool IsSuspended { get; set; }

    public DateTime? LastWarningAt { get; set; }

    public DateTime? SuspendedAt { get; set; }

    public string? Reason { get; set; }

    public virtual Member Member { get; set; } = null!;
}
