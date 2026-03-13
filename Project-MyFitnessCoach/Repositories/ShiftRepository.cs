using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IShiftRepository
    {
        Task<List<ShiftDto>> GetAllAsync();
        Task<ShiftDto?> GetByDateAndSlotAsync(DateOnly date, string slot);
        Task<List<ShiftDto>> GetByDatesAsync(List<DateOnly> dates);
        Task AddRangeAsync(IEnumerable<ShiftDto> schedules);
        Task DeleteRangeAsync(IEnumerable<ShiftDto> schedules);
        Task AddAsync(ShiftDto schedule);
        Task<List<ShiftDto>> GetByDateRangeAsync(DateOnly start, DateOnly end);
        Task<List<ShiftDto>> GetByCriteriaAsync(ShiftQueryCriteria criteria);
        Task<Instructor?> GetInstructorByIdAsync(int id);
        Task UpdateInstructorAsync(Instructor instructor);
	}

    public class ShiftRepository : IShiftRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public ShiftRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public async Task<Instructor?> GetInstructorByIdAsync(int id)
        {
            return await _context.Instructors.FindAsync(id);
        }

        public async Task UpdateInstructorAsync(Instructor instructor)
        {
            _context.Entry(instructor).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        public async Task<List<ShiftDto>> GetAllAsync()
        {
            return await _context.Shifts
                .Select(s => new ShiftDto
                {
                    InstructorId = s.InstructorId,
                    ScheduleDate = s.ScheduleDate,
                    TimeSlot = s.TimeSlot,
                    IsBooked = s.IsBooked
                })
                .ToListAsync();
        }

        public async Task<ShiftDto?> GetByDateAndSlotAsync(DateOnly date, string slot)
        {
            return await _context.Shifts
                .Where(x => x.ScheduleDate == date && x.TimeSlot == slot)
                .Select(s => new ShiftDto
                {
                    InstructorId = s.InstructorId,
                    ScheduleDate = s.ScheduleDate,
                    TimeSlot = s.TimeSlot,
                    IsBooked = s.IsBooked
                })
                .FirstOrDefaultAsync();
        }

        public async Task<List<ShiftDto>> GetByDatesAsync(List<DateOnly> dates)
        {
            return await _context.Shifts
                .Where(x => dates.Contains(x.ScheduleDate))
                .Select(s => new ShiftDto
                {
                    InstructorId = s.InstructorId,
                    ScheduleDate = s.ScheduleDate,
                    TimeSlot = s.TimeSlot,
                    IsBooked = s.IsBooked
                })
                .ToListAsync();
        }

        public async Task AddRangeAsync(IEnumerable<ShiftDto> schedules)
        {
			var entities = schedules
				.Where(d => d != null)
				.Select(d => new Shift
				{
					InstructorId = d.InstructorId,
					ScheduleDate = d.ScheduleDate,
					TimeSlot = d.TimeSlot?.Trim(),
					IsBooked = d.IsBooked
				})
				.ToList();

			if (!entities.Any()) return;
			await _context.Shifts.AddRangeAsync(entities);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteRangeAsync(IEnumerable<ShiftDto> schedules)
        {
			var dtoList = schedules
				 .Where(d => d != null)
				 .Select(d => new
				 {
					 d.InstructorId,
					 d.ScheduleDate,
					 TimeSlot = d.TimeSlot?.Trim()
				 })
				 .ToList();

			if (!dtoList.Any()) return;

			var instructorIds = dtoList.Select(d => d.InstructorId).Distinct().ToList();
			var dates = dtoList.Select(d => d.ScheduleDate).Distinct().ToList();

			var candidates = await _context.Shifts
				.Where(s => instructorIds.Contains(s.InstructorId) && dates.Contains(s.ScheduleDate))
				.ToListAsync();

			var toRemove = candidates
				.Where(s => dtoList.Any(d =>
					d.InstructorId == s.InstructorId &&
					d.ScheduleDate == s.ScheduleDate &&
					d.TimeSlot == s.TimeSlot))
				.ToList();

			if (!toRemove.Any()) return;

			_context.Shifts.RemoveRange(toRemove);
			await _context.SaveChangesAsync();
		}

        public async Task AddAsync(ShiftDto schedule)
        {
			if (schedule == null) return;

			var entity = new Shift
			{
				InstructorId = schedule.InstructorId,
				ScheduleDate = schedule.ScheduleDate,
				TimeSlot = schedule.TimeSlot?.Trim(),
				IsBooked = schedule.IsBooked
			};

			await _context.Shifts.AddAsync(entity);
			await _context.SaveChangesAsync();
		}

        public async Task<List<ShiftDto>> GetByDateRangeAsync(DateOnly start, DateOnly end)
        {
            return await _context.Shifts
            .Where(x => x.ScheduleDate >= start && x.ScheduleDate <= end)
            .Select(s => new ShiftDto
            {
                InstructorId = s.InstructorId,
                ScheduleDate = s.ScheduleDate,
                TimeSlot = s.TimeSlot,
                IsBooked = s.IsBooked
            })
            .ToListAsync();
        }

        public  async Task<List<ShiftDto>> GetByCriteriaAsync(ShiftQueryCriteria criteria)
		{
            var query = _context.Shifts.AsQueryable();

			if (criteria.InstructorId.HasValue)
			{
				query = query.Where(x => x.InstructorId == criteria.InstructorId.Value);
			}

            if (criteria.StartDate.HasValue)
            {
			    query = query.Where(x => x.ScheduleDate >= criteria.StartDate.Value);
            }

            if (criteria.EndDate.HasValue)
            {
			    query = query.Where(x => x.ScheduleDate <= criteria.EndDate.Value);
            }

            if (criteria.IsBooked.HasValue)
            {
                query = query.Where(x => x.IsBooked == criteria.IsBooked.Value);
            }

            return await query
                .Select(s => new ShiftDto
                {
                    Id = s.Id,
                    InstructorId = s.InstructorId,
                    ScheduleDate = s.ScheduleDate,
                    TimeSlot = s.TimeSlot,
                    IsBooked = s.IsBooked
                })
                .ToListAsync();
		}
	}
}
