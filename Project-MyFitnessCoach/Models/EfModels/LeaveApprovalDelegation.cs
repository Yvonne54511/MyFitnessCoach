#nullable disable
using System;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class LeaveApprovalDelegation
{
    public int Id { get; set; }

    public int ManagerEmployeeId { get; set; }

    public int DelegateEmployeeId { get; set; }

    public int LeaveRequestId { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Employee ManagerEmployee { get; set; }

    public virtual Employee DelegateEmployee { get; set; }

    public virtual LeaveRequest LeaveRequest { get; set; }
}
