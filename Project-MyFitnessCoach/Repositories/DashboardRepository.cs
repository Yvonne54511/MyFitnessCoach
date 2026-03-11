using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IDashboardRepository
    {
        int GetTotalUsers();
        int GetActiveUsers();
        int GetPendingUsers();
        int GetActiveRoles();
        int GetActiveFunctions();
        int GetActiveInstructors();
    }

    public class DashboardRepository : IDashboardRepository
    {
        private readonly MyFitnessCoachDbContext _db;

        public DashboardRepository(MyFitnessCoachDbContext db)
        {
            _db = db;
        }

        public int GetTotalUsers() => _db.Users.Count();
        public int GetActiveUsers() => _db.Users.Count(x => x.IsActive);
        public int GetPendingUsers() => _db.Users.Count(x => !x.IsConfirmed);
        public int GetActiveRoles() => _db.Roles.Count(x => x.IsActive);
        public int GetActiveFunctions() => _db.Functions.Count(x => x.IsActive);
        public int GetActiveInstructors() => _db.Instructors.Count(x => x.IsActive);
    }
}
