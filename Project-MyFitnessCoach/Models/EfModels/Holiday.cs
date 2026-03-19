using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class Holiday
{
    public int Id { get; set; }

    public DateOnly HolidayDate { get; set; }

    public string Name { get; set; } = null!;

    public int Year { get; set; }

    public bool IsActive { get; set; }
}
