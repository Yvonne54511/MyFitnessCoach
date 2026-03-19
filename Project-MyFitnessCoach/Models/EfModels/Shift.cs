using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class Shift
{
    public int Id { get; set; }

    public int InstructorId { get; set; }

    public DateOnly ScheduleDate { get; set; }

    public string TimeSlot { get; set; } = null!;

    public bool IsBooked { get; set; }

    public virtual Instructor Instructor { get; set; } = null!;

    public virtual ICollection<ReserveOrder> ReserveOrders { get; set; } = new List<ReserveOrder>();
}
