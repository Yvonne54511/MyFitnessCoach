using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Services;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Controllers
{
    public class AccountController : Controller
    {
        private readonly IMemberAccountService _accountService;

        public AccountController(IMemberAccountService accountService)
        {
            _accountService = accountService;
        }

        [Authorize]
        [HttpGet]
        public IActionResult ChangePassword()
        {
            return View();
        }

        [Authorize]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ChangePassword(ChangePasswordViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId))
            {
                return RedirectToAction(nameof(Login));
            }

            var result = await _accountService.ChangePasswordAsync(userId, model.OldPassword, model.NewPassword);
            if (!result.IsSuccess)
            {
                ModelState.AddModelError(string.Empty, result.Message);
                return View(model);
            }

            TempData["ChangePasswordSuccess"] = "密碼修改成功！";
            return View();
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

            var dto = new LoginDto
            {
                Account = model.Account,
                Password = model.Password
            };

            var result = await _accountService.LoginAsync(dto);
            if (!result.IsSuccess || result.Member == null)
            {
                ModelState.AddModelError(string.Empty, result.Message);
                return View(model);
            }

            var claims = new List<Claim>
            {
                new(ClaimTypes.NameIdentifier, result.Member.Id.ToString()),
                new(ClaimTypes.Name, result.Member.UserName ?? result.Member.Account),
                new(ClaimTypes.Email, result.Member.Email),
                new("Account", result.Member.Account)
            };

            foreach (var role in result.Member.Roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme, ClaimTypes.Name, ClaimTypes.Role);
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

            return RedirectToAction("Index", "Dashboard");
        }

        [HttpGet]
        public IActionResult ForgetPassword()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ForgetPassword(ForgetPasswordViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var result = await _accountService.CreateResetPasswordRequestAsync(
                model.Email,
                code => Url.Action("ResetPassword", "Account", new { code }, Request.Scheme) ?? string.Empty);

            ViewBag.Email = result.Email;
            ViewBag.IsSent = true;
            ViewBag.EmailSent = result.EmailSent;
            ViewBag.Message = result.Message;
            return View(model);
        }

        [HttpGet]
        public async Task<IActionResult> ResetPassword(string code)
        {
            if (string.IsNullOrWhiteSpace(code) || !await _accountService.IsResetPasswordCodeValidAsync(code))
            {
                TempData["ResetPasswordError"] = "重設密碼連結無效 or 已過期";
                return RedirectToAction(nameof(ForgetPassword));
            }

            return View(new ResetPasswordViewModel
            {
                Code = code
            });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ResetPassword(ResetPasswordViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var dto = new ResetPasswordDto
            {
                Code = model.Code,
                Password = model.Password,
                ConfirmPassword = model.ConfirmPassword
            };

            var result = await _accountService.ResetPasswordAsync(dto);
            if (!result.IsSuccess)
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
