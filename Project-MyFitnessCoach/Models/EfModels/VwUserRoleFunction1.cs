using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class VwUserRoleFunction1
{
    public string UserName { get; set; } = null!;

    public string? Account { get; set; }

    public string RoleName { get; set; } = null!;

    public string FunctionName { get; set; } = null!;
}
