using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class Instructor
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public string ImageUrl { get; set; } = null!;

    public string Description { get; set; } = null!;

    public int HourWage { get; set; }

    public int CancelCount { get; set; }

    public bool IsActive { get; set; }

    public virtual ICollection<InstructorWallet> InstructorWallets { get; set; } = new List<InstructorWallet>();

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

    public virtual ICollection<Shift> Shifts { get; set; } = new List<Shift>();

    public virtual User User { get; set; } = null!;
}
