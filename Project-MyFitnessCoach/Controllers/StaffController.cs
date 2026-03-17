using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Services;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class StaffController : Controller
    {
        private readonly IUserService _userService;

        public StaffController(IUserService userService)
        {
            _userService = userService;
        }

        public IActionResult Index()
        {
            var staffList = _userService.GetStaffList();
            ViewBag.Roles = _userService.GetActiveRoles();
            return View(staffList);
        }

        [HttpGet]
        public IActionResult GetStaffList()
        {
            var staffList = _userService.GetStaffList();
            return PartialView("_StaffListPartial", staffList);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Invite(StaffInviteViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return Json(new { success = false, message = "資料格式錯誤" });
            }

            var result = _userService.InviteStaff(model, code => 
                Url.Action("Activate", "Staff", new { code }, Request.Scheme));

            if (result)
            {
                return Json(new { success = true, message = "邀請已送出" });
            }

            return Json(new { success = false, message = "邀請送出失敗，可能該 Email 已被註冊" });
        }

        [HttpGet]
        public IActionResult Edit(int id)
        {
            var model = _userService.GetStaffEditModel(id);
            if (model == null) return NotFound();

            ViewBag.Roles = _userService.GetActiveRoles();
            return PartialView("_EditStaffPartial", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Edit(StaffEditViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return Json(new { success = false, message = "資料格式錯誤" });
            }

            var result = _userService.UpdateStaff(model);
            if (result)
            {
                return Json(new { success = true, message = "更新成功" });
            }

            return Json(new { success = false, message = "更新失敗" });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Delete(int id)
        {
            var result = _userService.DeleteStaff(id);
            if (result)
            {
                return Json(new { success = true, message = "刪除成功" });
            }

            return Json(new { success = false, message = "刪除失敗" });
        }

        [AllowAnonymous]
        [HttpGet]
        public IActionResult Activate(string code)
        {
            if (string.IsNullOrEmpty(code) || !_userService.IsConfirmCodeValid(code))
            {
                ViewBag.Error = "啟動連結無效或已過期";
                return View("ActivateError");
            }

            return View(new StaffActivateViewModel { Code = code });
        }

        [AllowAnonymous]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Activate(StaffActivateViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            if (_userService.AccountExists(model.Account))
            {
                ModelState.AddModelError("Account", "此帳號已被使用");
                return View(model);
            }

            var result = _userService.ActivateAccount(model);
            if (result)
            {
                TempData["LoginMessage"] = "帳號啟用成功，請登入";
                return RedirectToAction("Login", "Account");
            }

            ViewBag.Error = "帳號啟用失敗";
            return View("ActivateError");
        }
    }
}
