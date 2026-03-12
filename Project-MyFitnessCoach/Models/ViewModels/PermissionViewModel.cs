using Project_MyFitnessCoach.Models.DTOs;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class PermissionViewModel
    {
        public List<RoleDto> Roles { get; set; } = new List<RoleDto>();
        public List<FunctionDto> Functions { get; set; } = new List<FunctionDto>();
        public List<RoleFunctionDto> RoleFunctions { get; set; } = new List<RoleFunctionDto>();
        public List<RolePermissionRowViewModel> RolePermissionRows { get; set; } = new List<RolePermissionRowViewModel>();
    }

    public class RolePermissionRowViewModel
    {
        public int RoleId { get; set; }
        public string RoleName { get; set; }
        public List<int> FunctionIds { get; set; } = new List<int>();
        public string FunctionNames { get; set; } // Comma separated
        public List<int> UserIds { get; set; } = new List<int>();
        public string UserNames { get; set; } // Comma separated
    }

    public class EditRolePermissionViewModel
    {
        public int RoleId { get; set; }
        public string RoleName { get; set; }
        public List<int> SelectedFunctionIds { get; set; } = new List<int>();
        public List<int> SelectedUserIds { get; set; } = new List<int>();
        
        public List<FunctionDto> AllFunctions { get; set; } = new List<FunctionDto>();
        public List<StaffDto> AllStaff { get; set; } = new List<StaffDto>();
    }
}
