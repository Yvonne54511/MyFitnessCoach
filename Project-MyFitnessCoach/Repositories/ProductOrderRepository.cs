using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IProductOrderRepository
    {
        Task<List<ProductOrderDto>> GetAllAsync(int? status, string searchString);
        Task<ProductOrderDto> GetByIdAsync(int id);
        Task UpdateStatusAsync(int id, int newStatus);
        Task DeleteAsync(int id);
        bool Exists(int id);
        Task<ProductOrderDashboardDto> GetDashboardDataAsync();
    }

    public class ProductOrderRepository : IProductOrderRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public ProductOrderRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public async Task<ProductOrderDashboardDto> GetDashboardDataAsync()
        {
            var now = DateTime.Now;
            var startOfMonth = new DateTime(now.Year, now.Month, 1);
            var startOfLastMonth = startOfMonth.AddMonths(-1);
            var endOfLastMonth = startOfMonth.AddDays(-1);

            // 本月與上月訂單量
            var totalThisMonth = await _context.ProductOrders.CountAsync(o => o.CreateAt >= startOfMonth);
            var totalLastMonth = await _context.ProductOrders.CountAsync(o => o.CreateAt >= startOfLastMonth && o.CreateAt <= endOfLastMonth);
            
            // 待出貨 (Status = 1)
            var pendingThisMonth = await _context.ProductOrders.CountAsync(o => o.Status == 1 && o.CreateAt >= startOfMonth);
            var pendingLastMonth = await _context.ProductOrders.CountAsync(o => o.Status == 1 && o.CreateAt >= startOfLastMonth && o.CreateAt <= endOfLastMonth);
            
            // 爭議中/退貨申請 (Status = 4)
            var disputedThisMonth = await _context.ProductOrders.CountAsync(o => o.Status == 4 && o.CreateAt >= startOfMonth);
            var disputedLastMonth = await _context.ProductOrders.CountAsync(o => o.Status == 4 && o.CreateAt >= startOfLastMonth && o.CreateAt <= endOfLastMonth);

            // 計算百分比變動
            double CalculateChange(int current, int previous)
            {
                if (previous == 0) return current > 0 ? 100 : 0;
                return Math.Round((double)(current - previous) / previous * 100, 1);
            }

            // 趨勢圖 (最近 14 天)
            var startDate = now.AddDays(-13).Date;
            var trendData = await _context.ProductOrders
                .Where(o => o.CreateAt >= startDate)
                .GroupBy(o => o.CreateAt.Date)
                .Select(g => new { Date = g.Key, Count = g.Count() })
                .ToListAsync();

            var trends = new List<OrderTrendDto>();
            for (int i = 0; i < 14; i++)
            {
                var date = startDate.AddDays(i);
                var count = trendData.FirstOrDefault(d => d.Date == date)?.Count ?? 0;
                trends.Add(new OrderTrendDto { Date = date.ToString("M/d"), Count = count });
            }

            // 縣市分布 (取 Address 前 3 個字)
            var cityData = await _context.ProductOrders
                .Where(o => !string.IsNullOrEmpty(o.Address))
                .Select(o => o.Address.Substring(0, 3))
                .GroupBy(city => city)
                .Select(g => new CityDistributionDto { City = g.Key, Count = g.Count() })
                .OrderByDescending(g => g.Count)
                .Take(5)
                .ToListAsync();

            // 商品類別排行 (透過明細與產品關聯)
            var categoryRankings = await _context.ProductOrderDetails
                .Include(d => d.Product)
                .ThenInclude(p => p.Category)
                .GroupBy(d => d.Product.Category.CategoryName)
                .Select(g => new CategoryRankingDto
                {
                    CategoryName = g.Key ?? "未分類",
                    TotalSold = g.Sum(d => d.Qty)
                })
                .OrderByDescending(g => g.TotalSold)
                .Take(5)
                .ToListAsync();

            return new ProductOrderDashboardDto
            {
                TotalOrdersThisMonth = totalThisMonth,
                TotalOrdersChangePercentage = CalculateChange(totalThisMonth, totalLastMonth),
                PendingShipmentCount = await _context.ProductOrders.CountAsync(o => o.Status == 1), // 待出貨不限月份
                PendingShipmentChangePercentage = CalculateChange(pendingThisMonth, pendingLastMonth),
                DisputedCount = await _context.ProductOrders.CountAsync(o => o.Status == 4), // 爭議中不限月份
                DisputedChangePercentage = CalculateChange(disputedThisMonth, disputedLastMonth),
                OrderTrends = trends,
                CityDistributions = cityData,
                CategoryRankings = categoryRankings
            };
        }

        public async Task<List<ProductOrderDto>> GetAllAsync(int? status, string searchString)
        {
            var query = _context.ProductOrders
                .Include(p => p.Member)
                .ThenInclude(m => m.User)
                .AsQueryable();

            if (status.HasValue)
            {
                query = query.Where(p => p.Status == status.Value);
            }

            if (!string.IsNullOrEmpty(searchString))
            {
                query = query.Where(p => p.Member.User.UserName.Contains(searchString) || 
                                       p.Receiver.Contains(searchString));
            }

            return await query.OrderByDescending(p => p.CreateAt)
                .Select(p => new ProductOrderDto
                {
                    Id = p.Id,
                    MemberId = p.MemberId,
                    MemberName = p.Member.User.UserName,
                    CreateAt = p.CreateAt,
                    OriginalAmount = p.OriginalAmount,
                    DiscountAmount = p.DiscountAmount,
                    Receiver = p.Receiver,
                    Status = p.Status
                }).ToListAsync();
        }

        public async Task<ProductOrderDto> GetByIdAsync(int id)
        {
            var p = await _context.ProductOrders
                .Include(p => p.Member)
                .ThenInclude(m => m.User)
                .Include(p => p.ProductOrderDetails)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (p == null) return null;

            return new ProductOrderDto
            {
                Id = p.Id,
                MemberId = p.MemberId,
                MemberName = p.Member.User.UserName,
                CreateAt = p.CreateAt,
                OriginalAmount = p.OriginalAmount,
                DiscountAmount = p.DiscountAmount,
                Receiver = p.Receiver,
                Address = p.Address,
                Mobile = p.Mobile,
                TaxNumber = p.TaxNumber,
                Status = p.Status,
                Memo = p.Memo,
                OrderDetails = p.ProductOrderDetails.Select(d => new ProductOrderDetailDto
                {
                    Id = d.Id,
                    ProductId = d.ProductId,
                    ProductName = d.ProductName,
                    UnitPrice = d.UnitPrice,
                    Qty = d.Qty,
                    SubTotal = d.SubTotal,
                    ImageUrl = d.ImageUrl,
                    Memo = d.Memo
                }).ToList()
            };
        }

        public async Task UpdateStatusAsync(int id, int newStatus)
        {
            var order = await _context.ProductOrders.FindAsync(id);
            if (order != null)
            {
                order.Status = newStatus;
                await _context.SaveChangesAsync();
            }
        }

        public async Task DeleteAsync(int id)
        {
            var order = await _context.ProductOrders.FindAsync(id);
            if (order != null)
            {
                order.Status = 3;
                await _context.SaveChangesAsync();
            }
        }

        public bool Exists(int id)
        {
            return _context.ProductOrders.Any(e => e.Id == id);
        }
    }
}
