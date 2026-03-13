using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.Dtos
{
	public class Result
	{
		public bool IsSuccess { get; set; }
		public string ErrorMessage { get; set; }
		public int? InstructorId { get; set; } // 確保是 int?
		public List<string> Roles { get; set; } = new List<string>();

		// 供登入使用的版本
		public static Result Success(int? instructorId, List<string> roles)
		{
			return new Result 
			{ 
				IsSuccess = true, 
				InstructorId = instructorId, 
				Roles = roles ?? new List<string>() 
			};
		}

		// 供一般 Service (如 ReservationService) 使用的版本
		public static Result Success(int? instructorId)
		{
			return new Result 
			{ 
				IsSuccess = true, 
				InstructorId = instructorId,
				Roles = new List<string>()
			};
		}

		public static Result Failure(string errorMessage)
		{
			return new Result { IsSuccess = false, ErrorMessage = errorMessage };
		}
	}
}
