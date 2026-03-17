using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IInstructorWalletRepository
    {
        Task<InstructorWallet?> GetByInstructorIdAsync(int instructorId);
        Task UpdateAsync(InstructorWallet wallet);
    }

    public class InstructorWalletRepository : IInstructorWalletRepository
    {
        private readonly MyFitnessCoachDbContext _db;

        public InstructorWalletRepository(MyFitnessCoachDbContext db)
        {
            _db = db;
        }

        public async Task<InstructorWallet?> GetByInstructorIdAsync(int instructorId)
        {
            return await _db.InstructorWallets
                .Include(w => w.Instructor)
                .ThenInclude(i => i.User)
                .FirstOrDefaultAsync(w => w.InstructorId == instructorId);
        }

        public async Task UpdateAsync(InstructorWallet wallet)
        {
            _db.InstructorWallets.Update(wallet);
            await _db.SaveChangesAsync();
        }
    }
}
