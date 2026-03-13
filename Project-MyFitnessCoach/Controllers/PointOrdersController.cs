using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Controllers
{
    public class PointOrdersController : Controller
    {
        private readonly MyFitnessCoachDbContext _context;

        public PointOrdersController(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        // 點數儲值首頁 (列出所有儲值紀錄)
        public async Task<IActionResult> Index()
        {
            var pointOrders = await _context.PointOrders
                .Include(p => p.PointsRecordDetails)
                .OrderByDescending(p => p.CreateAt)
                .ToListAsync();
            return View(pointOrders);
        }

        // 點數數據概覽
        public async Task<IActionResult> DashBoard()
        {
            var now = DateTime.Now;
            var today = now.Date;
            var yesterday = today.AddDays(-1);
            var firstDayOfMonth = new DateTime(now.Year, now.Month, 1);
            var firstDayOfLastMonth = firstDayOfMonth.AddMonths(-1);
            var lastDayOfLastMonth = firstDayOfMonth.AddDays(-1);

            // 1. KPI 數據
            var todayRevenue = await _context.PointOrders
                .Where(o => o.CreateAt >= today && o.Status == 1)
                .SumAsync(o => (decimal?)o.DiscountedPrice) ?? 0;
            
            var yesterdayRevenue = await _context.PointOrders
                .Where(o => o.CreateAt >= yesterday && o.CreateAt < today && o.Status == 1)
                .SumAsync(o => (decimal?)o.DiscountedPrice) ?? 0;

            var monthTotal = await _context.PointOrders
                .Where(o => o.CreateAt >= firstDayOfMonth && o.Status == 1)
                .SumAsync(o => (decimal?)o.DiscountedPrice) ?? 0;
            
            var lastMonthTotal = await _context.PointOrders
                .Where(o => o.CreateAt >= firstDayOfLastMonth && o.CreateAt <= lastDayOfLastMonth && o.Status == 1)
                .SumAsync(o => (decimal?)o.DiscountedPrice) ?? 0;

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
                PlanSales = popularPlans.Select(p => p.Count).ToList()
            };

            return View(viewModel);
        }

        // 儲值頁面
        public IActionResult Recharge()
        {
            return View();
        }

        // 處理儲值請求
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
                // 3. 建立 PointOrder
                var pointOrder = new PointOrder
                {
                    MemberId = memberId,
                    CreateAt = DateTime.Now,
                    PointQty = pointAmount,
                    OriginalPrice = price,
                    DiscountedPrice = price // 暫不考慮折扣
                };
                _context.PointOrders.Add(pointOrder);
                await _context.SaveChangesAsync();

                // 4. 更新 UserWallet
                var wallet = member.UserWallet;
                if (wallet == null)
                {
                    // 若無錢包則建立一個 (理論上註冊時應已建立)
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

                // 5. 記錄點數增減 (PointsRecordDetail)
                var record = new PointsRecordDetail
                {
                    PointOrderId = pointOrder.Id,
                    UserWalletId = wallet.Id,
                    CreateAt = DateTime.Now,
                    PointAmount = pointAmount,
                    MerchandiseCategory = "Recharge", // 儲值
                    ReserveOrderId = null
                };
                _context.PointsRecordDetails.Add(record);

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                TempData["SuccessMessage"] = $"儲值成功！已存入 {pointAmount} 點。";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                ModelState.AddModelError("", $"儲值過程發生錯誤：{ex.Message}");
                return View();
            }
        }
    }
}
