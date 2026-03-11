using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;

namespace Project_MyFitnessCoach.Repos
{
	public interface ILoginRepository
	{
		Task<User> GetByAccountAsync(string account);
	}

	public class LoginRepository : ILoginRepository
	{
		private readonly ResRevContext _context;
		public LoginRepository(ResRevContext context)
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
