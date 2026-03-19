using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public class EmployeeService
    {
        private readonly IEmployeeRepository _repo;
        private readonly MyFitnessCoachDbContext _db;

        /// <summary>
        /// 需要 Employee 記錄的角色名稱（員工角色）
        /// </summary>
        private static readonly HashSet<string> EmployeeRoles = new(StringComparer.OrdinalIgnoreCase)
        {
            "purchasor", "marketor", "admin"
        };

        /// <summary>
        /// 角色名稱 → 預設部門 ID 對應（採購部=1, 行銷部=2）
        /// </summary>
        private static readonly Dictionary<string, int> RoleDepartmentMap = new(StringComparer.OrdinalIgnoreCase)
        {
            { "purchasor", 1 },  // 採購部
            { "marketor", 2 },   // 行銷部
            { "admin", 1 }       // 預設歸採購部（管理員無固定部門）
        };

        public EmployeeService(IEmployeeRepository repo, MyFitnessCoachDbContext db)
        {
            _repo = repo;
            _db = db;
        }

        /// <summary>
        /// 檢查使用者是否擁有「員工角色」，若有且尚無 Employee 記錄則自動建立。
        /// 若已有 Employee 記錄但 IsActive == false，則重新啟用。
        /// </summary>
        public async Task EnsureEmployeeExistsAsync(int userId, IEnumerable<string> roleNames)
        {
            bool needsEmployee = roleNames.Any(r => EmployeeRoles.Contains(r));
            if (!needsEmployee) return;

            var existing = await _repo.GetByUserIdAsync(userId);

            if (existing != null)
            {
                // 已存在但停用 → 重新啟用
                if (!existing.IsActive)
                {
                    existing.IsActive = true;
                    await _repo.UpdateAsync(existing);
                }
                return;
            }

            // 不存在 → 自動建立 Employee 記錄
            var employee = new Employee
            {
                UserId = userId,
                DepartmentId = GetDefaultDepartmentId(roleNames),
                HiredDate = DateOnly.FromDateTime(DateTime.Today),
                IsActive = true,
                ManagerId = null,
                WorkDelegateId = null
            };
            await _repo.CreateAsync(employee);
        }

        /// <summary>
        /// 若使用者不再擁有任何「員工角色」，停用 Employee 記錄（不刪除，保留歷史資料）。
        /// </summary>
        public async Task DeactivateEmployeeIfNoEmployeeRolesAsync(int userId, IEnumerable<string> roleNames)
        {
            bool needsEmployee = roleNames.Any(r => EmployeeRoles.Contains(r));
            if (needsEmployee) return;

            var existing = await _repo.GetByUserIdAsync(userId);
            if (existing != null && existing.IsActive)
            {
                existing.IsActive = false;
                await _repo.UpdateAsync(existing);
            }
        }

        /// <summary>
        /// 依角色名稱對應預設部門 ID
        /// </summary>
        private static int GetDefaultDepartmentId(IEnumerable<string> roleNames)
        {
            foreach (var role in roleNames)
            {
                if (RoleDepartmentMap.TryGetValue(role, out var deptId))
                    return deptId;
            }
            return 1; // fallback: 採購部
        }

        public async Task<EmployeeListViewModel> GetListAsync(string? deptFilter, string? keyword)
        {
            var employees = await _repo.GetAllAsync(deptFilter, keyword);

            // 部門下拉選單
            var departments = await _db.Departments
                .OrderBy(d => d.Name)
                .ToListAsync();

            var dtos = employees.Select(e => new AdminEmployeeDto
            {
                Id = e.Id,
                UserId = e.UserId,
                UserName = e.User?.UserName,
                Account = e.User?.Account,
                DepartmentName = e.Department?.Name,
                ManagerName = e.Manager?.User?.UserName,
                WorkDelegateName = e.WorkDelegate?.User?.UserName,
                HiredDate = e.HiredDate,
                IsActive = e.IsActive
            }).ToList();

            return new EmployeeListViewModel
            {
                DepartmentFilter = deptFilter,
                SearchKeyword = keyword,
                Employees = dtos,
                DepartmentOptions = new List<SelectListItem>
                {
                    new SelectListItem { Value = "", Text = "全部部門" }
                }.Concat(departments.Select(d => new SelectListItem
                {
                    Value = d.Id.ToString(),
                    Text = d.Name
                })).ToList()
            };
        }

        public async Task<EmployeeEditViewModel> GetForEditAsync(int id)
        {
            var employee = await _repo.GetByIdAsync(id);
            if (employee == null) return null;

            var departments = await _db.Departments.OrderBy(d => d.Name).ToListAsync();
            var allEmployees = await _db.Employees
                .Include(e => e.User)
                .Where(e => e.IsActive)
                .OrderBy(e => e.User.UserName)
                .ToListAsync();

            return new EmployeeEditViewModel
            {
                Id = employee.Id,
                UserId = employee.UserId,
                DepartmentId = employee.DepartmentId,
                ManagerId = employee.ManagerId,
                WorkDelegateId = employee.WorkDelegateId,
                IsActive = employee.IsActive,
                UserName = employee.User?.UserName,
                Account = employee.User?.Account,
                DepartmentOptions = departments.Select(d => new SelectListItem
                {
                    Value = d.Id.ToString(),
                    Text = d.Name
                }).ToList(),
                ManagerOptions = new List<SelectListItem>
                {
                    new SelectListItem { Value = "", Text = "-- 無主管 --" }
                }.Concat(allEmployees
                    .Where(e => e.Id != id) // 不能是自己
                    .Select(e => new SelectListItem
                    {
                        Value = e.Id.ToString(),
                        Text = e.User?.UserName
                    })).ToList(),
                DelegateOptions = new List<SelectListItem>
                {
                    new SelectListItem { Value = "", Text = "-- 無代理人 --" }
                }.Concat(allEmployees
                    .Where(e => e.Id != id) // 不能是自己
                    .Select(e => new SelectListItem
                    {
                        Value = e.Id.ToString(),
                        Text = e.User?.UserName
                    })).ToList()
            };
        }

        public async Task<Result> UpdateAsync(EmployeeEditViewModel vm)
        {
            var employee = await _repo.GetByIdAsync(vm.Id);
            if (employee == null)
                return Result.Failure("找不到此員工");

            employee.DepartmentId = vm.DepartmentId;
            employee.ManagerId = vm.ManagerId;
            employee.WorkDelegateId = vm.WorkDelegateId;
            employee.IsActive = vm.IsActive;

            await _repo.UpdateAsync(employee);

            return Result.Success(null);
        }
    }
}
