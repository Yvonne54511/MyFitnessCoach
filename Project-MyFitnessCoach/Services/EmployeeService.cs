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

        public EmployeeService(IEmployeeRepository repo, MyFitnessCoachDbContext db)
        {
            _repo = repo;
            _db = db;
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
