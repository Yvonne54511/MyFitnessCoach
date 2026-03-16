using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.Services;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.ViewModels;
using System.Threading.Tasks;
using System.Linq;

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
        [Function("edit_ProductOrders")]
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
            var dto = await _service.GetDashboardDataAsync();
            
            var viewModel = new ProductOrderDashboardViewModel
            {
                TotalOrdersThisMonth = dto.TotalOrdersThisMonth,
                TotalOrdersChangePercentage = dto.TotalOrdersChangePercentage,
                PendingShipmentCount = dto.PendingShipmentCount,
                PendingShipmentChangePercentage = dto.PendingShipmentChangePercentage,
                DisputedCount = dto.DisputedCount,
                DisputedChangePercentage = dto.DisputedChangePercentage,
                OrderTrends = dto.OrderTrends.Select(t => new OrderTrendViewModel
                {
                    Date = t.Date,
                    Count = t.Count
                }).ToList(),
                CityDistributions = dto.CityDistributions.Select(c => new CityDistributionViewModel
                {
                    City = c.City,
                    Count = c.Count
                }).ToList(),
                CategoryRankings = dto.CategoryRankings.Select(c => new CategoryRankingViewModel
                {
                    CategoryName = c.CategoryName,
                    TotalSold = c.TotalSold
                }).ToList()
            };

            return View(viewModel);
        }

        // GET: ProductOrders/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var dto = await _service.GetByIdAsync(id.Value);

            if (dto == null)
            {
                return NotFound();
            }

            var viewModel = new ProductOrderViewModel
            {
                Id = dto.Id,
                MemberId = dto.MemberId,
                MemberName = dto.MemberName,
                CreateAt = dto.CreateAt,
                OriginalAmount = dto.OriginalAmount,
                DiscountAmount = dto.DiscountAmount,
                Receiver = dto.Receiver,
                Address = dto.Address,
                Mobile = dto.Mobile,
                TaxNumber = dto.TaxNumber?.ToString(),
                Status = dto.Status,
                Memo = dto.Memo,
                OrderDetails = dto.OrderDetails.Select(d => new ProductOrderDetailViewModel
                {
                    Id = d.Id,
                    ProductOrderId = d.ProductOrderId,
                    ProductId = d.ProductId,
                    ProductName = d.ProductName,
                    UnitPrice = d.UnitPrice,
                    Qty = d.Qty,
                    SubTotal = d.SubTotal,
                    DiscountedPrice = d.DiscountedPrice,
                    ImageUrl = d.ImageUrl,
                    Memo = d.Memo
                }).ToList()
            };

            return View(viewModel);
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
