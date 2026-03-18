#nullable disable
using System;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class Holiday
{
    public int Id { get; set; }

    public DateTime HolidayDate { get; set; }

    public string Name { get; set; }

    public int Year { get; set; }

    public bool IsActive { get; set; } = true;
}
