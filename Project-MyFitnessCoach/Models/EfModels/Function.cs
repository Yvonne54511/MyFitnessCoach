using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class Function
{
    public int Id { get; set; }

    public string FunctionName { get; set; } = null!;

    public bool IsActive { get; set; }

    public string? Description { get; set; }

    public string? ApiPath { get; set; }

    public virtual ICollection<RoleFunction> RoleFunctions { get; set; } = new List<RoleFunction>();
}
