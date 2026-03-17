using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.Infra;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class AdminLeaveController : Controller
    {
        private readonly AdminLeaveService _adminLeaveService;
        private readonly EmployeeService _employeeService;

        public AdminLeaveController(AdminLeaveService adminLeaveService, EmployeeService employeeService)
        {
            _adminLeaveService = adminLeaveService;
            _employeeService = employeeService;
        }

        // ========== 全部申請管理 ==========

        // GET: /AdminLeave/List
        [Function("admin_LeaveRequests")]
        public async Task<IActionResult> List(string departmentFilter, string statusFilter, string monthFilter, string searchKeyword)
        {
            var vm = await _adminLeaveService.GetAllRequestsAsync(departmentFilter, statusFilter, monthFilter, searchKeyword);
            return View(vm);
        }

        // GET: /AdminLeave/Detail/{id}
        [Function("admin_LeaveRequests")]
        public async Task<IActionResult> Detail(int id)
        {
            var dto = await _adminLeaveService.GetDetailAsync(id);
            if (dto == null) return NotFound();

            return View(dto);
        }

        // ========== 員工管理 ==========

        // GET: /AdminLeave/EmployeeList
        [Function("admin_Employees")]
        public async Task<IActionResult> EmployeeList(string departmentFilter, string searchKeyword)
        {
            var vm = await _employeeService.GetListAsync(departmentFilter, searchKeyword);
            return View(vm);
        }

        // GET: /AdminLeave/EmployeeEdit/{id}
        [HttpGet]
        [Function("admin_Employees")]
        public async Task<IActionResult> EmployeeEdit(int id)
        {
            var vm = await _employeeService.GetForEditAsync(id);
            if (vm == null) return NotFound();

            return View(vm);
        }

        // POST: /AdminLeave/EmployeeEdit
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Function("admin_Employees")]
        public async Task<IActionResult> EmployeeEdit(EmployeeEditViewModel vm)
        {
            if (!ModelState.IsValid)
            {
                // 重新載入下拉選單
                var reloadVm = await _employeeService.GetForEditAsync(vm.Id);
                if (reloadVm == null) return NotFound();

                vm.UserName = reloadVm.UserName;
                vm.Account = reloadVm.Account;
                vm.DepartmentOptions = reloadVm.DepartmentOptions;
                vm.ManagerOptions = reloadVm.ManagerOptions;
                vm.DelegateOptions = reloadVm.DelegateOptions;
                return View(vm);
            }

            var result = await _employeeService.UpdateAsync(vm);

            if (result.IsSuccess)
            {
                TempData["SuccessMessage"] = "員工資料已更新";
                return RedirectToAction("EmployeeList");
            }

            TempData["ErrorMessage"] = result.ErrorMessage;
            var reload = await _employeeService.GetForEditAsync(vm.Id);
            if (reload == null) return NotFound();

            vm.UserName = reload.UserName;
            vm.Account = reload.Account;
            vm.DepartmentOptions = reload.DepartmentOptions;
            vm.ManagerOptions = reload.ManagerOptions;
            vm.DelegateOptions = reload.DelegateOptions;
            return View(vm);
        }
    }
}
