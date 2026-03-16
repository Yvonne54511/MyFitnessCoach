using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Repositories;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public interface IInstructorService
    {
        Task<IEnumerable<InstructorDto>> GetAllInstructorsAsync();
        Task<InstructorDto?> GetInstructorByIdAsync(int id);
        Task CreateInstructorAsync(InstructorDto dto);
        Task UpdateInstructorAsync(InstructorDto dto);
        Task DeleteInstructorAsync(int id);
        Task ToggleIsActiveAsync(int id);
        Task<IEnumerable<UserDto>> GetAvailableUsersAsync();
    }

    public class InstructorService : IInstructorService
    {
        private readonly IInstructorRepository _repository;

        public InstructorService(IInstructorRepository repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<InstructorDto>> GetAllInstructorsAsync()
        {
            var instructors = await _repository.GetAllAsync();
            return instructors.Select(i => new InstructorDto
            {
                Id = i.Id,
                UserId = i.UserId,
                UserName = i.User?.UserName ?? i.User?.Account ?? "Unknown",
                ImageUrl = NormalizeImageUrl(i.ImageUrl),
                Description = i.Description,
                HourWage = i.HourWage,
                CancelCount = i.CancelCount,
                IsActive = i.IsActive
            });
        }

        public async Task<InstructorDto?> GetInstructorByIdAsync(int id)
        {
            var i = await _repository.GetByIdAsync(id);
            if (i == null) return null;

            return new InstructorDto
            {
                Id = i.Id,
                UserId = i.UserId,
                UserName = i.User?.UserName ?? i.User?.Account ?? "Unknown",
                ImageUrl = NormalizeImageUrl(i.ImageUrl),
                Description = i.Description,
                HourWage = i.HourWage,
                CancelCount = i.CancelCount,
                IsActive = i.IsActive
            };
        }

        private string NormalizeImageUrl(string? url)
        {
            if (string.IsNullOrEmpty(url)) return string.Empty;
            if (url.StartsWith("/images/"))
            {
                return "/img/" + url.Substring(8);
            }
            return url;
        }

        public async Task CreateInstructorAsync(InstructorDto dto)
        {
            var instructor = new Instructor
            {
                UserId = dto.UserId,
                ImageUrl = dto.ImageUrl,
                Description = dto.Description,
                HourWage = dto.HourWage,
                CancelCount = 0,
                IsActive = true
            };
            await _repository.CreateAsync(instructor);
        }

        public async Task UpdateInstructorAsync(InstructorDto dto)
        {
            var instructor = await _repository.GetByIdAsync(dto.Id);
            if (instructor != null)
            {
                instructor.ImageUrl = dto.ImageUrl;
                instructor.Description = dto.Description;
                instructor.HourWage = dto.HourWage;
                instructor.CancelCount = dto.CancelCount;
                instructor.IsActive = dto.IsActive;

                await _repository.UpdateAsync(instructor);
            }
        }

        public async Task DeleteInstructorAsync(int id)
        {
            await _repository.DeleteAsync(id);
        }

        public async Task ToggleIsActiveAsync(int id)
        {
            var instructor = await _repository.GetByIdAsync(id);
            if (instructor != null)
            {
                instructor.IsActive = !instructor.IsActive;
                await _repository.UpdateAsync(instructor);
            }
        }

        public async Task<IEnumerable<UserDto>> GetAvailableUsersAsync()
        {
            var users = await _repository.GetAvailableUsersAsync();
            return users.Select(u => new UserDto
            {
                Id = u.Id,
                UserName = u.UserName ?? u.Account,
                Account = u.Account
            });
        }
    }
}
