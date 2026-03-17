using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.Infra;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class ApplyLeaveController : Controller
    {
        private readonly LeaveService _leaveService;

        public ApplyLeaveController(LeaveService leaveService)
        {
            _leaveService = leaveService;
        }

        // GET: /ApplyLeave/List
        [Function("view_LeaveRequests")]
        public async Task<IActionResult> List(string statusFilter, string monthFilter)
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var vm = await _leaveService.GetMyRequestsAsync(empId.Value, statusFilter, monthFilter);
            return View(vm);
        }

        // GET: /ApplyLeave/Add
        [Function("edit_LeaveRequests")]
        public async Task<IActionResult> Add()
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var vm = await _leaveService.GetAddViewModelAsync(empId.Value);
            if (vm == null) return NotFound();

            return View(vm);
        }

        // POST: /ApplyLeave/Add
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Function("edit_LeaveRequests")]
        public async Task<IActionResult> Add(AddLeaveViewModel vm)
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            // 移除唯讀欄位的驗證
            ModelState.Remove(nameof(vm.EmployeeName));
            ModelState.Remove(nameof(vm.DepartmentName));
            ModelState.Remove(nameof(vm.ManagerName));

            if (!ModelState.IsValid)
            {
                var reloadVm = await _leaveService.GetAddViewModelAsync(empId.Value);
                if (reloadVm == null) return NotFound();
                reloadVm.LeaveTypeId = vm.LeaveTypeId;
                reloadVm.StartDate = vm.StartDate;
                reloadVm.EndDate = vm.EndDate;
                reloadVm.HoursUsed = vm.HoursUsed;
                reloadVm.Reason = vm.Reason;
                reloadVm.LeaveDelegateId = vm.LeaveDelegateId;
                return View(reloadVm);
            }

            var dto = new AddLeaveRequestDto
            {
                EmployeeId = empId.Value,
                LeaveTypeId = vm.LeaveTypeId,
                StartDate = vm.StartDate,
                EndDate = vm.EndDate,
                HoursUsed = vm.HoursUsed,
                Reason = vm.Reason,
                LeaveDelegateId = vm.LeaveDelegateId
            };

            var result = await _leaveService.ApplyAsync(dto);

            if (result.IsSuccess)
            {
                TempData["SuccessMessage"] = "請假申請已送出，等待主管審核";
                return RedirectToAction("List");
            }

            ModelState.AddModelError("", result.ErrorMessage);
            var reloadVm2 = await _leaveService.GetAddViewModelAsync(empId.Value);
            if (reloadVm2 == null) return NotFound();
            reloadVm2.LeaveTypeId = vm.LeaveTypeId;
            reloadVm2.StartDate = vm.StartDate;
            reloadVm2.EndDate = vm.EndDate;
            reloadVm2.HoursUsed = vm.HoursUsed;
            reloadVm2.Reason = vm.Reason;
            reloadVm2.LeaveDelegateId = vm.LeaveDelegateId;
            return View(reloadVm2);
        }

        // 4.2-1: AJAX - 取得可用代理人（排除請假者）
        [HttpGet]
        [Function("edit_LeaveRequests")]
        public async Task<IActionResult> GetAvailableDelegates(DateTime startDate, DateTime endDate)
        {
            var empId = User.GetEmployeeId();
            var deptId = User.GetDepartmentId();
            if (empId == null || deptId == null) return Forbid();

            var delegates = await _leaveService.GetAvailableDelegatesAsync(
                empId.Value, deptId.Value, startDate, endDate);

            return Json(delegates.Select(d => new { value = d.Value, text = d.Text }));
        }

        // 4.2-1: AJAX - 檢查預設代理人是否在該區間請假
        [HttpGet]
        [Function("edit_LeaveRequests")]
        public async Task<IActionResult> CheckDefaultDelegate(DateTime startDate, DateTime endDate)
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var vm = await _leaveService.GetAddViewModelAsync(empId.Value);
            if (vm?.DefaultDelegateId == null)
                return Json(new { hasDefault = false });

            var onLeave = await _leaveService.CheckDelegateOnLeaveAsync(
                vm.DefaultDelegateId.Value, startDate, endDate);

            // 取得代理人名稱
            var delegateName = vm.DelegateOptions
                .FirstOrDefault(d => d.Value == vm.DefaultDelegateId.ToString())?.Text ?? "";

            return Json(new
            {
                hasDefault = true,
                delegateId = vm.DefaultDelegateId,
                delegateName,
                onLeave
            });
        }

        // 4.2-3: 申請取消請假
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Function("edit_LeaveRequests")]
        public async Task<IActionResult> CancelRequest(int id, string cancelReason)
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var result = await _leaveService.RequestCancelAsync(id, empId.Value, cancelReason);

            if (result.IsSuccess)
            {
                TempData["SuccessMessage"] = "已送出取消申請，等待主管審核";
            }
            else
            {
                TempData["ErrorMessage"] = result.ErrorMessage;
            }

            return RedirectToAction("List");
        }

        // GET: /ApplyLeave/WorkDelegate
        [Function("edit_WorkDelegate")]
        public async Task<IActionResult> WorkDelegate()
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var vm = await _leaveService.GetWorkDelegateViewModelAsync(empId.Value);
            if (vm == null) return NotFound();

            return View(vm);
        }

        // POST: /ApplyLeave/WorkDelegate
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Function("edit_WorkDelegate")]
        public async Task<IActionResult> WorkDelegate(WorkDelegateViewModel vm)
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            if (vm.NewDelegateId == null || vm.NewDelegateId == 0)
            {
                ModelState.AddModelError("", "請選擇代理人");
                var reloadVm = await _leaveService.GetWorkDelegateViewModelAsync(empId.Value);
                return View(reloadVm);
            }

            var result = await _leaveService.SetWorkDelegateAsync(empId.Value, vm.NewDelegateId.Value);

            if (result.IsSuccess)
            {
                TempData["SuccessMessage"] = "代理人設定成功";
                return RedirectToAction("WorkDelegate");
            }

            ModelState.AddModelError("", result.ErrorMessage);
            var reload = await _leaveService.GetWorkDelegateViewModelAsync(empId.Value);
            return View(reload);
        }

        // POST: /ApplyLeave/RemoveDelegate
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Function("edit_WorkDelegate")]
        public async Task<IActionResult> RemoveDelegate()
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var result = await _leaveService.RemoveWorkDelegateAsync(empId.Value);

            if (result.IsSuccess)
            {
                TempData["SuccessMessage"] = "已解除代理人設定";
            }
            else
            {
                TempData["ErrorMessage"] = result.ErrorMessage;
            }

            return RedirectToAction("WorkDelegate");
        }
    }
}
