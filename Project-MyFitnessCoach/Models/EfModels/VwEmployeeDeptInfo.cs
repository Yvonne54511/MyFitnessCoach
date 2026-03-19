using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class VwEmployeeDeptInfo
{
    public string UserName { get; set; } = null!;

    public string? Role { get; set; }

    public string DepartmentName { get; set; } = null!;

    public string? ManagerName { get; set; }

    public string? WorkDelegateName { get; set; }
}
