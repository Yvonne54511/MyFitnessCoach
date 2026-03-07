using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Services;

namespace Project_MyFitnessCoach.Controllers
{
    public class AuthController : Controller
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpGet]
        public IActionResult Register()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Register(RegisterViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var result = _authService.Register(model);

            if (result.Success)
            {
                // 註冊成功，導向確認頁面並傳遞信箱
                TempData["UserEmail"] = model.Email;
                return RedirectToAction("ConfirmRegister");
            }

            ModelState.AddModelError("", result.Message);
            return View(model);
        }

        [HttpGet]
        public IActionResult ConfirmRegister()
        {
            ViewBag.Email = TempData["UserEmail"];
            return View();
        }

        [HttpGet]
        public IActionResult ActivateRegister(int userId, string confirmCode)
        {
            var result = _authService.Activate(userId, confirmCode);
            ViewBag.Message = result.Message;
            ViewBag.IsSuccess = result.Success;
            return View();
        }

        [HttpGet]
        public IActionResult Login()
        {
            return View();
        }
    }
}
