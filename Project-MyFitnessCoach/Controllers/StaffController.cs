using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Services;
using Project_MyFitnessCoach.Models.Services;
using Project_MyFitnessCoach.Models.ViewModels;
using System.Threading.Tasks;
using System.Linq;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class StaffController : Controller
    {
        private readonly IUserService _userService;
        private readonly PermissionService _permissionService;

        public StaffController(IUserService userService, PermissionService permissionService)
        {
            _userService = userService;
            _permissionService = permissionService;
        }

        public async Task<IActionResult> Index(string? name = null, string? role = null, int? id = null)
        {
            var staffDtos = await _userService.GetStaffListAsync(name, role, id);
            var staffList = staffDtos.Select(s => new StaffListItemViewModel
            {
                Id = s.Id,
                UserName = s.UserName,
                Email = s.Email,
                Account = s.Account,
                IsConfirmed = s.IsConfirmed,
                IsActive = s.IsActive,
                Roles = s.Roles
            }).ToList();

            ViewBag.Roles = await _userService.GetActiveRolesAsync();
            ViewBag.CurrentName = name;
            ViewBag.CurrentRole = role;
            ViewBag.CurrentId = id;

            return View(staffList);
        }

        [HttpGet]
        public async Task<IActionResult> GetStaffList(string? name = null, string? role = null, int? id = null)
        {
            var staffDtos = await _userService.GetStaffListAsync(name, role, id);
            var staffList = staffDtos.Select(s => new StaffListItemViewModel
            {
                Id = s.Id,
                UserName = s.UserName,
                Email = s.Email,
                Account = s.Account,
                IsConfirmed = s.IsConfirmed,
                IsActive = s.IsActive,
                Roles = s.Roles
            }).ToList();

            return PartialView("_StaffListPartial", staffList);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Invite(StaffInviteViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return Json(new { success = false, message = "資料格式錯誤" });
            }

            var dto = new StaffInviteDto
            {
                UserName = model.UserName,
                Email = model.Email,
                RoleIds = model.RoleIds
            };

            var result = await _userService.InviteStaffAsync(dto, code => 
                Url.Action("Activate", "Staff", new { code }, Request.Scheme));

            return Json(new { success = result.IsSuccess, message = result.Message });
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            var dto = await _userService.GetStaffByIdAsync(id);
            if (dto == null) return NotFound();

            var model = new StaffEditViewModel
            {
                Id = dto.Id,
                UserName = dto.UserName,
                Email = dto.Email,
                IsActive = dto.IsActive,
                RoleIds = dto.RoleIds
            };

            ViewBag.Roles = await _userService.GetActiveRolesAsync();
            return PartialView("_EditStaffPartial", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(StaffEditViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return Json(new { success = false, message = "資料格式錯誤" });
            }

            var dto = new StaffUpdateDto
            {
                Id = model.Id,
                UserName = model.UserName,
                Email = model.Email,
                IsActive = model.IsActive,
                RoleIds = model.RoleIds
            };

            var result = await _userService.UpdateStaffAsync(dto);
            return Json(new { success = result.IsSuccess, message = result.Message });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _userService.DeleteStaffAsync(id);
            return Json(new { success = result.IsSuccess, message = result.Message });
        }

        [AllowAnonymous]
        [HttpGet]
        public async Task<IActionResult> Activate(string code)
        {
            if (string.IsNullOrEmpty(code) || !await _userService.IsConfirmCodeValidAsync(code))
            {
                ViewBag.Error = "啟動連結無效或已過期";
                return View("ActivateError");
            }

            return View(new StaffActivateViewModel { Code = code });
        }

        [AllowAnonymous]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Activate(StaffActivateViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            if (await _userService.AccountExistsAsync(model.Account))
            {
                ModelState.AddModelError("Account", "此帳號已被使用");
                return View(model);
            }

            var dto = new StaffActivateDto
            {
                Code = model.Code,
                Account = model.Account,
                Password = model.Password
            };

            var result = await _userService.ActivateAccountAsync(dto);
            if (result.IsSuccess)
            {
                TempData["LoginMessage"] = "帳號啟用成功，請登入";
                return RedirectToAction("Login", "Account");
            }

            ViewBag.Error = result.Message;
            return View("ActivateError");
        }

        #region Role & Function Management (Moved from PermissionController)
        public async Task<IActionResult> RoleFunctions()
        {
            var model = new PermissionViewModel
            {
                Roles = await _permissionService.GetAllRolesAsync(),
                Functions = await _permissionService.GetAllFunctionsAsync(),
                RoleFunctions = await _permissionService.GetAllRoleFunctionsAsync(),
                RolePermissionRows = await _permissionService.GetRolePermissionRowsAsync()
            };
            return View(model);
        }

        [HttpGet]
        public async Task<IActionResult> EditRolePermission(int roleId)
        {
            var rows = await _permissionService.GetRolePermissionRowsAsync();
            var row = rows.FirstOrDefault(r => r.RoleId == roleId);
            if (row == null) return NotFound();

            var staffList = await _userService.GetStaffListAsync();

            var model = new EditRolePermissionViewModel
            {
                RoleId = row.RoleId,
                RoleName = row.RoleName,
                SelectedFunctionIds = row.FunctionIds,
                SelectedUserIds = row.UserIds,
                AllFunctions = await _permissionService.GetAllFunctionsAsync(),
                AllStaff = staffList.ToList()
            };

            return PartialView("_EditRolePermissionPartial", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UpdateRolePermissions(int roleId, List<int> functionIds, List<int> userIds)
        {
            await _permissionService.UpdateRolePermissionsAsync(roleId, functionIds, userIds);
            return Json(new { success = true, message = "權限更新成功" });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateRole(RoleDto dto)
        {
            if (ModelState.IsValid)
            {
                await _permissionService.CreateRoleAsync(dto);
            }
            return RedirectToAction(nameof(RoleFunctions));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditRole(RoleDto dto)
        {
            if (ModelState.IsValid)
            {
                await _permissionService.UpdateRoleAsync(dto);
            }
            return RedirectToAction(nameof(RoleFunctions));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteRole(int id)
        {
            await _permissionService.DeleteRoleAsync(id);
            return RedirectToAction(nameof(RoleFunctions));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateFunction(FunctionDto dto)
        {
            if (ModelState.IsValid || !string.IsNullOrEmpty(dto.FunctionName))
            {
                await _permissionService.CreateFunctionAsync(dto);
            }
            return RedirectToAction(nameof(RoleFunctions));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditFunction(FunctionDto dto)
        {
            if (ModelState.IsValid)
            {
                await _permissionService.UpdateFunctionAsync(dto);
            }
            return RedirectToAction(nameof(RoleFunctions));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteFunction(int id)
        {
            await _permissionService.DeleteFunctionAsync(id);
            return RedirectToAction(nameof(RoleFunctions));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateRoleFunction(RoleFunctionDto dto)
        {
            if (dto.RoleId > 0 && dto.FunctionId > 0)
            {
                await _permissionService.CreateRoleFunctionAsync(dto);
            }
            return RedirectToAction(nameof(RoleFunctions));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteRoleFunction(int id)
        {
            await _permissionService.DeleteRoleFunctionAsync(id);
            return RedirectToAction(nameof(RoleFunctions));
        }
        #endregion
    }
}
