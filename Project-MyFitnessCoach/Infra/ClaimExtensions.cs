using System.Security.Claims;

namespace Project_MyFitnessCoach.Models.Infra
{
    public static class ClaimExtensions
    {
        public static int? GetEmployeeId(this ClaimsPrincipal user)
            => int.TryParse(user.FindFirst("EmployeeId")?.Value, out var id) ? id : null;

        public static int? GetDepartmentId(this ClaimsPrincipal user)
            => int.TryParse(user.FindFirst("DepartmentId")?.Value, out var id) ? id : null;
    }
}
