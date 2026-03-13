using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Repositories;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public interface IAdminService
    {
        Task<List<ShiftDto>> GetAllInstructorShiftsAsync(ShiftQueryCriteria criteria = null);
        Task<bool> UpdateShiftStatusAsync(int shiftId, bool isBooked);
        Task<List<InstructorDto>> GetInstructorsAsync();
    }

    public class AdminService : IAdminService
    {
        private readonly IAdminRepository _adminRepository;

        public AdminService(IAdminRepository adminRepository)
        {
            _adminRepository = adminRepository;
        }

        public async Task<List<ShiftDto>> GetAllInstructorShiftsAsync(ShiftQueryCriteria criteria = null)
        {
            return await _adminRepository.GetAllInstructorShiftsAsync(criteria);
        }

        public async Task<bool> UpdateShiftStatusAsync(int shiftId, bool isBooked)
        {
            return await _adminRepository.UpdateShiftStatusAsync(shiftId, isBooked);
        }

        public async Task<List<InstructorDto>> GetInstructorsAsync()
        {
            return await _adminRepository.GetInstructorsAsync();
        }
    }
}
