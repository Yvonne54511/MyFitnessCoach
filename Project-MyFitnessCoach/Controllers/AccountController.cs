using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Services;

namespace Project_MyFitnessCoach.Controllers
{
    public class AccountController : Controller
    {
        private readonly IAccountService _accountService;

        public AccountController(IAccountService accountService)
        {
            _accountService = accountService;
        }

        [HttpGet]
        public IActionResult Login(string? returnUrl = null)
        {
            if (User.Identity?.IsAuthenticated == true)
            {
                return RedirectToAction("Index", "Dashboard");
            }

            ViewData["ReturnUrl"] = returnUrl;
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginViewModel model, string? returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var result = _accountService.Login(model);
            if (!result.Success || result.User == null)
            {
                ModelState.AddModelError(string.Empty, result.Message);
                return View(model);
            }

            var claims = new List<Claim>
            {
                new(ClaimTypes.NameIdentifier, result.User.Id.ToString()),
                new(ClaimTypes.Name, result.User.UserName),
                new(ClaimTypes.Email, result.User.Email)
            };

            if (result.InstructorId.HasValue)
            {
                claims.Add(new Claim("InstructorId", result.InstructorId.Value.ToString()));
            }

            // 寫入角色 Claims
            foreach (var role in result.Roles)
            {
                string standardizedRole = role.Trim();
                if (string.Equals(standardizedRole, "admin", StringComparison.OrdinalIgnoreCase)) 
                    standardizedRole = "Admin";
                else if (string.Equals(standardizedRole, "instructor", StringComparison.OrdinalIgnoreCase)) 
                    standardizedRole = "Instructor";

                claims.Add(new Claim(ClaimTypes.Role, standardizedRole));
            }

            // 寫入功能權限 Claims (自定義類型 Permission)
            foreach (var func in result.Functions)
            {
                claims.Add(new Claim("Permission", func));
            }

            var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            var principal = new ClaimsPrincipal(identity);

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                principal,
                new AuthenticationProperties
                {
                    IsPersistent = true,
                    ExpiresUtc = DateTimeOffset.UtcNow.AddHours(8)
                });

            if (!string.IsNullOrWhiteSpace(returnUrl) && Url.IsLocalUrl(returnUrl))
            {
                return Redirect(returnUrl);
            }

            if (result.Roles.Any(r => r.Equals("Admin", StringComparison.OrdinalIgnoreCase)))
            {
                return RedirectToAction("AllShifts", "Shift");
            }

            if (result.Roles.Any(r => r.Equals("Instructor", StringComparison.OrdinalIgnoreCase)))
            {
                return RedirectToAction("Index", "Shift");
            }

            return RedirectToAction("Index", "Dashboard");
        }

        [HttpGet]
        public IActionResult ForgetPassword()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult ForgetPassword(ForgetPasswordViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var result = _accountService.CreateResetPasswordRequest(
                model.Email,
                code => Url.Action("ResetPassword", "Account", new { code }, Request.Scheme) ?? string.Empty);

            ViewBag.Email = result.Email;
            ViewBag.IsSent = true;
            ViewBag.EmailSent = result.EmailSent;
            return View(model);
        }

        [HttpGet]
        public IActionResult ResetPassword(string code)
        {
            if (string.IsNullOrWhiteSpace(code) || !_accountService.IsResetPasswordCodeValid(code))
            {
                TempData["ResetPasswordError"] = "���]�K�X�s���L�ĩΤw�L��";
                return RedirectToAction(nameof(ForgetPassword));
            }

            return View(new ResetPasswordViewModel
            {
                Code = code
            });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult ResetPassword(ResetPasswordViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var result = _accountService.ResetPassword(model);
            if (!result.Success)
            {
                ModelState.AddModelError(string.Empty, result.Message);
                return View(model);
            }

            TempData["LoginMessage"] = result.Message;
            return RedirectToAction(nameof(Login));
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction(nameof(Login));
        }
    }
}
