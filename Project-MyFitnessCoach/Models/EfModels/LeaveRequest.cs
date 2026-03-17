#nullable disable
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

    public decimal DaysUsed { get; set; }

    public string Reason { get; set; }

    public string Status { get; set; }

    public int? LeaveDelegateId { get; set; }

    public int? ApprovedBy { get; set; }

    public DateTime? ApprovedAt { get; set; }

    public string RejectReason { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Employee Employee { get; set; }

    public virtual LeaveType LeaveType { get; set; }

    public virtual Employee LeaveDelegate { get; set; }

    public virtual Employee Approver { get; set; }

    public virtual ICollection<LeaveAttachment> Attachments { get; set; } = new List<LeaveAttachment>();
}
