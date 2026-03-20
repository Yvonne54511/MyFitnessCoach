using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.Infra;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Models.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Controllers
{
    
    public class PointOrdersController : Controller
    {
        private readonly MyFitnessCoachDbContext _context;
        private readonly IPointOrderService _pointOrderService;

        public PointOrdersController(MyFitnessCoachDbContext context, IPointOrderService pointOrderService)
        {
            _context = context;
            _pointOrderService = pointOrderService;
        }

        // 點數儲值首頁 (列出所有儲值紀錄)
        [Function("edit_PlanOrders")]
        public async Task<IActionResult> Index()
        {
            var pointOrders = await _context.PointOrders
                .Include(p => p.Member).ThenInclude(m => m.User)
                .Include(p => p.PointsRecordDetails)
                .Include(p => p.TopUpPlan)
                .OrderByDescending(p => p.CreateAt)
                .ToListAsync();
            return View(pointOrders);
        }

        // 點數數據概覽
        [Function("edit_PlanOrders")]
        public async Task<IActionResult> Dashboard()
        {
            var now = DateTime.Now;
            var today = now.Date;
            var yesterday = today.AddDays(-1);
            var firstDayOfMonth = new DateTime(now.Year, now.Month, 1);
            var firstDayOfLastMonth = firstDayOfMonth.AddMonths(-1);
            var lastDayOfLastMonth = firstDayOfMonth.AddDays(-1);

            // 取得所有相關訂單資料一次性處理 (優化連線不穩)
            var orders = await _context.PointOrders
                .Where(o => o.CreateAt >= firstDayOfLastMonth && o.Status == 1)
                .Select(o => new { o.CreateAt, o.DiscountedPrice })
                .ToListAsync();

            // 1. KPI 數據 (從記憶體中篩選，減少 DB 負載)
            var todayRevenue = orders.Where(o => o.CreateAt >= today).Sum(o => (decimal?)o.DiscountedPrice) ?? 0;
            var yesterdayRevenue = orders.Where(o => o.CreateAt >= yesterday && o.CreateAt < today).Sum(o => (decimal?)o.DiscountedPrice) ?? 0;
            var monthTotal = orders.Where(o => o.CreateAt >= firstDayOfMonth).Sum(o => (decimal?)o.DiscountedPrice) ?? 0;
            var lastMonthTotal = orders.Where(o => o.CreateAt >= firstDayOfLastMonth && o.CreateAt <= lastDayOfLastMonth).Sum(o => (decimal?)o.DiscountedPrice) ?? 0;

            var totalCirculatingPoints = await _context.UserWallets.SumAsync(w => (int?)w.CurrentBalance) ?? 0;

            // 2. 儲值趨勢 (近 30 日)
            var last30Days = Enumerable.Range(0, 30)
                .Select(i => today.AddDays(-29 + i))
                .ToList();

            var trendData = await _context.PointOrders
                .Where(o => o.CreateAt >= today.AddDays(-29) && o.Status == 1)
                .GroupBy(o => o.CreateAt.Date)
                .Select(g => new
                {
                    Date = g.Key,
                    Actual = g.Sum(o => o.DiscountedPrice),
                    TotalPoints = g.Sum(o => o.PointQty)
                })
                .ToListAsync();

            var trendLabels = last30Days.Select(d => d.ToString("MM/dd")).ToList();
            var actualPaymentData = last30Days.Select(d => trendData.FirstOrDefault(t => t.Date == d)?.Actual ?? 0).ToList();
            var bonusPointsData = last30Days.Select(d => {
                var item = trendData.FirstOrDefault(t => t.Date == d);
                return item == null ? 0 : (item.TotalPoints - (int)item.Actual);
            }).ToList();

            // 3. 熱門儲值方案
            var popularPlans = await _context.PointOrders
                .GroupBy(o => o.PointQty)
                .Select(g => new
                {
                    Points = g.Key,
                    Count = g.Count()
                })
                .OrderByDescending(g => g.Count)
                .Take(5)
                .ToListAsync();

            // 4. 每月平均客單價走勢 (1-12月)
            var monthlyAverageTicketSizes = new List<decimal>();
            for (int month = 1; month <= 12; month++)
            {
                var start = new DateTime(now.Year, month, 1);
                var end = start.AddMonths(1).AddDays(-1);
                var avgDto = await _pointOrderService.CalculateAverageTicketSizeAsync(start, end);
                monthlyAverageTicketSizes.Add(avgDto.AverageTicketSize);
            }

            var viewModel = new PointOrderDashboardViewModel
            {
                TodayRevenue = todayRevenue,
                RevenueTrend = yesterdayRevenue == 0 ? 100 : Math.Round((double)(todayRevenue - yesterdayRevenue) / (double)yesterdayRevenue * 100, 1),
                MonthTotal = monthTotal,
                MonthComparison = lastMonthTotal == 0 ? 100 : Math.Round((double)(monthTotal - lastMonthTotal) / (double)lastMonthTotal * 100, 1),
                TotalCirculatingPoints = totalCirculatingPoints,
                TrendLabels = trendLabels,
                ActualPaymentData = actualPaymentData,
                BonusPointsData = bonusPointsData,
                PlanNames = popularPlans.Select(p => $"{p.Points} 點方案").ToList(),
                PlanSales = popularPlans.Select(p => p.Count).ToList(),
                MonthlyAverageTicketSizes = monthlyAverageTicketSizes
            };

            return View(viewModel);
        }

        // 會員點數總覽列表
        public async Task<IActionResult> PointRecords()
        {
            var wallets = await _context.UserWallets
                .Include(w => w.Member)
                .ThenInclude(m => m.User)
                .OrderBy(w => w.MemberId)
                .ToListAsync();

            var viewModel = wallets.Select(w => new PointOrderViewModel
            {
                Id = w.Id, // 使用錢包 ID 作為記錄 ID
                MemberId = w.MemberId,
                MemberName = w.Member.User.UserName,
                PointQty = (int)w.CurrentBalance, // 將目前餘額對應至 PointQty
                CreateAt = w.LastUpdated // 將最後更新時間對應至 CreateAt
            }).ToList();

            return View(viewModel);
        }

        // 儲值頁面
        public IActionResult Recharge()
        {
            return View();
        }

        // 點數儲值詳情
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null) return NotFound();

            var order = await _context.PointOrders
                .Include(p => p.Member).ThenInclude(m => m.User)
                .Include(p => p.TopUpPlan)
                .Include(p => p.PointsRecordDetails)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (order == null) return NotFound();

            var viewModel = new PointOrderViewModel
            {
                Id = order.Id,
                MemberId = order.MemberId,
                MemberName = order.Member.User.UserName,
                TopUpPlanId = order.TopUpPlanId,
                PlanName = order.TopUpPlan?.PlanName ?? "手動儲值",
                CreateAt = order.CreateAt,
                PointQty = order.PointQty,
                OriginalPrice = order.OriginalPrice,
                DiscountedPrice = order.DiscountedPrice,
                Status = order.Status,
                RecordDetails = order.PointsRecordDetails.Select(d => new PointsRecordDetailViewModel
                {
                    Id = d.Id,
                    PointOrderId = d.PointOrderId,
                    UserWalletId = d.UserWalletId,
                    CreateAt = d.CreateAt,
                    PointAmount = d.PointAmount,
                    MerchandiseCategory = d.MerchandiseCategory,
                    ReserveOrderId = d.ReserveOrderId
                }).ToList()
            };

            return View(viewModel);
        }

        // 處理儲值請求 (手動直接儲值)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Recharge(int memberId, int pointAmount, decimal price)
        {
            // 1. 驗證會員是否存在
            var member = await _context.Members
                .Include(m => m.User)
                .Include(m => m.UserWallet)
                .FirstOrDefaultAsync(m => m.Id == memberId);

            if (member == null)
            {
                ModelState.AddModelError("", "儲值失敗：找不到指定的會員。");
                return View();
            }

            // 2. 驗證金額與點數
            if (pointAmount <= 0 || price <= 0)
            {
                ModelState.AddModelError("", "儲值失敗：儲值點數與金額必須大於 0。");
                return View();
            }

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 3. 尋找匹配的儲值方案 (優化：根據點數與金額匹配對應的 PlanName)
                var matchingPlan = await _context.TopUpPlans
                    .FirstOrDefaultAsync(p => p.Points == pointAmount && p.Price == (decimal)price && p.IsActive);

                var pointOrder = new PointOrder
                {
                    MemberId = memberId,
                    TopUpPlanId = matchingPlan?.Id ?? 1, // 如果匹配到則使用該方案 ID，否則預設為手動儲值方案 (1)
                    CreateAt = DateTime.Now,
                    PointQty = pointAmount,
                    OriginalPrice = price,
                    DiscountedPrice = price,
                    Status = 1 
                };
                _context.PointOrders.Add(pointOrder);
                await _context.SaveChangesAsync();

                // 4. 更新 UserWallet
                var wallet = member.UserWallet;
                if (wallet == null)
                {
                    wallet = new UserWallet
                    {
                        MemberId = memberId,
                        CurrentBalance = 0,
                        LastUpdated = DateTime.Now
                    };
                    _context.UserWallets.Add(wallet);
                    await _context.SaveChangesAsync();
                }

                wallet.CurrentBalance += pointAmount;
                wallet.LastUpdated = DateTime.Now;
                _context.Entry(wallet).State = EntityState.Modified;

                // 5. 記錄點數增減 (PointsRecordDetail - 類別設為 Recharge)
                var record = new PointsRecordDetail
                {
                    PointOrderId = pointOrder.Id,
                    UserWalletId = wallet.Id,
                    CreateAt = DateTime.Now,
                    PointAmount = pointAmount,
                    MerchandiseCategory = "Recharge",
                    ReserveOrderId = null
                };
                _context.PointsRecordDetails.Add(record);

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                TempData["SuccessMessage"] = $"儲值成功！已為 {member.User.UserName} 存入 {pointAmount} 點。";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                ModelState.AddModelError("", $"儲值過程發生錯誤：{ex.Message}");
                return View();
            }
        }

        // 確認收款 (Status 0 -> 1)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CompletePayment(int id)
        {
            var order = await _context.PointOrders
                .Include(p => p.Member).ThenInclude(m => m.UserWallet)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (order == null) return NotFound();
            if (order.Status != 0)
            {
                TempData["ErrorMessage"] = "僅有待付款訂單可以執行確認收款。";
                return RedirectToAction(nameof(Details), new { id = id });
            }

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 1. 更新訂單狀態
                order.Status = 1;
                _context.Entry(order).State = EntityState.Modified;

                // 2. 更新錢包
                var wallet = order.Member.UserWallet;
                if (wallet == null)
                {
                    wallet = new UserWallet { MemberId = order.MemberId, CurrentBalance = 0, LastUpdated = DateTime.Now };
                    _context.UserWallets.Add(wallet);
                    await _context.SaveChangesAsync();
                }

                wallet.CurrentBalance += order.PointQty;
                wallet.LastUpdated = DateTime.Now;

                // 3. 記錄流水帳
                var record = new PointsRecordDetail
                {
                    PointOrderId = order.Id,
                    UserWalletId = wallet.Id,
                    CreateAt = DateTime.Now,
                    PointAmount = order.PointQty,
                    MerchandiseCategory = "Recharge"
                };
                _context.PointsRecordDetails.Add(record);

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                TempData["SuccessMessage"] = "收款確認成功，點數已存入會員錢包。";
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                TempData["ErrorMessage"] = $"確認收款失敗：{ex.Message}";
            }

            return RedirectToAction(nameof(Details), new { id = id });
        }

        // 同意取消儲值訂單
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CancelOrder(int id)
        {
            var order = await _context.PointOrders
                .Include(p => p.Member).ThenInclude(m => m.UserWallet)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (order == null) return NotFound();
            if (order.Status == 3)
            {
                TempData["ErrorMessage"] = "該訂單已被取消，不須重複操作。";
                return RedirectToAction(nameof(Details), new { id = id });
            }

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                int oldStatus = order.Status;
                
                // 1. 更新訂單狀態為「已取消」(3)
                order.Status = 3;
                _context.Entry(order).State = EntityState.Modified;

                var wallet = order.Member.UserWallet;
                if (wallet != null)
                {
                    // 2. 處理錢包退點 (僅當原狀態為已完成時才扣除餘額)
                    int refundAmount = 0;
                    if (oldStatus == 1)
                    {
                        refundAmount = -order.PointQty;
                        wallet.CurrentBalance += refundAmount; // 加負值 = 扣除
                        wallet.LastUpdated = DateTime.Now;
                        _context.Entry(wallet).State = EntityState.Modified;
                    }

                    // 3. 記錄取消異動 (無論原本是否完成，都必須記錄在流水帳)
                    var cancelRecord = new PointsRecordDetail
                    {
                        PointOrderId = order.Id,
                        UserWalletId = wallet.Id,
                        CreateAt = DateTime.Now,
                        PointAmount = refundAmount, // 已完成訂單為負值，待付款訂單為 0
                        MerchandiseCategory = "已取消",
                        ReserveOrderId = null
                    };
                    _context.PointsRecordDetails.Add(cancelRecord);
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                TempData["SuccessMessage"] = "訂單已成功取消，並同步更新點數紀錄。";
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                TempData["ErrorMessage"] = $"取消過程發生錯誤：{ex.Message}";
            }

            return RedirectToAction(nameof(Details), new { id = id });
        }
    }
}

    
