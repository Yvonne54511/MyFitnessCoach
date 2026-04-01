using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IInstructorWalletRepository
    {
        Task<InstructorWallet?> GetByInstructorIdAsync(int instructorId);
        Task<List<InstructorWalletDetail>> GetAllDetailsAsync();
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
                .Include(w => w.InstructorWalletDetails)
                .FirstOrDefaultAsync(w => w.InstructorId == instructorId);
        }

        public async Task<List<InstructorWalletDetail>> GetAllDetailsAsync()
        {
            return await _db.InstructorWalletDetails
                .Include(d => d.InstructorWallet)
                .ThenInclude(w => w.Instructor)
                .ThenInclude(i => i.User)
                .OrderByDescending(d => d.SalaryDate)
                .ThenBy(d => d.InstructorWallet.Instructor.User.UserName)
                .ToListAsync();
        }

        public async Task UpdateAsync(InstructorWallet wallet)
        {
            _db.InstructorWallets.Update(wallet);
            await _db.SaveChangesAsync();
        }
    }
}
