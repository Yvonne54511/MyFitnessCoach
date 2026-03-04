using Microsoft.AspNetCore.Mvc;

namespace Project_MyFitnessCoach.Controllers
{
	public class UsersController : Controller
	{
		
		public IActionResult Login()
		{
			return View();
		}
	}
}
