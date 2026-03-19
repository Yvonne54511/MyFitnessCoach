using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class SensitiveWord
{
    public int Id { get; set; }

    public string Word { get; set; } = null!;
}
