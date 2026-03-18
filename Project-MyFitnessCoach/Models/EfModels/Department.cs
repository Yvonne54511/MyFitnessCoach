#nullable disable
using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class Department
{
    public int Id { get; set; }

    public string Name { get; set; }

    public int? ManagerId { get; set; }

    public virtual Employee Manager { get; set; }

    public virtual ICollection<Employee> Employees { get; set; } = new List<Employee>();
}
