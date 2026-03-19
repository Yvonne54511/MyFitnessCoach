using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class UserExternalLogin
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public string LoginProvider { get; set; } = null!;

    public string ProviderKey { get; set; } = null!;

    public string? ProviderDisplayName { get; set; }

    public virtual User User { get; set; } = null!;
}
