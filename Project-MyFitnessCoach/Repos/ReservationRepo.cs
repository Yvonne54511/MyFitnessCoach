using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Repos
{
    public interface IReservationRepository
    {
        Task<List<ReservationDto>> GetByCriteriaAsync(ShiftQueryCriteria criteria);
        Task<ReservationDto?> GetByShiftIdAsync(int shiftId);
        Task<bool> UpdateMemorandumAsync(int shiftId, string memorandum);
    }

    public class ReservationRepository : IReservationRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public ReservationRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public async Task<List<ReservationDto>> GetByCriteriaAsync(ShiftQueryCriteria criteria)
        {
            var query = _context.Shifts
                .Include(s => s.Instructor)
                .ThenInclude(i => i.User)
                .Include(s => s.ReserveOrders)
                .ThenInclude(ro => ro.Member)
                .ThenInclude(m => m.User)
                .AsQueryable();

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
                .Select(s => new ReservationDto
                {
                    Id = s.Id,
                    InstructorId = s.InstructorId,
                    InstructorName = s.Instructor.User.UserName,
                    ScheduleDate = s.ScheduleDate,
                    TimeSlot = s.TimeSlot,
                    IsBooked = s.IsBooked,
                    MemberName = s.ReserveOrders.Select(ro => ro.Member.User.UserName).FirstOrDefault(),
                    MemberId = s.ReserveOrders.Select(ro => ro.MemberId).FirstOrDefault(),
                    Target = s.ReserveOrders.Select(ro => ro.Target).FirstOrDefault(),
                    Memorandum = s.ReserveOrders.Select(ro => ro.Memorandum).FirstOrDefault()
                })
                .ToListAsync();
        }

        public async Task<ReservationDto?> GetByShiftIdAsync(int shiftId)
        {
            return await _context.Shifts
                .Include(s => s.Instructor)
                .ThenInclude(i => i.User)
                .Include(s => s.ReserveOrders)
                .ThenInclude(ro => ro.Member)
                .ThenInclude(m => m.User)
                .Where(s => s.Id == shiftId)
                .Select(s => new ReservationDto
                {
                    Id = s.Id,
                    InstructorId = s.InstructorId,
                    InstructorName = s.Instructor.User.UserName,
                    ScheduleDate = s.ScheduleDate,
                    TimeSlot = s.TimeSlot,
                    IsBooked = s.IsBooked,
                    MemberName = s.ReserveOrders.Select(ro => ro.Member.User.UserName).FirstOrDefault(),
                    MemberId = s.ReserveOrders.Select(ro => ro.MemberId).FirstOrDefault(),
                    Target = s.ReserveOrders.Select(ro => ro.Target).FirstOrDefault(),
                    Memorandum = s.ReserveOrders.Select(ro => ro.Memorandum).FirstOrDefault()
                })
                .FirstOrDefaultAsync();
        }

        public async Task<bool> UpdateMemorandumAsync(int shiftId, string memorandum)
        {
            var order = await _context.ReserveOrders.FirstOrDefaultAsync(ro => ro.ShiftId == shiftId);
            if (order == null) return false;

            order.Memorandum = memorandum;
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
