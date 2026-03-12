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
    }

    public class ProductOrderRepository : IProductOrderRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public ProductOrderRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
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
