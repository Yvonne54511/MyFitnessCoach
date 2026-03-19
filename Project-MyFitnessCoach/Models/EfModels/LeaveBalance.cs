using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class LeaveBalance
{
    public int Id { get; set; }

    public int EmployeeId { get; set; }

    public int LeaveTypeId { get; set; }

    public int Year { get; set; }

    public decimal? TotalDays { get; set; }

    public decimal? UsedDays { get; set; }

    public decimal? RemainingDays { get; set; }

    public virtual Employee Employee { get; set; } = null!;

    public virtual ICollection<LeaveBalanceHistory> LeaveBalanceHistories { get; set; } = new List<LeaveBalanceHistory>();

    public virtual LeaveType LeaveType { get; set; } = null!;
}
