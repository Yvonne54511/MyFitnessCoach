using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Repositories;
using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Models.Services
{
    public class PermissionService
    {
        private readonly IRoleRepository _roleRepo;
        private readonly IFunctionRepository _funcRepo;
        private readonly IRoleFunctionRepository _rfRepo;

        public PermissionService(
            IRoleRepository roleRepo,
            IFunctionRepository funcRepo,
            IRoleFunctionRepository rfRepo)
        {
            _roleRepo = roleRepo;
            _funcRepo = funcRepo;
            _rfRepo = rfRepo;
        }

        // Roles
        public async Task<List<RoleDto>> GetAllRolesAsync()
        {
            var entities = await _roleRepo.GetAllAsync();
            return entities.Select(e => e.ToDto()).ToList();
        }

        public async Task CreateRoleAsync(RoleDto dto)
        {
            var entity = dto.ToEntity();
            entity.Id = 0; // Ensure ID is 0 for creation
            await _roleRepo.CreateAsync(entity);
        }

        public async Task UpdateRoleAsync(RoleDto dto)
        {
            var entity = await _roleRepo.GetByIdAsync(dto.Id);
            if (entity == null) return;
            
            entity.RoleName = dto.RoleName;
            entity.Description = dto.Description;
            entity.IsActive = dto.IsActive;
            
            await _roleRepo.UpdateAsync(entity);
        }

        public async Task DeleteRoleAsync(int id) => await _roleRepo.DeleteAsync(id);

        // Functions
        public async Task<List<FunctionDto>> GetAllFunctionsAsync()
        {
            var entities = await _funcRepo.GetAllAsync();
            return entities.Select(e => e.ToDto()).ToList();
        }

        public async Task CreateFunctionAsync(FunctionDto dto)
        {
            var entity = dto.ToEntity();
            entity.Id = 0; // Ensure ID is 0 for creation
            await _funcRepo.CreateAsync(entity);
        }

        public async Task UpdateFunctionAsync(FunctionDto dto)
        {
            var entity = await _funcRepo.GetByIdAsync(dto.Id);
            if (entity == null) return;

            entity.FunctionName = dto.FunctionName;
            entity.Description = dto.Description;
            entity.api_path = dto.ApiPath;
            entity.IsActive = dto.IsActive;

            await _funcRepo.UpdateAsync(entity);
        }

        public async Task DeleteFunctionAsync(int id) => await _funcRepo.DeleteAsync(id);

        // Role-Function Mappings
        public async Task<List<RoleFunctionDto>> GetAllRoleFunctionsAsync()
        {
            var entities = await _rfRepo.GetAllAsync();
            return entities.Select(e => e.ToDto()).ToList();
        }

        public async Task CreateRoleFunctionAsync(RoleFunctionDto dto)
        {
            if (await _rfRepo.ExistsAsync(dto.RoleId, dto.FunctionId)) return;

            var entity = dto.ToEntity();
            entity.Id = 0;
            await _rfRepo.CreateAsync(entity);
        }

        public async Task DeleteRoleFunctionAsync(int id) => await _rfRepo.DeleteAsync(id);
    }
}
