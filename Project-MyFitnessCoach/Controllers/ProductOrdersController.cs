using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models.Services;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.ViewModels;
using System.Threading.Tasks;
using System.Linq;
using Project_MyFitnessCoach.Models.Infra;

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
                TotalOrdersThisMonth = dto.TotalOrdersThisMonth, //本月總訂單數
                TotalOrdersChangePercentage = dto.TotalOrdersChangePercentage, //訂單成長率
                PendingShipmentCount = dto.PendingShipmentCount, //待處理訂單總數
                PendingShipmentChangePercentage = dto.PendingShipmentChangePercentage,//待處理訂單占比
                DisputedCount = dto.DisputedCount, //爭議與退貨訂單總數
                DisputedChangePercentage = dto.DisputedChangePercentage, //爭議與退貨訂單占比
				OrderTrends = (dto.OrderTrends ?? new List<OrderTrendDto>()).Select(t => new OrderTrendViewModel //給圖表用的linq日期與數量
                {
                    Date = t.Date,
                    Count = t.Count
                }).ToList(),
                CityDistributions = (dto.CityDistributions ?? new List<CityDistributionDto>()).Select(c => new CityDistributionViewModel
                {
                    City = c.City,
                    Count = c.Count
                }).ToList(),
                CategoryRankings = (dto.CategoryRankings ?? new List<CategoryRankingDto>()).Select(c => new CategoryRankingViewModel
                {
                    CategoryName = c.CategoryName,
                    TotalSold = c.TotalSold
                }).ToList(),
                TodayOrders = dto.TodayOrders.Select(o => new TodayOrderViewModel
                {
                    Id = o.Id,
                    MemberName = o.MemberName,
                    CreateAt = o.CreateAt,
                    FinalAmount = o.OriginalAmount - o.DiscountAmount,
                    Status = o.Status
                }).ToList(),
                PendingOrders = dto.PendingOrders.Select(o => new TodayOrderViewModel
                {
                    Id = o.Id,
                    MemberName = o.MemberName,
                    CreateAt = o.CreateAt,
                    FinalAmount = o.OriginalAmount - o.DiscountAmount,
                    Status = o.Status
                }).ToList()
            };

            return View(viewModel);
        }

        // GET: ProductOrders/MemberAllOrders/5
        public async Task<IActionResult> MemberAllOrders(int? id) //用來看會員目前的全部訂單
        {
            // 如果沒傳 ID，暫時預設為 1 (測試用)
            int memberId = id ?? 1;

            var ordersDto = await _service.GetByMemberIdAsync(memberId);
            
            var viewModel = ordersDto.Select(dto => new ProductOrderViewModel
            {
                Id = dto.Id,
                MemberName = dto.MemberName,
                CreateAt = dto.CreateAt,
                OriginalAmount = dto.OriginalAmount,
                DiscountAmount = dto.DiscountAmount,
                Status = dto.Status,
                OrderDetails = dto.OrderDetails.Select(d => new ProductOrderDetailViewModel
                {
                    ProductName = d.ProductName,
                    UnitPrice = d.UnitPrice,
                    Qty = d.Qty,
                    SubTotal = d.SubTotal,
                    ImageUrl = d.ImageUrl
                }).ToList()
            }).ToList();

            ViewBag.MemberId = memberId;
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
