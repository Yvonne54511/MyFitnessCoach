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
		Task<int> GetUserIdByInstructorIdAsync(int instructorId);
    }

    public class SalaryService : ISalaryService
    {
        private readonly MyFitnessCoachDbContext _context;
		private readonly IConfiguration _configuration;

		public SalaryService(MyFitnessCoachDbContext context, IConfiguration configuration)
        {
            _context = context;
			_configuration = configuration;
		}

		public async Task<int> GetUserIdByInstructorIdAsync(int instructorId)
		{
			var instructor = await _context.Instructors.FindAsync(instructorId);
			return instructor?.UserId ?? 0;
		}

        public async Task<SalaryRankingsViewModel> GetRankingsAsync()
        {
            var result = new SalaryRankingsViewModel();

            // 1. 預約最多 (Top Booked) - Based on Shifts where IsBooked is true
            result.TopBooked = await _context.Shifts
                .Where(s => s.IsBooked)
                .GroupBy(s => new { s.InstructorId, s.Instructor.User.UserName, s.Instructor.ImageUrl })
                .OrderByDescending(g => g.Count())
                .Take(3)
                .Select(g => new RankingItemViewModel
                {
                    InstructorId = g.Key.InstructorId,
                    InstructorName = g.Key.UserName,
                    ImageUrl = g.Key.ImageUrl,
                    Value = g.Count().ToString() + " 次"
                })
                .ToListAsync();

            // 2. 評分最高 (Top Rated) - Average rating from Reviews (not banned)
            result.TopRated = await _context.Reviews
                .Where(r => !r.IsBanned)
                .GroupBy(r => new { r.InstructorId, r.Instructor.User.UserName, r.Instructor.ImageUrl })
                .OrderByDescending(g => g.Average(r => r.Rating))
                .Take(3)
                .Select(g => new RankingItemViewModel
                {
                    InstructorId = g.Key.InstructorId,
                    InstructorName = g.Key.UserName,
                    ImageUrl = g.Key.ImageUrl,
                    Value = g.Average(r => r.Rating).ToString("F1") + " 分"
                })
                .ToListAsync();

            // 3. 好評最多 (Most Positive Reviews) - Count of Reviews with Rating >= 4
            result.MostPositiveReviews = await _context.Reviews
                .Where(r => !r.IsBanned && r.Rating >= 4)
                .GroupBy(r => new { r.InstructorId, r.Instructor.User.UserName, r.Instructor.ImageUrl })
                .OrderByDescending(g => g.Count())
                .Take(3)
                .Select(g => new RankingItemViewModel
                {
                    InstructorId = g.Key.InstructorId,
                    InstructorName = g.Key.UserName,
                    ImageUrl = g.Key.ImageUrl,
                    Value = g.Count().ToString() + " 則"
                })
                .ToListAsync();

            return result;
        }

        public async Task<List<SalaryInstructorViewModel>> GetInstructorsAsync()
        {
            return await _context.Instructors
                .Include(i => i.User)
                .Include(i => i.InstructorWallets)
                .Where(i => i.IsActive)
                .Select(i => new SalaryInstructorViewModel
                {
                    Id = i.Id,
                    Name = i.User.UserName,
                    ImageUrl = i.ImageUrl,
                    WalletBalance = i.InstructorWallets.FirstOrDefault() != null ? i.InstructorWallets.First().CurrentBalance : 0,
                    LastUpdated = i.InstructorWallets.FirstOrDefault() != null ? i.InstructorWallets.First().LastUpdated : DateTime.MinValue
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

            // 2. Performance Metrics Calculation using bool helper
            var monthlyMetrics = await GetPeriodMetricsAsync(instructorId, year, month, isAnnual: false);
            var annualMetrics = await GetPeriodMetricsAsync(instructorId, year, month, isAnnual: true);

            // 2.2 Monthly Trend
            var monthlyTrends = new List<int>();
            for (int m = 1; m <= 12; m++)
            {
                int count = await _context.Shifts
                    .CountAsync(s => s.InstructorId == instructorId && s.IsBooked && s.ScheduleDate.Year == year && s.ScheduleDate.Month == m);
                monthlyTrends.Add(count);
            }

            // 3. Global Scores Calculation using bool helper
            var allInstructors = await _context.Instructors.Where(i => i.IsActive).Select(i => i.Id).ToListAsync();
            double globalTotalScore = 0;
            double annualGlobalTotalScore = 0;

            foreach (var id in allInstructors)
            {
                var mMetrics = await GetPeriodMetricsAsync(id, year, month, isAnnual: false);
                globalTotalScore += mMetrics.WeightedScore;

                var aMetrics = await GetPeriodMetricsAsync(id, year, month, isAnnual: true);
                annualGlobalTotalScore += aMetrics.WeightedScore;
            }

            var detail = new SalaryDetailViewModel
            {
                InstructorId = instructorId,
                InstructorName = instructor.User.UserName,
                ImageUrl = instructor.ImageUrl,
                InstructorEmail = instructor.User.Email, // 傳遞 Email
                HourWage = instructor.HourWage,
                Year = year,
                Month = month,
                Shifts = shifts,
                BookingCount = monthlyMetrics.BookingCount,
                AverageRating = monthlyMetrics.AverageRating,
                PositiveReviewCount = monthlyMetrics.PositiveReviewCount,
                AnnualBookingCount = annualMetrics.BookingCount,
                AnnualAverageRating = annualMetrics.AverageRating,
                AnnualPositiveReviewCount = annualMetrics.PositiveReviewCount,
                MonthlyBookingTrend = monthlyTrends,
                GlobalTotalScore = globalTotalScore,
                AnnualGlobalTotalScore = annualGlobalTotalScore,
                MonthlyBonusPool = monthlyPool,
                AnnualBonusPool = annualPool
            };

            detail.BonusAmount = Math.Round(detail.SuggestedBonus, 0);
            detail.AnnualBonusAmount = Math.Round(detail.AnnualSuggestedBonus, 0);

			// 注入匯率設定 (從 Controller 移至此處)
			detail.TwdToUsdRate = _configuration.GetValue<double>("CurrencySettings:TwdToUsdRate", 32.0);

            return detail;
        }

        private async Task<PeriodMetricsResult> GetPeriodMetricsAsync(int instructorId, int year, int month, bool isAnnual)
        {
            DateTime startDateTime, endDateTime;
            DateOnly startDate, endDate;

            if (!isAnnual)
            {
                startDate = new DateOnly(year, month, 1);
                endDate = startDate.AddMonths(1).AddDays(-1);
                startDateTime = new DateTime(year, month, 1);
                endDateTime = startDateTime.AddMonths(1).AddSeconds(-1);
            }
            else // Annual
            {
                startDate = new DateOnly(year, 1, 1);
                endDate = new DateOnly(year, 12, 31);
                startDateTime = new DateTime(year, 1, 1);
                endDateTime = new DateTime(year, 12, 31, 23, 59, 59);
            }

            int bookingCount = await _context.Shifts
                .CountAsync(s => s.InstructorId == instructorId && s.IsBooked && s.ScheduleDate >= startDate && s.ScheduleDate <= endDate);

            var reviews = _context.Reviews
                .Where(r => r.InstructorId == instructorId && !r.IsBanned && r.CreatedAt >= startDateTime && r.CreatedAt <= endDateTime);

            double avgRating = await reviews.AnyAsync() ? await reviews.AverageAsync(r => r.Rating) : 0;
            int positiveCount = await reviews.CountAsync(r => r.Rating >= 4);

            // Apply different weights based on period
            double weightedScore = (!isAnnual)
                ? (bookingCount * 0.5) + (avgRating * 0.3) + (positiveCount * 0.4)
                : (bookingCount * 0.3) + (avgRating * 0.4) + (positiveCount * 0.5);

            return new PeriodMetricsResult
            {
                BookingCount = bookingCount,
                AverageRating = avgRating,
                PositiveReviewCount = positiveCount,
                WeightedScore = weightedScore
            };
        }

        private class PeriodMetricsResult
        {
            public int BookingCount { get; set; }
            public double AverageRating { get; set; }
            public int PositiveReviewCount { get; set; }
            public double WeightedScore { get; set; }
        }
    }
}
