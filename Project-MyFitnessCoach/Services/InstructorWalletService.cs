using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Repositories;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public interface IInstructorWalletService
    {
        Task<InstructorWalletDto?> GetWalletByInstructorIdAsync(int instructorId);
    }

    public class InstructorWalletService : IInstructorWalletService
    {
        private readonly IInstructorWalletRepository _walletRepository;

        public InstructorWalletService(IInstructorWalletRepository walletRepository)
        {
            _walletRepository = walletRepository;
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
                LastUpdated = wallet.LastUpdated
            };
        }
    }
}
