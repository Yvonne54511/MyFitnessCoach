using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class InstructorWalletDetail
{
    public int Id { get; set; }

    public int InstructorWalletId { get; set; }

    public string SalaryDate { get; set; } = null!;

    public decimal TotalAmount { get; set; }

    public DateTime CreatedAt { get; set; }

    public string Category { get; set; } = null!;

    public virtual InstructorWallet InstructorWallet { get; set; } = null!;
}
