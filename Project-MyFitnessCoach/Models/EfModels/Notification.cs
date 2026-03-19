using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class Notification
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public int? SenderId { get; set; }

    public string NotifyType { get; set; } = null!;

    public string Title { get; set; } = null!;

    public string Content { get; set; } = null!;

    public bool IsRead { get; set; }

    public int? ReferenceId { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual User? Sender { get; set; }

    public virtual User User { get; set; } = null!;
}
