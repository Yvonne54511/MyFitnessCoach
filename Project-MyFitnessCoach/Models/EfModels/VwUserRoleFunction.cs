using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class VwUserRoleFunction
{
    public int UserId { get; set; }

    public string UserName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public int RoleId { get; set; }

    public string RoleName { get; set; } = null!;

    public int FunctionId { get; set; }

    public string FunctionName { get; set; } = null!;
}
