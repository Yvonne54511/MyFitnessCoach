using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repositories
{
	public interface ILoginRepository
	{
		Task<User> GetByAccountAsync(string account);
	}

	public class LoginRepository : ILoginRepository
	{
		private readonly MyFitnessCoachDbContext _context;
		public LoginRepository(MyFitnessCoachDbContext context)
		{
			_context = context;
		}

		public async Task<User> GetByAccountAsync(string account)
		{
			return await _context.Users
				.Include(u => u.Instructors)
				.Include(u => u.UserRoles)
					.ThenInclude(ur => ur.Role)
				.FirstOrDefaultAsync(u => u.Account == account);
		}
	}
}
