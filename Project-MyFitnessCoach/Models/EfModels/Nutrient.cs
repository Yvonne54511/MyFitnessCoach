using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class Nutrient
{
    public int Id { get; set; }

    public int FoodId { get; set; }

    public int BaseAmount { get; set; }

    public string Measure { get; set; } = null!;

    public double? Kcal { get; set; }

    public double? ProteinGram { get; set; }

    public double? CarbGram { get; set; }

    public double? FatGram { get; set; }

    public virtual Food Food { get; set; } = null!;
}
