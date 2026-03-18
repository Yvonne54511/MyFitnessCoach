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

        // ========== 步驟 4.4：國定假日管理 ==========

        // GET: /AdminLeave/HolidayList
        [Function("admin_Holidays")]
        public async Task<IActionResult> HolidayList(int? year)
        {
            var vm = await _adminLeaveService.GetHolidayListAsync(year);
            return View(vm);
        }

        // GET: /AdminLeave/HolidayCreate
        [Function("admin_Holidays")]
        public IActionResult HolidayCreate()
        {
            return View(new HolidayEditViewModel());
        }

        // POST: /AdminLeave/HolidayCreate
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Function("admin_Holidays")]
        public async Task<IActionResult> HolidayCreate(HolidayEditViewModel vm)
        {
            if (!ModelState.IsValid) return View(vm);

            var result = await _adminLeaveService.CreateHolidayAsync(vm);
            if (result.IsSuccess)
            {
                TempData["SuccessMessage"] = "國定假日已新增";
                return RedirectToAction("HolidayList", new { year = vm.HolidayDate.Year });
            }

            TempData["ErrorMessage"] = result.ErrorMessage;
            return View(vm);
        }

        // GET: /AdminLeave/HolidayEdit/{id}
        [Function("admin_Holidays")]
        public async Task<IActionResult> HolidayEdit(int id)
        {
            var vm = await _adminLeaveService.GetHolidayForEditAsync(id);
            if (vm == null) return NotFound();
            return View(vm);
        }

        // POST: /AdminLeave/HolidayEdit
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Function("admin_Holidays")]
        public async Task<IActionResult> HolidayEdit(HolidayEditViewModel vm)
        {
            if (!ModelState.IsValid) return View(vm);

            var result = await _adminLeaveService.UpdateHolidayAsync(vm);
            if (result.IsSuccess)
            {
                TempData["SuccessMessage"] = "國定假日已更新";
                return RedirectToAction("HolidayList", new { year = vm.HolidayDate.Year });
            }

            TempData["ErrorMessage"] = result.ErrorMessage;
            return View(vm);
        }

        // POST: /AdminLeave/HolidayDelete
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Function("admin_Holidays")]
        public async Task<IActionResult> HolidayDelete(int id, int year)
        {
            var result = await _adminLeaveService.DeleteHolidayAsync(id);
            if (result.IsSuccess)
                TempData["SuccessMessage"] = "國定假日已刪除";
            else
                TempData["ErrorMessage"] = result.ErrorMessage;

            return RedirectToAction("HolidayList", new { year });
        }

        // ========== 步驟 4.4：假別額度管理 ==========

        // GET: /AdminLeave/BalanceList
        [Function("admin_LeaveBalances")]
        public async Task<IActionResult> BalanceList(string departmentFilter, string searchKeyword, int? year)
        {
            var vm = await _adminLeaveService.GetBalanceListAsync(departmentFilter, searchKeyword, year);
            return View(vm);
        }

        // GET: /AdminLeave/BalanceGrant
        [Function("admin_LeaveBalances")]
        public async Task<IActionResult> BalanceGrant(int employeeId, int leaveTypeId, int year)
        {
            var vm = await _adminLeaveService.GetBalanceGrantViewModelAsync(employeeId, leaveTypeId, year);
            if (vm == null) return NotFound();
            return View(vm);
        }

        // POST: /AdminLeave/BalanceGrant
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Function("admin_LeaveBalances")]
        public async Task<IActionResult> BalanceGrant(BalanceGrantViewModel vm)
        {
            if (!ModelState.IsValid)
            {
                var reload = await _adminLeaveService.GetBalanceGrantViewModelAsync(
                    vm.EmployeeId, vm.LeaveTypeId, vm.Year);
                if (reload == null) return NotFound();

                vm.EmployeeName = reload.EmployeeName;
                vm.DepartmentName = reload.DepartmentName;
                vm.LeaveTypeName = reload.LeaveTypeName;
                vm.CurrentTotalDays = reload.CurrentTotalDays;
                vm.CurrentUsedDays = reload.CurrentUsedDays;
                vm.CurrentRemainingDays = reload.CurrentRemainingDays;
                return View(vm);
            }

            var empId = User.GetEmployeeId();
            var operatorId = empId ?? 0;

            var result = await _adminLeaveService.GrantBalanceAsync(
                vm.EmployeeId, vm.LeaveTypeId, vm.Year, vm.GrantDays, vm.Reason, operatorId);

            if (result.IsSuccess)
            {
                TempData["SuccessMessage"] = $"已成功給予 {vm.GrantDays:N2} 天額度";
                return RedirectToAction("BalanceList", new { year = vm.Year });
            }

            TempData["ErrorMessage"] = result.ErrorMessage;
            return RedirectToAction("BalanceGrant", new { vm.EmployeeId, vm.LeaveTypeId, vm.Year });
        }

        // GET: /AdminLeave/BalanceHistory
        [Function("admin_LeaveBalances")]
        public async Task<IActionResult> BalanceHistory(int employeeId, int? leaveTypeId, int? year)
        {
            var vm = await _adminLeaveService.GetBalanceHistoryAsync(employeeId, leaveTypeId, year);
            if (vm == null) return NotFound();
            return View(vm);
        }
    }
}
