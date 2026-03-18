#nullable disable
using System;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class LeaveBalanceHistory
{
    public int Id { get; set; }

    public int LeaveBalanceId { get; set; }

    /// <summary>
    /// AdminGrant(管理員給假), Apply(請假扣除), Reject(駁回退還), CancelApproved(取消退還)
    /// </summary>
    public string ChangeType { get; set; }

    /// <summary>
    /// 正數=增加, 負數=扣除
    /// </summary>
    public decimal ChangeDays { get; set; }

    public decimal OldTotalDays { get; set; }

    public decimal NewTotalDays { get; set; }

    public decimal OldUsedDays { get; set; }

    public decimal NewUsedDays { get; set; }

    public string Reason { get; set; }

    public int OperatorId { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual LeaveBalance LeaveBalance { get; set; }

    public virtual Employee Operator { get; set; }
}
