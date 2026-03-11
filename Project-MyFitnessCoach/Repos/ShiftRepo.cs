using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repos
{
    // 1. 定義介面 (Interface)
    public interface IShiftRepository
    {
        // 取得所有已預約的紀錄
        Task<List<ShiftDto>> GetAllAsync();

        // 根據單一日期與時段，取得已存在的紀錄 (用來比對防重複)
        Task<ShiftDto?> GetByDateAndSlotAsync(DateOnly date, string slot);

        // 根據多個日期取得已存在的紀錄（批次查詢）
        Task<List<ShiftDto>> GetByDatesAsync(List<DateOnly> dates);

        // 批次新增
        Task AddRangeAsync(IEnumerable<ShiftDto> schedules);

        // 批次刪除
        Task DeleteRangeAsync(IEnumerable<ShiftDto> schedules);

        // 單筆新增
        Task AddAsync(ShiftDto schedule);
        Task<List<ShiftDto>> GetByDateRangeAsync(DateOnly start, DateOnly end);

        Task<List<ShiftDto>> GetByCriteriaAsync(ShiftQueryCriteria criteria);

        // 新增：取得營養師資訊
        Task<Instructor?> GetInstructorByIdAsync(int id);
        Task UpdateInstructorAsync(Instructor instructor);
	}

    // 2. 實作類別 (Implementation)
    public class ShiftRepository : IShiftRepository
    {
        private readonly ResRevContext _context;

        public ShiftRepository(ResRevContext context)
        {
            _context = context;
        }

        // 新增實作
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
            // Shift.ScheduleDate is DateOnly so compare directly
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

			// 篩選可能的符合項以減少拉整張表
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
