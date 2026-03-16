using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.Repositories;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Models.Services
{
    public interface IPointOrderService
    {
        Task<List<PointOrderDto>> GetAllAsync(int? status, string searchString);
        Task<PointOrderDto> GetByIdAsync(int id);
        Task<bool> ApproveOrderAsync(int id);
        Task<bool> UpdateStatusAsync(int id, int newStatus);
        Task<bool> RefundReservationAsync(int reserveOrderId);
        Task<AverageTicketSizeDto> CalculateAverageTicketSizeAsync(DateTime? startDate = null, DateTime? endDate = null);
    }

    public class PointOrderService : IPointOrderService
    {
        private readonly IPointOrderRepository _repository;
        private readonly MyFitnessCoachDbContext _context;

        public PointOrderService(IPointOrderRepository repository, MyFitnessCoachDbContext context)
        {
            _repository = repository;
            _context = context;
        }

        public async Task<AverageTicketSizeDto> CalculateAverageTicketSizeAsync(DateTime? startDate = null, DateTime? endDate = null)
        {
            if (startDate > endDate)
            {
                throw new ArgumentException("開始日期不能晚於結束日期");
            }

            return await _repository.GetAverageTicketSizeAsync(startDate, endDate);
        }

        public async Task<List<PointOrderDto>> GetAllAsync(int? status, string searchString)
        {
            return await _repository.GetAllAsync(status, searchString);
        }

        public async Task<PointOrderDto> GetByIdAsync(int id)
        {
            return await _repository.GetByIdAsync(id);
        }

        public async Task<bool> ApproveOrderAsync(int id)
        {
            var order = await _repository.GetEntityByIdAsync(id);
            if (order == null || order.Status != 0) return false; // 只有待付款(0)能審核

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 1. 更新訂單狀態為已完成(1)
                order.Status = 1;

                // 2. 更新會員錢包
                var wallet = order.Member.UserWallet;
                if (wallet == null)
                {
                    wallet = new UserWallet
                    {
                        MemberId = order.MemberId,
                        CurrentBalance = 0,
                        LastUpdated = DateTime.Now
                    };
                    _context.UserWallets.Add(wallet);
                    await _context.SaveChangesAsync(); // 先存檔取得 wallet ID
                }

                wallet.CurrentBalance += order.PointQty;
                wallet.LastUpdated = DateTime.Now;

                // 3. 寫入流水帳紀錄
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
                return true;
            }
            catch
            {
                await transaction.RollbackAsync();
                return false;
            }
        }

        public async Task<bool> UpdateStatusAsync(int id, int newStatus)
        {
            // 這裡可以加入爭議處理或手動調整的邏輯
            var order = await _repository.GetEntityByIdAsync(id);
            if (order == null) return false;

            order.Status = newStatus;
            await _repository.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RefundReservationAsync(int reserveOrderId)
        {
            var reserveOrder = await _context.ReserveOrders
                .Include(ro => ro.Member)
                .ThenInclude(m => m.UserWallet)
                .FirstOrDefaultAsync(ro => ro.Id == reserveOrderId);

            if (reserveOrder == null || reserveOrder.Status == "Cancelled") return false;

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 1. 更新預約單狀態
                reserveOrder.Status = "Cancelled";

                // 2. 退點
                var wallet = reserveOrder.Member.UserWallet;
                int refundAmount = (int)reserveOrder.Price; // 假設點數與金額 1:1

                if (wallet != null)
                {
                    wallet.CurrentBalance += refundAmount;
                    wallet.LastUpdated = DateTime.Now;

                    // 3. 寫入流水帳
                    var record = new PointsRecordDetail
                    {
                        PointOrderId = 0, // 非儲值產生的紀錄
                        UserWalletId = wallet.Id,
                        CreateAt = DateTime.Now,
                        PointAmount = refundAmount,
                        MerchandiseCategory = "Refund",
                        ReserveOrderId = reserveOrderId
                    };
                    _context.PointsRecordDetails.Add(record);
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                return true;
            }
            catch
            {
                await transaction.RollbackAsync();
                return false;
            }
        }
    }
}
