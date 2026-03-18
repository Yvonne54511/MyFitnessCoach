#nullable disable
using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class LeaveType
{
    public int Id { get; set; }

    public string Name { get; set; }

    public int DaysPerYear { get; set; }

    public bool CarryOver { get; set; }

    public bool RequiresDoc { get; set; }

    public bool IsActive { get; set; }

    /// <summary>
    /// PreAllocated(特休) | Unlimited(病假/事假/公假) | ApprovalRequired(婚假/喪假)
    /// </summary>
    public string QuotaType { get; set; } = "PreAllocated";

    /// <summary>
    /// 法定天數警示門檻（病假=30, 事假=14, 其他=null）
    /// </summary>
    public int? WarnThresholdDays { get; set; }

    public virtual ICollection<LeaveRequest> LeaveRequests { get; set; } = new List<LeaveRequest>();

    public virtual ICollection<LeaveBalance> LeaveBalances { get; set; } = new List<LeaveBalance>();
}
