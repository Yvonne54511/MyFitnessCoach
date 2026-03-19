using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class VwUserMemberFoodRecord
{
    public int UserId { get; set; }

    public string UserName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public int MemberId { get; set; }

    public byte? Gender { get; set; }

    public double? Weight { get; set; }

    public double? Height { get; set; }

    public double? Bmr { get; set; }

    public double? Tdee { get; set; }

    public int FoodRecordId { get; set; }

    public DateTime EatDt { get; set; }

    public string MealType { get; set; } = null!;

    public double Amount { get; set; }

    public string RecordMeasure { get; set; } = null!;

    public int FoodId { get; set; }

    public string FoodName { get; set; } = null!;

    public string CategoryName { get; set; } = null!;

    public int? BaseAmount { get; set; }

    public string? NutrientMeasure { get; set; }

    public double? TotalKcal { get; set; }

    public double? TotalProtein { get; set; }

    public double? TotalCarb { get; set; }

    public double? TotalFat { get; set; }
}
