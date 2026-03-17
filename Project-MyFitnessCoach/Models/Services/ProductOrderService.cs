using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Repositories;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Models.Services
{
    public class ProductOrderService
    {
        private readonly IProductOrderRepository _repository;

        public ProductOrderService(IProductOrderRepository repository)
        {
            _repository = repository;
        }

        public async Task<List<ProductOrderDto>> GetAllAsync(int? status, string searchString)
        {
            return await _repository.GetAllAsync(status, searchString);
        }

        public async Task<ProductOrderDashboardDto> GetDashboardDataAsync()
        {
            return await _repository.GetDashboardDataAsync();
        }

        public async Task<ProductOrderDto> GetByIdAsync(int id)
        {
            return await _repository.GetByIdAsync(id);
        }

        public async Task<List<ProductOrderDto>> GetByMemberIdAsync(int memberId)
        {
            return await _repository.GetByMemberIdAsync(memberId);
        }

        public async Task UpdateStatusAsync(int id, int newStatus)
        {
            // 在此可以加入商業邏輯，例如：
            // 只有待處理的訂單才能變更為已出貨
            // 或者更新狀態時發送通知信
            await _repository.UpdateStatusAsync(id, newStatus);
        }

        public async Task DeleteAsync(int id)
        {
            await _repository.DeleteAsync(id);
        }

        public bool Exists(int id)
        {
            return _repository.Exists(id);
        }
    }
}
