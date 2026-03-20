using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Repositories;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services 
{ 
    public interface IInstructorWalletService
    {
        Task<InstructorWalletDto?> GetWalletByInstructorIdAsync(int instructorId);
        Task<List<InstructorWalletExportDto>> GetAllWalletDetailsForExportAsync();
        Task<bool> AddSalaryEntryAsync(int instructorId, decimal amount, string note, string category = "月薪與加給");
    }

    public class InstructorWalletService : IInstructorWalletService
    {
        private readonly IInstructorWalletRepository _walletRepository;

        public InstructorWalletService(IInstructorWalletRepository walletRepository)
        {
            _walletRepository = walletRepository;
        }

        public async Task<bool> AddSalaryEntryAsync(int instructorId, decimal amount, string note, string category = "月薪與加給")
        {
            var wallet = await _walletRepository.GetByInstructorIdAsync(instructorId);
            if (wallet == null) return false;

            // 1. 增加餘額
            wallet.CurrentBalance += (int)amount; 
            wallet.LastUpdated = DateTime.Now;

            // 2. 新增入帳明細
            var detail = new Project_MyFitnessCoach.Models.EfModels.InstructorWalletDetail
            {
                InstructorWalletId = wallet.Id,
                SalaryDate = DateTime.Now.ToString("yyyy-MM-dd"), 
                TotalAmount = amount,
                Category = category,
                CreatedAt = DateTime.Now
            };

            wallet.InstructorWalletDetails.Add(detail);

            await _walletRepository.UpdateAsync(wallet);
            return true;
        }


        public async Task<InstructorWalletDto?> GetWalletByInstructorIdAsync(int instructorId)
        {
            var wallet = await _walletRepository.GetByInstructorIdAsync(instructorId);
            if (wallet == null) return null;

            return new InstructorWalletDto
            {
                Id = wallet.Id,
                InstructorId = wallet.InstructorId,
                InstructorName = wallet.Instructor.User.UserName,
                CurrentBalance = wallet.CurrentBalance,
                LastUpdated = wallet.LastUpdated,
                Details = wallet.InstructorWalletDetails
                    .OrderByDescending(d => d.CreatedAt)
                    .Select(d => new InstructorWalletDetailDto
                    {
                        Id = d.Id,
                        SalaryDate = d.SalaryDate,
                        TotalAmount = d.TotalAmount,
                        Category = d.Category,
                        CreatedAt = d.CreatedAt
                    }).ToList()
            };
        }

        public async Task<List<InstructorWalletExportDto>> GetAllWalletDetailsForExportAsync()
        {
            var details = await _walletRepository.GetAllDetailsAsync();
            return details.Select(d => new InstructorWalletExportDto
            {
                InstructorName = d.InstructorWallet.Instructor.User.UserName,
                SalaryDate = d.SalaryDate,
                TotalAmount = d.TotalAmount,
                Category = d.Category
            }).ToList();
        }
    }
}
