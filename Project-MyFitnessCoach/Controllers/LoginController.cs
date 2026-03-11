using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Collections.Generic;
using System.Threading.Tasks;
using System;
using System.Linq;
using Project_MyFitnessCoach.Models.DTOs;

namespace Project_MyFitnessCoach.Controllers
{
	public class LoginController : Controller
	{
		private readonly LoginService _service;

		public LoginController(LoginService service)
		{
			_service = service;
		}

		public IActionResult Index()
		{
			return View();
		}

		[HttpPost]
		[ValidateAntiForgeryToken]
		public async Task<IActionResult> Index(LoginViewModel vm, string returnUrl)
		{
			if (!ModelState.IsValid) return View(vm);

			var dto = new LoginDto
			{
				Account = vm.Account,
				Password = vm.Password
			};

			var result = await _service.LoginAsync(dto);

			if (result.IsSuccess == false)
			{
				TempData["ErrorMessage"] = result.ErrorMessage;
				return View(vm); 
			}

			// 將角色清單傳入
			await ProcessLogin(vm.Account, result.InstructorId, result.Roles);

            // 判斷角色導向 (不分大小寫)
            if (result.Roles.Any(r => r.Equals("Admin", StringComparison.OrdinalIgnoreCase)))
            {
                return RedirectToAction("AllShifts", "Shift");
            }
            
            if (result.Roles.Any(r => r.Equals("Instructor", StringComparison.OrdinalIgnoreCase)))
            {
                return RedirectToAction("Index", "Shift");
            }

            // 若有 ReturnUrl 則導向 ReturnUrl
            if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl))
            {
                return Redirect(returnUrl);
            }

			return RedirectToAction("Index", "Home");
		}

		private async Task ProcessLogin(string account, int? instructorId, List<string> roles)
		{
			var claims = new List<Claim>
			{
				new Claim(ClaimTypes.Name, account)
			};

            // 如果有營養師 ID 才加入
            if (instructorId.HasValue)
            {
                claims.Add(new Claim("InstructorId", instructorId.ToString()));
            }

            // 標準化角色名稱：保證在寫入 Claim 時符合大寫開頭的規定 (Admin, Instructor)
            foreach (var role in roles)
            {
                string standardizedRole = role;
                if (role.Equals("admin", StringComparison.OrdinalIgnoreCase)) standardizedRole = "Admin";
                if (role.Equals("instructor", StringComparison.OrdinalIgnoreCase)) standardizedRole = "Instructor";

                claims.Add(new Claim(ClaimTypes.Role, standardizedRole));
            }

			var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
			var principal = new ClaimsPrincipal(identity);
			
			await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, principal, 
                new AuthenticationProperties { IsPersistent = true, ExpiresUtc = DateTimeOffset.UtcNow.AddMinutes(30) });
		}

		public async Task<IActionResult> Logout()
		{
			await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
			return RedirectToAction("Index", "Home");
		}
	}
}
