using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public class ShiftService
    {
        private readonly IShiftRepository _repository;

        public ShiftService(IShiftRepository repository)
        {
            _repository = repository;
        }

        // 取得剩餘修改次數
        public async Task<int> GetRemainingChancesAsync(int instructorId)
        {
            // 檢查本月是否已有排班紀錄
            var today = DateTime.Today;
            var criteria = new ShiftQueryCriteria
            {
                InstructorId = instructorId,
                StartDate = new DateOnly(today.Year, today.Month, 1),
                EndDate = new DateOnly(today.Year, today.Month, 1).AddMonths(1).AddDays(-1)
            };
            var existingRecords = await _repository.GetByCriteriaAsync(criteria);

            // 如果本月還沒排過班，視為第一次送班，顯示 3 次機會
            if (!existingRecords.Any())
            {
                return 3;
            }

            var instructor = await _repository.GetInstructorByIdAsync(instructorId);
            return instructor?.CancelCount ?? 3;
        }

        // 1. 取得前端需要的已預約字串陣列 (例如 "2026-03-05-S0")
        public async Task<List<string>> GetBookedSlotsForFrontendAsync(int instructorId)
        {
            // 只抓取該營養師「目前月份」的紀錄
            var today = DateTime.Today;
            var criteria = new ShiftQueryCriteria
            {
                InstructorId = instructorId,
                StartDate = new DateOnly(today.Year, today.Month, 1),
                EndDate = new DateOnly(today.Year, today.Month, 1).AddMonths(1).AddDays(-1)
            };

            var bookedData = await _repository.GetByCriteriaAsync(criteria);
            var resultList = new List<string>();

            foreach (var item in bookedData)
            {
                // 使用 Trim() 避免資料庫中可能有多的空格
                string slotIndex = (item.TimeSlot ?? "").Trim() switch
                {
                    "09-10 (早)" => "S0",
                    "14-15 (午)" => "S1",
                    "18-19 (晚)" => "S2",
                    _ => ""
                };

                if (!string.IsNullOrEmpty(slotIndex))
                {
                    // ScheduleDate is DateOnly
                    resultList.Add($"{item.ScheduleDate:yyyy-MM-dd}-{slotIndex}");
                }
            }
            return resultList;
        }

        // 2. 商業邏輯：同步更新 (新增勾選的，刪除取消勾選的)
        public async Task<Result> SyncSchedulesAsync(List<ShiftRecordDto> dtos, int instructorId)
        {
            if (dtos == null) return Result.Success(instructorId);

            // 1. 取得講師資訊
            var instructor = await _repository.GetInstructorByIdAsync(instructorId);
            if (instructor == null) return Result.Failure("找不到營養師資訊");

            // 2. 確定查詢範圍
            var firstDate = dtos.Any() ? dtos.Min(d => d.Date) : DateOnly.FromDateTime(DateTime.Today);
            var criteria = new ShiftQueryCriteria
            {
                InstructorId = instructorId,
                StartDate = new DateOnly(firstDate.Year, firstDate.Month, 1),
                EndDate = new DateOnly(firstDate.Year, firstDate.Month, 1).AddMonths(1).AddDays(-1)
            };

            // 3. 獲取該月份的現有紀錄
            var existingRecords = await _repository.GetByCriteriaAsync(criteria);
            
            // 判斷是否為「第一次送班表」：如果資料庫完全沒資料，就是第一次
            bool isFirstSubmission = !existingRecords.Any();

            // 4. 找出變動項目
            var toDeleteDtos = existingRecords
                .Where(db => !dtos.Any(dto =>
                    dto.Date == db.ScheduleDate &&
                    dto.Slot?.Trim() == db.TimeSlot?.Trim()))
                .ToList();

            if (toDeleteDtos.Any(d => d.IsBooked))
            {
                return Result.Failure("此時段已有客戶預約，無法直接關閉，請至訂單管理進行取消操作。");
            }

            var toAddDtos = dtos
                .Where(dto => !existingRecords.Any(db =>
                    db.ScheduleDate == dto.Date &&
                    db.TimeSlot?.Trim() == dto.Slot?.Trim()))
                .Select(dto => new ShiftDto
                {
                    InstructorId = instructorId,
                    ScheduleDate = dto.Date,
                    TimeSlot = dto.Slot?.Trim(),
                    IsBooked = false
                })
                .ToList();

            // 5. 檢查是否有實際變動
            bool hasChanges = toDeleteDtos.Any() || toAddDtos.Any();
            if (hasChanges)
            {
                if (isFirstSubmission)
                {
                    // 第一次排班：不扣次數，並確保 CancelCount 初始化為 3
                    instructor.CancelCount = 3;
                }
                else
                {
                    // 是修改行為：執行減法邏輯
                    int remaining = instructor.CancelCount;
                    if (remaining <= 0)
                    {
                        return Result.Failure("本月修改次數已達上限（3次），無法再進行修改。");
                    }
                    instructor.CancelCount = remaining - 1;
                }

                // 執行變更
                if (toDeleteDtos.Any()) await _repository.DeleteRangeAsync(toDeleteDtos);
                if (toAddDtos.Any()) await _repository.AddRangeAsync(toAddDtos);

                // 更新營養師資料
                await _repository.UpdateInstructorAsync(instructor);
            }

            return Result.Success(instructorId);
        }

        // 便利方法：從 ViewModel 直接儲存
        public async Task<Result> SaveFromViewModelsAsync(List<ShiftViewModel> vms, int instructorId)
        {
            var dtos = vms?.Select(vm => new ShiftRecordDto
            {
                Date = DateOnly.ParseExact(vm.Date, "yyyy-MM-dd"),
                Slot = vm.Time_Slot
            }).ToList() ?? new List<ShiftRecordDto>();
            return await SyncSchedulesAsync(dtos, instructorId);
        }
    }
}
