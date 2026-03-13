using System.Diagnostics;
using Project_MyFitnessCoach.Models;
using Microsoft.AspNetCore.Mvc;

namespace Project_MyFitnessCoach.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        [Route("Home/Error/{statusCode?}")]
        public IActionResult Error(int? statusCode = null)
        {
            var requestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier;
            
            if (statusCode.HasValue)
            {
                ViewBag.StatusCode = statusCode.Value;
                switch (statusCode.Value)
                {
                    case 401:
                        ViewBag.Title = "未授權存取";
                        ViewBag.Message = "您尚未登入或登入狀態已過期，請重新登入後再繼續使用系統。";
                        ViewBag.LinkText = "重新登入";
                        ViewBag.LinkUrl = "/Account/Login";
                        break;
                    case 403:
                        ViewBag.Title = "權限不足";
                        ViewBag.Message = "您目前的帳號沒有存取此資源的權限。如需協助，請聯絡系統管理員。";
                        ViewBag.LinkText = "返回首頁";
                        ViewBag.LinkUrl = "/Dashboard/Index";
                        break;
                    case 404:
                        ViewBag.Title = "找不到頁面";
                        ViewBag.Message = "抱歉，您要尋找的頁面不存在，可能已被移除或網址輸入錯誤。";
                        ViewBag.LinkText = "返回首頁";
                        ViewBag.LinkUrl = "/Dashboard/Index";
                        break;
                    default:
                        ViewBag.Title = "系統發生錯誤";
                        ViewBag.Message = "系統發生未預期的錯誤，請稍後再試。如果問題持續發生，請聯絡系統管理員。";
                        ViewBag.LinkText = "返回首頁";
                        ViewBag.LinkUrl = "/Dashboard/Index";
                        break;
                }
            }
            else
            {
                ViewBag.Title = "系統發生錯誤";
                ViewBag.Message = "系統發生未預期的錯誤，請稍後再試。如果問題持續發生，請聯絡系統管理員。";
                ViewBag.LinkText = "返回首頁";
                ViewBag.LinkUrl = "/Dashboard/Index";
            }

            return View(new ErrorViewModel { RequestId = requestId });
        }
    }
}
