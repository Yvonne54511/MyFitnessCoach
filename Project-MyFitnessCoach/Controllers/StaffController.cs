using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Services;
using System.Threading.Tasks;
using System.Linq;

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

        // --- Role & Function Management ---

        [HttpGet]
        public async Task<IActionResult> RolesFunction()
        {
            var roles = await _userService.GetAllRolesAsync();
            var functions = await _userService.GetAllFunctionsAsync();
            var mappings = await _userService.GetRoleFunctionsAsync();

            var viewModel = new RolesFunctionViewModel
            {
                Roles = roles.ToList(),
                Functions = functions.ToList(),
                Matrix = roles.Select(r => new RoleFunctionMatrixRow
                {
                    RoleId = r.Id,
                    RoleName = r.RoleName,
                    FunctionStatus = functions.ToDictionary(
                        f => f.Id,
                        f => mappings.Any(m => m.RoleId == r.Id && m.FunctionId == f.Id)
                    )
                }).ToList()
            };

            return View(viewModel);
        }

        [HttpPost]
        public async Task<IActionResult> TogglePermission(int roleId, int functionId, bool isEnabled)
        {
            var result = await _userService.ToggleRoleFunctionAsync(roleId, functionId, isEnabled);
            return Json(new { success = result.IsSuccess, message = result.Message });
        }

        [HttpPost]
        public async Task<IActionResult> AddAssociation(AddRoleFunctionViewModel model)
        {
            if (!ModelState.IsValid) return Json(new { success = false, message = "請選擇角色與功能" });

            var result = await _userService.AddRoleFunctionsAsync(model.RoleId, model.FunctionIds);
            return Json(new { success = result.IsSuccess, message = result.Message });
        }

        // Role CRUD
        [HttpPost]
        public async Task<IActionResult> SaveRole(RoleDto dto)
        {
            var result = dto.Id > 0 
                ? await _userService.UpdateRoleAsync(dto) 
                : await _userService.CreateRoleAsync(dto);
            return Json(new { success = result.IsSuccess, message = result.Message });
        }

        [HttpPost]
        public async Task<IActionResult> DeleteRole(int id)
        {
            var result = await _userService.DeleteRoleAsync(id);
            return Json(new { success = result.IsSuccess, message = result.Message });
        }

        // Function CRUD
        [HttpPost]
        public async Task<IActionResult> SaveFunction(FunctionDto dto)
        {
            var result = dto.Id > 0 
                ? await _userService.UpdateFunctionAsync(dto) 
                : await _userService.CreateFunctionAsync(dto);
            return Json(new { success = result.IsSuccess, message = result.Message });
        }

        [HttpPost]
        public async Task<IActionResult> DeleteFunction(int id)
        {
            var result = await _userService.DeleteFunctionAsync(id);
            return Json(new { success = result.IsSuccess, message = result.Message });
        }
    }
}
