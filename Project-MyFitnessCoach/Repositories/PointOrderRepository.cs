using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Models.Repositories
{
    public interface IPointOrderRepository
    {
        Task<List<PointOrderDto>> GetAllAsync(int? status, string searchString);
        Task<PointOrderDto> GetByIdAsync(int id);
        Task<PointOrder> GetEntityByIdAsync(int id);
        Task UpdateStatusAsync(int id, int newStatus);
        Task SaveChangesAsync();
        Task<AverageTicketSizeDto> GetAverageTicketSizeAsync(DateTime? startDate, DateTime? endDate);
    }

    public class PointOrderRepository : IPointOrderRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public PointOrderRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public async Task<AverageTicketSizeDto> GetAverageTicketSizeAsync(DateTime? startDate, DateTime? endDate)
        {
            var query = _context.PointOrders.Where(p => p.Status == 1).AsQueryable();

            if (startDate.HasValue) query = query.Where(p => p.CreateAt >= startDate.Value);
            if (endDate.HasValue) query = query.Where(p => p.CreateAt <= endDate.Value);

            var result = await query.Select(p => new { p.DiscountedPrice })
                .ToListAsync();

            var totalRevenue = result.Sum(r => r.DiscountedPrice);
            var totalCount = result.Count;

            return new AverageTicketSizeDto
            {
                TotalRevenue = totalRevenue,
                TotalOrderCount = totalCount,
                AverageTicketSize = totalCount > 0 ? totalRevenue / totalCount : 0,
                CalculationDate = DateTime.Now
            };
        }

        public async Task<List<PointOrderDto>> GetAllAsync(int? status, string searchString)
        {
            var query = _context.PointOrders
                .Include(p => p.Member)
                .ThenInclude(m => m.User)
                .AsQueryable();

            if (status.HasValue)
            {
                query = query.Where(p => p.Status == status.Value);
            }

            if (!string.IsNullOrEmpty(searchString))
            {
                query = query.Where(p => p.Member.User.UserName.Contains(searchString));
            }

            return await query.OrderByDescending(p => p.CreateAt)
                .Select(p => new PointOrderDto
                {
                    Id = p.Id,
                    MemberId = p.MemberId,
                    MemberName = p.Member.User.UserName,
                    CreateAt = p.CreateAt,
                    PointQty = p.PointQty,
                    OriginalPrice = p.OriginalPrice,
                    DiscountedPrice = p.DiscountedPrice,
                    Status = p.Status
                }).ToListAsync();
        }

        public async Task<PointOrderDto> GetByIdAsync(int id)
        {
            var p = await _context.PointOrders
                .Include(p => p.Member)
                .ThenInclude(m => m.User)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (p == null) return null;

            return new PointOrderDto
            {
                Id = p.Id,
                MemberId = p.MemberId,
                MemberName = p.Member.User.UserName,
                CreateAt = p.CreateAt,
                PointQty = p.PointQty,
                OriginalPrice = p.OriginalPrice,
                DiscountedPrice = p.DiscountedPrice,
                Status = p.Status
            };
        }

        public async Task<PointOrder> GetEntityByIdAsync(int id)
        {
            return await _context.PointOrders
                .Include(o => o.Member)
                .ThenInclude(m => m.UserWallet)
                .FirstOrDefaultAsync(o => o.Id == id);
        }

        public async Task UpdateStatusAsync(int id, int newStatus)
        {
            var order = await _context.PointOrders.FindAsync(id);
            if (order != null)
            {
                order.Status = newStatus;
                await _context.SaveChangesAsync();
            }
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
