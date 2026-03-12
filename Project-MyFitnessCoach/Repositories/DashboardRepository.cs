using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using System.Collections.Generic;
using System.Linq;

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
        IEnumerable<InstructorRatingDto> GetInstructorRatings();
        GlobalRatingDto GetGlobalRating();
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

        public IEnumerable<InstructorRatingDto> GetInstructorRatings()
        {
            return _db.Instructors
                .Include(i => i.User)
                .Include(i => i.Reviews)
                .Select(i => new InstructorRatingDto
                {
                    InstructorId = i.Id,
                    InstructorName = i.User.UserName,
                    ImageUrl = i.ImageUrl,
                    TotalReviews = i.Reviews.Count(),
                    AverageRating = i.Reviews.Any() ? i.Reviews.Average(r => r.Rating) : 0,
                    Star5Count = i.Reviews.Count(r => r.Rating == 5),
                    Star4Count = i.Reviews.Count(r => r.Rating == 4),
                    Star3Count = i.Reviews.Count(r => r.Rating == 3),
                    Star2Count = i.Reviews.Count(r => r.Rating == 2),
                    Star1Count = i.Reviews.Count(r => r.Rating == 1)
                }).ToList();
        }

        public GlobalRatingDto GetGlobalRating()
        {
            var reviews = _db.Reviews.ToList();
            if (!reviews.Any()) return new GlobalRatingDto();

            return new GlobalRatingDto
            {
                TotalReviews = reviews.Count,
                AverageRating = reviews.Average(r => r.Rating),
                Star5Count = reviews.Count(r => r.Rating == 5),
                Star4Count = reviews.Count(r => r.Rating == 4),
                Star3Count = reviews.Count(r => r.Rating == 3),
                Star2Count = reviews.Count(r => r.Rating == 2),
                Star1Count = reviews.Count(r => r.Rating == 1)
            };
        }
    }
}
