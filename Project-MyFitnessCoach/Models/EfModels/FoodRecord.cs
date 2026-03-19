using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class FoodRecord
{
    public int Id { get; set; }

    public int MemberId { get; set; }

    public DateTime EatDt { get; set; }

    public string MealType { get; set; } = null!;

    public int FoodId { get; set; }

    public double Amount { get; set; }

    public string Measure { get; set; } = null!;

    public virtual Food Food { get; set; } = null!;

    public virtual Member Member { get; set; } = null!;
}
