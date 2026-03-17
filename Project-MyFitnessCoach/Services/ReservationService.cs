using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public class ReservationService
    {
        private readonly IReservationRepository _repository;

        public ReservationService(IReservationRepository repository)
        {
            _repository = repository;
        }

        public async Task<List<ReservationDto>> GetBookedShiftsAsync(int instructorId, DateOnly? startDate = null, DateOnly? endDate = null)
        {
            var criteria = new ShiftQueryCriteria
            {
                InstructorId = instructorId,
                StartDate = startDate ?? DateOnly.FromDateTime(DateTime.Today.AddMonths(-1)),
                EndDate = endDate ?? DateOnly.FromDateTime(DateTime.Today.AddMonths(2)),
                IsBooked = true
            };
            return await _repository.GetByCriteriaAsync(criteria);
        }

        public async Task<ReservationDto?> GetBookingDetailsAsync(int shiftId)
        {
            return await _repository.GetByShiftIdAsync(shiftId);
        }

        public async Task<Result> UpdateMemorandumAsync(int shiftId, string memorandum)
        {
            var success = await _repository.UpdateMemorandumAsync(shiftId, memorandum);
            return success ? Result.Success(shiftId) : Result.Failure("更新備註失敗，找不到預約紀錄。");
        }
    }
}
