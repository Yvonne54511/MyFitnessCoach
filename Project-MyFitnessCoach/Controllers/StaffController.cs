using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.Infra;
using Project_MyFitnessCoach.Services;
using Project_MyFitnessCoach.Models.Services;
using Project_MyFitnessCoach.Models.ViewModels;
using System.Threading.Tasks;
using System.Linq;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    [Function("edit_UserAccounts")]
    public class StaffController : Controller
    {
        private readonly IUserService _userService;
        private readonly PermissionService _permissionService;
        private readonly IInstructorService _instructorService;
        private readonly IWebHostEnvironment _environment;

        public StaffController(IUserService userService, PermissionService permissionService, IInstructorService instructorService, IWebHostEnvironment environment)
        {
            _userService = userService;
            _permissionService = permissionService;
            _instructorService = instructorService;
            _environment = environment;
        }

        public async Task<IActionResult> InstructorList()
        {
            var instructors = await _instructorService.GetAllInstructorsAsync();
            return View(instructors);
        }

        [HttpGet]
        public async Task<IActionResult> GetInstructorList()
        {
            var instructors = await _instructorService.GetAllInstructorsAsync();
            return PartialView("_InstructorListPartial", instructors);
        }

        [HttpGet]
        public async Task<IActionResult> CreateInstructor(int? userId = null)
        {
            var availableUsers = await _instructorService.GetAvailableUsersAsync();

            if (userId.HasValue)
            {
                // 指定使用者：僅傳入該使用者，前端顯示為唯讀
                var allStaff = await _userService.GetStaffListAsync();
                var targetUser = allStaff.FirstOrDefault(u => u.Id == userId.Value);
                if (targetUser != null)
                {
                    ViewBag.Users = new List<UserDto>
                    {
                        new UserDto { Id = targetUser.Id, UserName = targetUser.UserName, Account = targetUser.Account, Email = targetUser.Email }
                    };
                    ViewBag.FixedUserId = userId.Value;
                    return PartialView("_CreateInstructorPartial", new InstructorDto { UserId = userId.Value });
                }
            }

            ViewBag.Users = availableUsers;
            return PartialView("_CreateInstructorPartial", new InstructorDto());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateInstructor(InstructorDto dto, IFormFile? imageFile)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (imageFile != null && imageFile.Length > 0)
                    {
                        var fileName = Guid.NewGuid().ToString() + Path.GetExtension(imageFile.FileName);
                        var filePath = Path.Combine(_environment.WebRootPath, "img", "instructors", fileName);
                        
                        var folderPath = Path.GetDirectoryName(filePath);
                        if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath!);

                        using (var stream = new FileStream(filePath, FileMode.Create))
                        {
                            await imageFile.CopyToAsync(stream);
                        }
                        dto.ImageUrl = "/img/instructors/" + fileName;
                    }

                    await _instructorService.CreateInstructorAsync(dto);
                    return Json(new { success = true, message = "新增成功" });
                }
                
                var errors = string.Join("; ", ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage));
                return Json(new { success = false, message = "資料驗證失敗: " + errors });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "伺服器發生錯誤: " + ex.Message });
            }
        }

        [HttpGet]
        public async Task<IActionResult> EditInstructor(int id)
        {
            var dto = await _instructorService.GetInstructorByIdAsync(id);
            if (dto == null) return NotFound();

            return PartialView("_EditInstructorPartial", dto);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditInstructor(InstructorDto dto, IFormFile? imageFile)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (imageFile != null && imageFile.Length > 0)
                    {
                        var fileName = Guid.NewGuid().ToString() + Path.GetExtension(imageFile.FileName);
                        var filePath = Path.Combine(_environment.WebRootPath, "img", "instructors", fileName);
                        
                        var folderPath = Path.GetDirectoryName(filePath);
                        if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath!);

                        using (var stream = new FileStream(filePath, FileMode.Create))
                        {
                            await imageFile.CopyToAsync(stream);
                        }
                        dto.ImageUrl = "/img/instructors/" + fileName;
                    }

                    await _instructorService.UpdateInstructorAsync(dto);
                    return Json(new { success = true, message = "更新成功" });
                }
                
                var errors = string.Join("; ", ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage));
                return Json(new { success = false, message = "資料驗證失敗: " + errors });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "伺服器發生錯誤: " + ex.Message });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteInstructor(int id)
        {
            await _instructorService.DeleteInstructorAsync(id);
            return Json(new { success = true, message = "刪除成功" });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ToggleInstructorActive(int id)
        {
            await _instructorService.ToggleIsActiveAsync(id);
            return Json(new { success = true, message = "狀態已變更" });
        }

        public async Task<IActionResult> Index(string? name = null, string? role = null, int? id = null)
        {
            var staffDtos = await _userService.GetStaffListAsync(name, role, id);
            var allStaff = staffDtos.Select(s => new StaffListItemViewModel
            {
                Id = s.Id,
                UserName = s.UserName,
                Email = s.Email,
                Account = s.Account,
                IsConfirmed = s.IsConfirmed,
                IsActive = s.IsActive,
                Roles = s.Roles
            }).ToList();

            // 員工列表：排除只有 member 或 instructor 角色的使用者（無角色的也顯示）
            var staffList = allStaff
                .Where(s => !s.Roles.Any() || s.Roles.Any(r => r != "member" && r != "instructor"))
                .ToList();
            // 營養師列表：有 instructor 角色的使用者
            ViewBag.InstructorList = allStaff
                .Where(s => s.Roles.Any(r => r == "instructor"))
                .ToList();
            // 營養師詳細資料
            var instructors = await _instructorService.GetAllInstructorsAsync();
            ViewBag.InstructorDetails = instructors.ToList();
            // 會員列表：有 member 角色的使用者
            ViewBag.MemberList = allStaff
                .Where(s => s.Roles.Any(r => r == "member"))
                .ToList();

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
            }).Where(s => !s.Roles.Any() || s.Roles.Any(r => r != "member" && r != "instructor"))
            .ToList();

            return PartialView("_StaffListPartial", staffList);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Invite(StaffInviteViewModel model)
        {
            if (!ModelState.IsValid || model.RoleIds == null || model.RoleIds.Count == 0)
            {
                return Json(new { success = false, message = "請填寫完整資料，並至少選擇一個角色" });
            }

            try
            {
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
            catch (Exception ex)
            {
                return Json(new { success = false, message = "邀請失敗：" + ex.Message });
            }
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
        [Function("edit_RoleFunctions")]
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
