using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class LeaveRequest
{
    public int Id { get; set; }

    public int EmployeeId { get; set; }

    public int LeaveTypeId { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public decimal? DaysUsed { get; set; }

    public string? Reason { get; set; }

    public string Status { get; set; } = null!;

    public int? LeaveDelegateId { get; set; }

    public int? ApprovedBy { get; set; }

    public DateTime? ApprovedAt { get; set; }

    public string? RejectReason { get; set; }

    public DateTime CreatedAt { get; set; }

    public decimal? HoursUsed { get; set; }

    public string? OriginalStatus { get; set; }

    public DateTime? CancelRequestedAt { get; set; }

    public string? CancelReason { get; set; }

    public virtual Employee? ApprovedByNavigation { get; set; }

    public virtual Employee Employee { get; set; } = null!;

    public virtual ICollection<LeaveApprovalDelegation> LeaveApprovalDelegations { get; set; } = new List<LeaveApprovalDelegation>();

    public virtual ICollection<LeaveAttachment> LeaveAttachments { get; set; } = new List<LeaveAttachment>();

    public virtual Employee? LeaveDelegate { get; set; }

    public virtual LeaveType LeaveType { get; set; } = null!;
}
