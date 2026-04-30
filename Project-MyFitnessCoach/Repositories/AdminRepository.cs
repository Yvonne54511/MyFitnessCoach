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
        private readonly GoogleCalendarService _googleCalendarService;
        private readonly ILogger<AdminRepository> _logger;

        public AdminRepository(MyFitnessCoachDbContext context, IEmailService emailService, GoogleCalendarService googleCalendarService, ILogger<AdminRepository> logger)
        {
            _context = context;
            _emailService = emailService;
            _googleCalendarService = googleCalendarService;
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
                return false;
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
                            var member = await _context.Members
                                .Include(m => m.User)
                                .Include(m => m.UserWallet)
                                .FirstOrDefaultAsync(m => m.Id == order.MemberId);

                            if (member != null)
                            {
                                // 1. 退回點數
                                if (order.PointCost.HasValue && order.PointCost.Value > 0)
                                {
                                    if (member.UserWallet != null)
                                    {
                                        member.UserWallet.CurrentBalance += (decimal)order.PointCost.Value;
                                        member.UserWallet.LastUpdated = DateTime.Now;

                                        _context.PointsRecordDetails.Add(new PointsRecordDetail
                                        {
                                            PointOrderId = null,
                                            UserWalletId = member.UserWallet.Id,
                                            CreateAt = DateTime.Now,
                                            PointAmount = order.PointCost.Value,
                                            MerchandiseCategory = "後台取消預約(點數歸還)",
                                            ReserveOrderId = null
                                        });
                                    }
                                }

                                // 2. 寄送 Email (這裡可以用 Task.Run 隔離，因為 EmailService 不用 DB)
                                string email = "";
                                string userName = "";

                                if (order.MemberId == 6 && !string.IsNullOrEmpty(order.GuestEmail))
                                {
                                    // 訪客模式：從專用欄位提取 Email
                                    email = order.GuestEmail.Trim();
                                    userName = "訪客";
                                }
                                else if (member.User != null && !string.IsNullOrEmpty(member.User.Email))
                                {
                                    // 一般會員
                                    email = member.User.Email;
                                    userName = member.User.UserName;
                                }

                                if (!string.IsNullOrEmpty(email))
                                {
                                    string instrName = shift.Instructor.User.UserName ?? "您的營養師";
                                    string dateStr = shift.ScheduleDate.ToString("yyyy-MM-dd");
                                    string timeStr = shift.TimeSlot;

                                    _ = Task.Run(() => _emailService.SendReservationCancelEmailAsync(email, userName, instrName, dateStr, timeStr));
                                }

                                // 3. Google 日曆同步刪除 (必須等待，因為它會用到同一個 DbContext)
                                if (!string.IsNullOrEmpty(order.GoogleEventId))
                                {
                                    try
                                    {
                                        // 修改為 await，避免 DbContext 同時被多個 Thread 使用
                                        await _googleCalendarService.DeleteEventAsync(member.UserId, order.GoogleEventId);
                                    }
                                    catch (Exception ex)
                                    {
                                        _logger.LogError(ex, "Google 日曆同步刪除失敗: {Message}", ex.Message);
                                    }
                                }
                            }

                            // 4. 處理外鍵並刪除預約
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
