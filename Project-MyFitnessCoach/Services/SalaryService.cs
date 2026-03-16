using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public interface ISalaryService
    {
        Task<List<SalaryInstructorViewModel>> GetInstructorsAsync();
        Task<SalaryDetailViewModel> GetSalaryDetailAsync(int instructorId, int year, int month, double monthlyPool = 0, double annualPool = 0);
        Task<SalaryRankingsViewModel> GetRankingsAsync();
    }

    public class SalaryService : ISalaryService
    {
        private readonly MyFitnessCoachDbContext _context;

        public SalaryService(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public async Task<SalaryRankingsViewModel> GetRankingsAsync()
        {
            var result = new SalaryRankingsViewModel();

            // 1. 預約最多 (Top Booked) - Based on Shifts where IsBooked is true
            result.TopBooked = await _context.Shifts
                .Where(s => s.IsBooked)
                .GroupBy(s => new { s.InstructorId, s.Instructor.User.UserName })
                .OrderByDescending(g => g.Count())
                .Take(3)
                .Select(g => new RankingItemViewModel
                {
                    InstructorId = g.Key.InstructorId,
                    InstructorName = g.Key.UserName,
                    Value = g.Count().ToString() + " 次"
                })
                .ToListAsync();

            // 2. 評分最高 (Top Rated) - Average rating from Reviews (not banned)
            result.TopRated = await _context.Reviews
                .Where(r => !r.IsBanned)
                .GroupBy(r => new { r.InstructorId, r.Instructor.User.UserName })
                .OrderByDescending(g => g.Average(r => r.Rating))
                .Take(3)
                .Select(g => new RankingItemViewModel
                {
                    InstructorId = g.Key.InstructorId,
                    InstructorName = g.Key.UserName,
                    Value = g.Average(r => r.Rating).ToString("F1") + " 分"
                })
                .ToListAsync();

            // 3. 好評最多 (Most Positive Reviews) - Count of Reviews with Rating >= 4
            result.MostPositiveReviews = await _context.Reviews
                .Where(r => !r.IsBanned && r.Rating >= 4)
                .GroupBy(r => new { r.InstructorId, r.Instructor.User.UserName })
                .OrderByDescending(g => g.Count())
                .Take(3)
                .Select(g => new RankingItemViewModel
                {
                    InstructorId = g.Key.InstructorId,
                    InstructorName = g.Key.UserName,
                    Value = g.Count().ToString() + " 則"
                })
                .ToListAsync();

            return result;
        }

        public async Task<List<SalaryInstructorViewModel>> GetInstructorsAsync()
        {
            return await _context.Instructors
                .Include(i => i.User)
                .Where(i => i.IsActive)
                .Select(i => new SalaryInstructorViewModel
                {
                    Id = i.Id,
                    Name = i.User.UserName,
                    ImageUrl = i.ImageUrl
                })
                .ToListAsync();
        }

        public async Task<SalaryDetailViewModel> GetSalaryDetailAsync(int instructorId, int year, int month, double monthlyPool = 0, double annualPool = 0)
        {
            var instructor = await _context.Instructors
                .Include(i => i.User)
                .FirstOrDefaultAsync(i => i.Id == instructorId);

            if (instructor == null) return null;

            var startDate = new DateOnly(year, month, 1);
            var endDate = startDate.AddMonths(1).AddDays(-1);
            var today = DateOnly.FromDateTime(DateTime.Today);

            // 1. Get filtered shifts
            var shifts = await _context.Shifts
                .Where(s => s.InstructorId == instructorId &&
                            s.ScheduleDate >= startDate &&
                            s.ScheduleDate <= endDate &&
                            s.IsBooked &&
                            s.ScheduleDate < today)
                .OrderBy(s => s.ScheduleDate)
                .ThenBy(s => s.TimeSlot)
                .Select(s => new SalaryShiftViewModel
                {
                    Date = s.ScheduleDate,
                    TimeSlot = s.TimeSlot,
                    IsBooked = s.IsBooked
                })
                .ToListAsync();

            // 2. Performance Metrics Calculation (Monthly)
            int bookingCount = await _context.Shifts
                .CountAsync(s => s.InstructorId == instructorId && s.IsBooked && s.ScheduleDate >= startDate && s.ScheduleDate <= endDate);
            var reviews = _context.Reviews
                .Where(r => r.InstructorId == instructorId && !r.IsBanned && r.CreatedAt.Year == year && r.CreatedAt.Month == month);
            double avgRating = await reviews.AnyAsync() ? await reviews.AverageAsync(r => r.Rating) : 0;
            int positiveCount = await reviews.CountAsync(r => r.Rating >= 4);

            // 2.1 Performance Metrics Calculation (Annual)
            int annualBookingCount = await _context.Shifts
                .CountAsync(s => s.InstructorId == instructorId && s.IsBooked && s.ScheduleDate.Year == year);
            var annualReviews = _context.Reviews
                .Where(r => r.InstructorId == instructorId && !r.IsBanned && r.CreatedAt.Year == year);
            double annualAvgRating = await annualReviews.AnyAsync() ? await annualReviews.AverageAsync(r => r.Rating) : 0;
            int annualPositiveCount = await annualReviews.CountAsync(r => r.Rating >= 4);

            // 2.2 Monthly Trend
            var monthlyTrends = new List<int>();
            for (int m = 1; m <= 12; m++)
            {
                int count = await _context.Shifts
                    .CountAsync(s => s.InstructorId == instructorId && s.IsBooked && s.ScheduleDate.Year == year && s.ScheduleDate.Month == m);
                monthlyTrends.Add(count);
            }

            // 3. Global Scores Calculation
            var allInstructors = await _context.Instructors.Where(i => i.IsActive).Select(i => i.Id).ToListAsync();
            double globalTotalScore = 0;
            double annualGlobalTotalScore = 0;

            foreach (var id in allInstructors)
            {
                // Monthly components
                int bCount = await _context.Shifts.CountAsync(s => s.InstructorId == id && s.IsBooked && s.ScheduleDate >= startDate && s.ScheduleDate <= endDate);
                var rvs = _context.Reviews.Where(r => r.InstructorId == id && !r.IsBanned && r.CreatedAt.Year == year && r.CreatedAt.Month == month);
                double aRating = await rvs.AnyAsync() ? await rvs.AverageAsync(r => r.Rating) : 0;
                int pCount = await rvs.CountAsync(r => r.Rating >= 4);
                globalTotalScore += (bCount * 0.5) + (aRating * 0.3) + (pCount * 0.4);

                // Annual components
                int annual_bCount = await _context.Shifts.CountAsync(s => s.InstructorId == id && s.IsBooked && s.ScheduleDate.Year == year);
                var annual_rvs = _context.Reviews.Where(r => r.InstructorId == id && !r.IsBanned && r.CreatedAt.Year == year);
                double annual_aRating = await annual_rvs.AnyAsync() ? await annual_rvs.AverageAsync(r => r.Rating) : 0;
                int annual_pCount = await annual_rvs.CountAsync(r => r.Rating >= 4);
                annualGlobalTotalScore += (annual_bCount * 0.3) + (annual_aRating * 0.4) + (annual_pCount * 0.5);
            }

            var detail = new SalaryDetailViewModel
            {
                InstructorId = instructorId,
                InstructorName = instructor.User.UserName,
                HourWage = instructor.HourWage,
                Year = year,
                Month = month,
                Shifts = shifts,
                BookingCount = bookingCount,
                AverageRating = avgRating,
                PositiveReviewCount = positiveCount,
                AnnualBookingCount = annualBookingCount,
                AnnualAverageRating = annualAvgRating,
                AnnualPositiveReviewCount = annualPositiveCount,
                MonthlyBookingTrend = monthlyTrends,
                GlobalTotalScore = globalTotalScore,
                AnnualGlobalTotalScore = annualGlobalTotalScore,
                MonthlyBonusPool = monthlyPool,
                AnnualBonusPool = annualPool
            };

            detail.BonusAmount = Math.Round(detail.SuggestedBonus, 0);
            detail.AnnualBonusAmount = Math.Round(detail.AnnualSuggestedBonus, 0);

            return detail;
        }
    }
}
