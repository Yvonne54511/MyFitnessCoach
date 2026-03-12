using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public static class RoleDtoExtensions
    {
        public static RoleDto ToDto(this Role role)
        {
            if (role == null) return null;
            return new RoleDto
            {
                Id = role.Id,
                RoleName = role.RoleName,
                Description = role.Description,
                IsActive = role.IsActive
            };
        }

        public static Role ToEntity(this RoleDto dto)
        {
            if (dto == null) return null;
            return new Role
            {
                Id = dto.Id,
                RoleName = dto.RoleName,
                Description = dto.Description,
                IsActive = dto.IsActive
            };
        }
    }

    public static class FunctionDtoExtensions
    {
        public static FunctionDto ToDto(this Function function)
        {
            if (function == null) return null;
            return new FunctionDto
            {
                Id = function.Id,
                FunctionName = function.FunctionName,
                Description = function.Description,
                api_path = function.api_path,
                IsActive = function.IsActive
            };
        }

        public static Function ToEntity(this FunctionDto dto)
        {
            if (dto == null) return null;
            return new Function
            {
                Id = dto.Id,
                FunctionName = dto.FunctionName,
                Description = dto.Description,
                api_path = dto.api_path, // 此欄位與資料庫 api_path 對應
                IsActive = dto.IsActive
            };
        }
    }

    public class RoleFunctionDto
    {
        public int Id { get; set; }
        public int RoleId { get; set; }
        public int FunctionId { get; set; }
        public string RoleName { get; set; }
        public string FunctionName { get; set; }
        public bool IsEnabled { get; set; }
    }

    public static class RoleFunctionDtoExtensions
    {
        public static RoleFunctionDto ToDto(this RoleFunction rf)
        {
            if (rf == null) return null;
            return new RoleFunctionDto
            {
                Id = rf.Id,
                RoleId = rf.RoleId,
                FunctionId = rf.FunctionId,
                RoleName = rf.Role?.RoleName,
                FunctionName = rf.Function?.FunctionName
            };
        }

        public static RoleFunction ToEntity(this RoleFunctionDto dto)
        {
            if (dto == null) return null;
            return new RoleFunction
            {
                Id = dto.Id,
                RoleId = dto.RoleId,
                FunctionId = dto.FunctionId
            };
        }
    }
}
