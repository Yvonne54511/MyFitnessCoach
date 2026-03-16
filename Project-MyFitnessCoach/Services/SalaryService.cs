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
        Task<SalaryDetailViewModel> GetSalaryDetailAsync(int instructorId, int year, int month);
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

        public async Task<SalaryDetailViewModel> GetSalaryDetailAsync(int instructorId, int year, int month)
        {
            var instructor = await _context.Instructors
                .Include(i => i.User)
                .FirstOrDefaultAsync(i => i.Id == instructorId);

            if (instructor == null) return null;

            var startDate = new DateOnly(year, month, 1);
            var endDate = startDate.AddMonths(1).AddDays(-1);

            var shifts = await _context.Shifts
                .Where(s => s.InstructorId == instructorId && s.ScheduleDate >= startDate && s.ScheduleDate <= endDate)
                .OrderBy(s => s.ScheduleDate)
                .ThenBy(s => s.TimeSlot)
                .Select(s => new SalaryShiftViewModel
                {
                    Date = s.ScheduleDate,
                    TimeSlot = s.TimeSlot,
                    IsBooked = s.IsBooked
                })
                .ToListAsync();

            return new SalaryDetailViewModel
            {
                InstructorId = instructorId,
                InstructorName = instructor.User.UserName,
                HourWage = instructor.HourWage,
                Year = year,
                Month = month,
                Shifts = shifts
            };
        }
    }
}
