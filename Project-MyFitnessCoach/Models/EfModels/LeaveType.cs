using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class LeaveType
{
    public int Id { get; set; }

    public string Name { get; set; } = null!;

    public int DaysPerYear { get; set; }

    public bool CarryOver { get; set; }

    public bool RequiresDoc { get; set; }

    public bool IsActive { get; set; }

    public string QuotaType { get; set; } = null!;

    public int? WarnThresholdDays { get; set; }

    public virtual ICollection<LeaveBalance> LeaveBalances { get; set; } = new List<LeaveBalance>();

    public virtual ICollection<LeaveRequest> LeaveRequests { get; set; } = new List<LeaveRequest>();
}
