#nullable disable
using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class Employee
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public int DepartmentId { get; set; }

    public int? ManagerId { get; set; }

    public int? WorkDelegateId { get; set; }

    public DateOnly HiredDate { get; set; }

    public bool IsActive { get; set; }

    public virtual User User { get; set; }

    public virtual Department Department { get; set; }

    public virtual Employee Manager { get; set; }

    public virtual Employee WorkDelegate { get; set; }

    public virtual ICollection<Employee> Subordinates { get; set; } = new List<Employee>();

    public virtual ICollection<Employee> DelegateOf { get; set; } = new List<Employee>();

    public virtual ICollection<LeaveRequest> LeaveRequests { get; set; } = new List<LeaveRequest>();

    public virtual ICollection<LeaveRequest> DelegatedLeaveRequests { get; set; } = new List<LeaveRequest>();

    public virtual ICollection<LeaveRequest> ApprovedLeaveRequests { get; set; } = new List<LeaveRequest>();

    public virtual ICollection<LeaveBalance> LeaveBalances { get; set; } = new List<LeaveBalance>();
}
