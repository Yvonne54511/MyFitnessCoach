using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Repositories;
using Microsoft.AspNetCore.Identity;
using Project_MyFitnessCoach.Models.EfModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
	public class LoginService
	{
		private readonly ILoginRepository _repository;
		private readonly IPasswordHasher<User> _passwordHasher;

		public LoginService(ILoginRepository repository, IPasswordHasher<User> passwordHasher)
		{
			_repository = repository;
			_passwordHasher = passwordHasher;
		}

		public async Task<Result> LoginAsync(LoginDto dto)
		{
			var user = await _repository.GetByAccountAsync(dto.Account);
			if (user == null) return Result.Failure("帳號不存在");

			// 使用 PasswordHasher 驗證密碼
			var verifyResult = _passwordHasher.VerifyHashedPassword(user, user.HashedPassword, dto.Password);
			if (verifyResult == PasswordVerificationResult.Failed)
			{
				return Result.Failure("密碼錯誤");
			}

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
