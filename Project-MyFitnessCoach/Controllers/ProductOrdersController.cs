using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.Services;
using Project_MyFitnessCoach.Models.DTOs;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Controllers
{
    public class ProductOrdersController : Controller
    {
        private readonly ProductOrderService _service;

        public ProductOrdersController(ProductOrderService service)
        {
            _service = service;
        }

        // GET: ProductOrders
        public async Task<IActionResult> Index(int? status, string searchString)
        {
            var orders = await _service.GetAllAsync(status, searchString);
            
            ViewBag.CurrentStatus = status;
            ViewBag.CurrentSearch = searchString;

            return View(orders);
        }

        // GET: ProductOrders/Dashboard
        public async Task<IActionResult> Dashboard()
        {
            var data = await _service.GetDashboardDataAsync();
            return View(data);
        }

        // GET: ProductOrders/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var order = await _service.GetByIdAsync(id.Value);

            if (order == null)
            {
                return NotFound();
            }

            return View(order);
        }

        // POST: ProductOrders/UpdateStatus
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UpdateStatus(int id, int newStatus)
        {
            if (!_service.Exists(id))
            {
                return NotFound();
            }

            await _service.UpdateStatusAsync(id, newStatus);
            TempData["SuccessMessage"] = "訂單狀態已更新。";

            return RedirectToAction(nameof(Details), new { id = id });
        }

        // GET: ProductOrders/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var order = await _service.GetByIdAsync(id.Value);
            if (order == null)
            {
                return NotFound();
            }

            return View(order);
        }

        // POST: ProductOrders/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            if (!_service.Exists(id))
            {
                return NotFound();
            }

            await _service.DeleteAsync(id);
            TempData["SuccessMessage"] = "訂單已成功刪除。";
            return RedirectToAction(nameof(Index));
        }
    }
}
