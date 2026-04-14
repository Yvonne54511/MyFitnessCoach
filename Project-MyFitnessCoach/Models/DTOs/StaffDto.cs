using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public class StaffDto
    {
        public int Id { get; set; }
        public string UserName { get; set; }
        public string Email { get; set; }
        public string Account { get; set; }
        public bool IsConfirmed { get; set; }
        public bool IsActive { get; set; }
        public List<string> Roles { get; set; } = new List<string>();
        public List<int> RoleIds { get; set; } = new List<int>();
    }

    public class StaffInviteDto
    {
        public string UserName { get; set; }
        public string Email { get; set; }
        public List<int> RoleIds { get; set; } = new List<int>();
    }

    public class StaffUpdateDto
    {
        public int Id { get; set; }
        public string UserName { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }
        public List<int> RoleIds { get; set; }
    }

    public class StaffActivateDto
    {
        public string Code { get; set; }
        public string Account { get; set; }
        public string Password { get; set; }
    }

    public class StaffResultDto
    {
        public bool IsSuccess { get; set; }
        public string Message { get; set; }
    }
}
