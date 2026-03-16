using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IAdminRepository
    {
        Task<List<ShiftDto>> GetAllInstructorShiftsAsync(ShiftQueryCriteria criteria = null);
        Task<bool> UpdateShiftStatusAsync(int shiftId, bool isBooked);
        Task<List<InstructorDto>> GetInstructorsAsync();
    }

    public class AdminRepository : IAdminRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public AdminRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public async Task<List<ShiftDto>> GetAllInstructorShiftsAsync(ShiftQueryCriteria criteria = null)
        {
            var query = _context.Shifts
                .Include(s => s.Instructor)
                .ThenInclude(i => i.User)
                .AsQueryable();

            if (criteria != null)
            {
                if (criteria.InstructorId.HasValue)
                {
                    query = query.Where(s => s.InstructorId == criteria.InstructorId.Value);
                }
                if (!string.IsNullOrEmpty(criteria.InstructorName))
                {
                    query = query.Where(s => s.Instructor.User.UserName.Contains(criteria.InstructorName));
                }
                if (criteria.StartDate.HasValue)
                {
                    query = query.Where(s => s.ScheduleDate >= criteria.StartDate.Value);
                }
                if (criteria.EndDate.HasValue)
                {
                    query = query.Where(s => s.ScheduleDate <= criteria.EndDate.Value);
                }
                if (criteria.IsBooked.HasValue)
                {
                    query = query.Where(s => s.IsBooked == criteria.IsBooked.Value);
                }
            }

            return await query
                .OrderBy(s => s.Instructor.User.UserName)
                .ThenBy(s => s.ScheduleDate)
                .ThenBy(s => s.TimeSlot)
                .Select(s => new ShiftDto
                {
                    Id = s.Id,
                    InstructorId = s.InstructorId,
                    InstructorName = s.Instructor.User.UserName,
                    ScheduleDate = s.ScheduleDate,
                    TimeSlot = s.TimeSlot,
                    IsBooked = s.IsBooked
                })
                .ToListAsync();
        }

        public async Task<bool> UpdateShiftStatusAsync(int shiftId, bool isBooked)
        {
            var shift = await _context.Shifts
                .Include(s => s.ReserveOrders)
                .FirstOrDefaultAsync(s => s.Id == shiftId);

            if (shift == null) return false;

            var now = DateTime.Now;
            int hour = shift.TimeSlot.Contains("早") ? 8 : (shift.TimeSlot.Contains("午") ? 13 : 18);
            var shiftDateTime = shift.ScheduleDate.ToDateTime(new TimeOnly(hour, 0));

            if (now > shiftDateTime)
            {
                return false;
            }

            shift.IsBooked = isBooked;

            if (!isBooked && shift.ReserveOrders.Any())
            {
                _context.ReserveOrders.RemoveRange(shift.ReserveOrders);
            }

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<List<InstructorDto>> GetInstructorsAsync()
        {
            return await _context.Instructors
                .Include(i => i.User)
                .Select(i => new InstructorDto
                {
                    InstructorId = i.Id,
                    InstructorName = i.User.UserName
                })
                .ToListAsync();
        }
    }
}
