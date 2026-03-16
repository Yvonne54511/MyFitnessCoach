using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.DTOs
{
	public class Result
	{
		public bool IsSuccess { get; set; }
		public string ErrorMessage { get; set; }
		public int? InstructorId { get; set; } // ç¢ºä???int?
		public List<string> Roles { get; set; } = new List<string>();

		// ä¾›ç™»?¥ä½¿?¨ç??ˆæœ¬
		public static Result Success(int? instructorId, List<string> roles)
		{
			return new Result 
			{ 
				IsSuccess = true, 
				InstructorId = instructorId, 
				Roles = roles ?? new List<string>() 
			};
		}

		// ä¾›ä???Service (å¦?ReservationService) ä½¿ç”¨?„ç???
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
