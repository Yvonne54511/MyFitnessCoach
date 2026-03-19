using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class Food
{
    public int Id { get; set; }

    public int CategoryId { get; set; }

    public string FoodName { get; set; } = null!;

    public bool IsDeleted { get; set; }

    public virtual FoodCategory Category { get; set; } = null!;

    public virtual ICollection<FoodRecord> FoodRecords { get; set; } = new List<FoodRecord>();

    public virtual ICollection<Nutrient> Nutrients { get; set; } = new List<Nutrient>();
}
