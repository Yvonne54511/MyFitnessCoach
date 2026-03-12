using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
	public class LoginService
	{
		private readonly ILoginRepository _repository;

		public LoginService(ILoginRepository repository)
		{
			_repository = repository;
		}

		public async Task<Result> LoginAsync(LoginDto dto)
		{
			var user = await _repository.GetByAccountAsync(dto.Account);
			if (user == null) return Result.Failure("帳號不存在");

			if (user.HashedPassword != dto.Password) return Result.Failure("密碼錯誤");

            // 抓取角色名稱清單，並去除多餘空格
            var roles = user.UserRoles?
                            .Where(ur => ur.Role != null)
                            .Select(ur => ur.Role.RoleName.Trim())
                            .ToList() ?? new List<string>();

            // 安全抓取營養師 ID
            int? instructorId = user.Instructors?.FirstOrDefault()?.Id;

            return Result.Success(instructorId, roles);
		}
	}
}
