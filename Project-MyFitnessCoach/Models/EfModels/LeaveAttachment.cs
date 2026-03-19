using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class LeaveAttachment
{
    public int Id { get; set; }

    public int RequestId { get; set; }

    public string FileName { get; set; } = null!;

    public string FileUrl { get; set; } = null!;

    public DateTime UploadedAt { get; set; }

    public virtual LeaveRequest Request { get; set; } = null!;
}
