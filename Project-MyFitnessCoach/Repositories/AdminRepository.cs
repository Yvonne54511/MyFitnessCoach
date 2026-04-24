using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
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
        private readonly IEmailService _emailService;
        private readonly ILogger<AdminRepository> _logger;

        public AdminRepository(MyFitnessCoachDbContext context, IEmailService emailService, ILogger<AdminRepository> logger)
        {
            _context = context;
            _emailService = emailService;
            _logger = logger;
        }

        public async Task<List<ShiftDto>> GetAllInstructorShiftsAsync(ShiftQueryCriteria criteria = null)
        {
            var query = _context.Shifts
                .Include(s => s.Instructor)
                .ThenInclude(i => i.User)
                .AsQueryable();

            if (criteria != null)
            {
                if (criteria.InstructorId.HasValue) query = query.Where(s => s.InstructorId == criteria.InstructorId.Value);
                if (!string.IsNullOrEmpty(criteria.InstructorName)) query = query.Where(s => s.Instructor.User.UserName.Contains(criteria.InstructorName));
                if (criteria.StartDate.HasValue) query = query.Where(s => s.ScheduleDate >= criteria.StartDate.Value);
                if (criteria.EndDate.HasValue) query = query.Where(s => s.ScheduleDate <= criteria.EndDate.Value);
                if (criteria.IsBooked.HasValue) query = query.Where(s => s.IsBooked == criteria.IsBooked.Value);
            }

            return await query
                .OrderBy(s => s.Instructor.User.UserName)
                .ThenBy(s => s.ScheduleDate)
                .ThenBy(s => s.TimeSlot)
                .Select(s => new ShiftDto
                {
                    Id = s.Id,
                    InstructorId = s.InstructorId,
                    InstructorName = s.Instructor.User.UserName ?? "未知名",
                    ScheduleDate = s.ScheduleDate,
                    TimeSlot = s.TimeSlot,
                    IsBooked = s.IsBooked
                })
                .ToListAsync();
        }

        public async Task<bool> UpdateShiftStatusAsync(int shiftId, bool isBooked)
        {
            _logger.LogInformation("Repository: 開始更新 ShiftId {ShiftId}", shiftId);

            var shift = await _context.Shifts
                .Include(s => s.Instructor).ThenInclude(i => i.User)
                .Include(s => s.ReserveOrders)
                .FirstOrDefaultAsync(s => s.Id == shiftId);

            if (shift == null) return false;

            // 補回時間判定：不允許修改過去的班表
            var now = DateTime.Now;
            int hour = 8;
            if (shift.TimeSlot.Contains("午")) hour = 13;
            else if (shift.TimeSlot.Contains("晚")) hour = 18;
            else if (shift.TimeSlot.Contains("-")) 
            {
                var firstPart = shift.TimeSlot.Split('-')[0];
                int.TryParse(new string(firstPart.Where(char.IsDigit).ToArray()), out hour);
            }
            var shiftDateTime = shift.ScheduleDate.ToDateTime(new TimeOnly(hour == 0 ? 8 : hour, 0));

            if (now > shiftDateTime)
            {
                _logger.LogWarning("Repository: 禁止修改過去的班表 (ShiftId: {ShiftId})", shiftId);
                return false; // 這裡補回來了
            }

            if (shift.IsBooked == isBooked) return true;

            using (var transaction = await _context.Database.BeginTransactionAsync())
            {
                try
                {
                    shift.IsBooked = isBooked;

                    if (!isBooked && shift.ReserveOrders.Any())
                    {
                        foreach (var order in shift.ReserveOrders.ToList())
                        {
                            // 補回：更安全的會員資料讀取
                            var member = await _context.Members
                                .Include(m => m.User)
                                .Include(m => m.UserWallet)
                                .FirstOrDefaultAsync(m => m.Id == order.MemberId);

                            if (member != null && order.PointCost.HasValue && order.PointCost.Value > 0)
                            {
                                // 退回點數
                                if (member.UserWallet != null)
                                {
                                    member.UserWallet.CurrentBalance += (decimal)order.PointCost.Value;
                                    member.UserWallet.LastUpdated = DateTime.Now;

                                    // 記錄流水 (PointOrderId 可為 NULL)
                                    _context.PointsRecordDetails.Add(new PointsRecordDetail
                                    {
                                        PointOrderId = null,
                                        UserWalletId = member.UserWallet.Id,
                                        CreateAt = DateTime.Now,
                                        PointAmount = order.PointCost.Value,
                                        MerchandiseCategory = "Cancel",
                                        ReserveOrderId = null
                                    });
                                }

                                // 寄送 Email (失敗不中斷交易)
                                if (member.User != null && !string.IsNullOrEmpty(member.User.Email))
                                {
                                    try {
                                        _ = _emailService.SendReservationCancelEmailAsync(
                                            member.User.Email, member.User.UserName, 
                                            shift.Instructor.User.UserName ?? "您的營養師", 
                                            shift.ScheduleDate.ToString("yyyy-MM-dd"), shift.TimeSlot);
                                    } catch { }
                                }
                            }

                            // 處理外鍵並刪除預約
                            var relatedLogs = await _context.PointsRecordDetails.Where(r => r.ReserveOrderId == order.Id).ToListAsync();
                            foreach (var log in relatedLogs) log.ReserveOrderId = null;

                            _context.ReserveOrders.Remove(order);
                        }
                    }

                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();
                    return true;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Repository 發生錯誤: {Msg}", ex.Message);
                    await transaction.RollbackAsync();
                    throw;
                }
            }
        }

        public async Task<List<InstructorDto>> GetInstructorsAsync()
        {
            return await _context.Instructors.Include(i => i.User)
                .Select(i => new InstructorDto { InstructorId = i.Id, InstructorName = i.User.UserName ?? "未知" })
                .ToListAsync();
        }
    }
}
