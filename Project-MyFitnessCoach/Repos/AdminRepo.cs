using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repos
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
            // 1. 找出排班資料，並包含相關的預約紀錄
            var shift = await _context.Shifts
                .Include(s => s.ReserveOrders)
                .FirstOrDefaultAsync(s => s.Id == shiftId);

            if (shift == null) return false;

            // 2. 更新狀態
            shift.IsBooked = isBooked;

            // 3. 如果改為「開放中」(false)，則刪除關聯的預約紀錄
            if (!isBooked && shift.ReserveOrders.Any())
            {
                _context.ReserveOrders.RemoveRange(shift.ReserveOrders);
            }

            // 4. 存檔 (狀態更新與刪除紀錄會在同一個交易中執行)
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
