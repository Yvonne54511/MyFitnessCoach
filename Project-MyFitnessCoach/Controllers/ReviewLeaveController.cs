using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.Infra;
using Project_MyFitnessCoach.Services;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class ReviewLeaveController : Controller
    {
        private readonly ReviewLeaveService _reviewService;

        public ReviewLeaveController(ReviewLeaveService reviewService)
        {
            _reviewService = reviewService;
        }

        // GET: /ReviewLeave/Pending
        [FunctionOrDelegation("review_LeaveRequests")]
        public async Task<IActionResult> Pending(string typeFilter)
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var vm = await _reviewService.GetPendingListAsync(empId.Value);
            vm.TypeFilter = typeFilter;

            // 依類型篩選
            if (typeFilter == "new")
                vm.Requests = vm.Requests.Where(r => !r.IsCancelRequest).ToList();
            else if (typeFilter == "cancel")
                vm.Requests = vm.Requests.Where(r => r.IsCancelRequest).ToList();

            return View(vm);
        }

        // GET: /ReviewLeave/Detail/{id}
        [FunctionOrDelegation("review_LeaveRequests")]
        public async Task<IActionResult> Detail(int id)
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var dto = await _reviewService.GetDetailAsync(id, empId.Value);
            if (dto == null) return NotFound();

            return View(dto);
        }

        // POST: /ReviewLeave/Approve
        [HttpPost]
        [ValidateAntiForgeryToken]
        [FunctionOrDelegation("review_LeaveRequests")]
        public async Task<IActionResult> Approve(int id)
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var result = await _reviewService.ApproveAsync(id, empId.Value);

            if (result.IsSuccess)
                TempData["SuccessMessage"] = "已核准該假單";
            else
                TempData["ErrorMessage"] = result.ErrorMessage;

            return RedirectToAction("Pending");
        }

        // POST: /ReviewLeave/Reject
        [HttpPost]
        [ValidateAntiForgeryToken]
        [FunctionOrDelegation("review_LeaveRequests")]
        public async Task<IActionResult> Reject(int id, string rejectReason)
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var result = await _reviewService.RejectAsync(id, empId.Value, rejectReason);

            if (result.IsSuccess)
                TempData["SuccessMessage"] = "已駁回該假單";
            else
                TempData["ErrorMessage"] = result.ErrorMessage;

            return RedirectToAction("Pending");
        }

        // POST: /ReviewLeave/ApproveCancelRequest
        [HttpPost]
        [ValidateAntiForgeryToken]
        [FunctionOrDelegation("review_LeaveRequests")]
        public async Task<IActionResult> ApproveCancelRequest(int id)
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var result = await _reviewService.ApproveCancelAsync(id, empId.Value);

            if (result.IsSuccess)
                TempData["SuccessMessage"] = "已核准取消該假單";
            else
                TempData["ErrorMessage"] = result.ErrorMessage;

            return RedirectToAction("Pending");
        }

        // POST: /ReviewLeave/RejectCancelRequest
        [HttpPost]
        [ValidateAntiForgeryToken]
        [FunctionOrDelegation("review_LeaveRequests")]
        public async Task<IActionResult> RejectCancelRequest(int id, string rejectReason)
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var result = await _reviewService.RejectCancelAsync(id, empId.Value, rejectReason);

            if (result.IsSuccess)
                TempData["SuccessMessage"] = "已駁回取消請求，假單恢復原狀態";
            else
                TempData["ErrorMessage"] = result.ErrorMessage;

            return RedirectToAction("Pending");
        }

        // GET: /ReviewLeave/List（部門請假總覽）
        [Function("view_DeptLeave")]
        public async Task<IActionResult> List(string monthFilter, string employeeFilter, string statusFilter)
        {
            var empId = User.GetEmployeeId();
            if (empId == null) return Forbid();

            var vm = await _reviewService.GetDeptOverviewAsync(empId.Value, monthFilter, employeeFilter, statusFilter);
            if (vm == null) return NotFound();

            return View(vm);
        }
    }
}
