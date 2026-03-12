using Project_MyFitnessCoach.Models.DTOs;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class PermissionViewModel
    {
        public List<RoleDto> Roles { get; set; } = new List<RoleDto>();
        public List<FunctionDto> Functions { get; set; } = new List<FunctionDto>();
        public List<RoleFunctionDto> RoleFunctions { get; set; } = new List<RoleFunctionDto>();
    }
}
