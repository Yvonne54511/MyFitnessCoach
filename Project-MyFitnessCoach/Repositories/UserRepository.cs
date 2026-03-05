using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Repositories
{
	
	public class UserRepository
	{
		private readonly MyFitnessCoachDbContext _context;

		public UserRepository(MyFitnessCoachDbContext context)
		{
			this._context = context;
		}


	}
}
