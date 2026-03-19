using Project_MyFitnessCoach.Models.DTOs;
using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModel
{
    public class StaffListItemViewModel
    {
        public int Id { get; set; }
        public string UserName { get; set; }
        public string Email { get; set; }
        public string Account { get; set; }
        public bool IsConfirmed { get; set; }
        public bool IsActive { get; set; }
        public List<string> Roles { get; set; } = new List<string>();
    }

    public class StaffInviteViewModel
    {
        [Required(ErrorMessage = "請輸入員工姓名")]
        [Display(Name = "員工姓名")]
        public string UserName { get; set; }

        [Required(ErrorMessage = "請輸入電子郵件")]
        [EmailAddress(ErrorMessage = "請輸入正確的電子郵件格式")]
        [Display(Name = "電子郵件")]
        public string Email { get; set; }
    }

    public class StaffEditViewModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "請輸入員工姓名")]
        [Display(Name = "員工姓名")]
        public string UserName { get; set; }

        [Required(ErrorMessage = "請輸入電子郵件")]
        [EmailAddress(ErrorMessage = "請輸入正確的電子郵件格式")]
        [Display(Name = "電子郵件")]
        public string Email { get; set; }

        [Display(Name = "啟用狀態")]
        public bool IsActive { get; set; }

        [Required(ErrorMessage = "請至少選擇一個角色")]
        [Display(Name = "角色")]
        public List<int> RoleIds { get; set; } = new List<int>();
    }

    public class StaffActivateViewModel
    {
        public string Code { get; set; }

        [Required(ErrorMessage = "請輸入帳號")]
        [StringLength(20, MinimumLength = 4, ErrorMessage = "帳號長度需介於 4 到 20 個字元")]
        [Display(Name = "帳號")]
        public string Account { get; set; }

        [Required(ErrorMessage = "請輸入密碼")]
        [DataType(DataType.Password)]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "密碼長度至少需 6 個字元")]
        [Display(Name = "密碼")]
        public string Password { get; set; }

        [DataType(DataType.Password)]
        [Display(Name = "確認密碼")]
        [Compare("Password", ErrorMessage = "密碼與確認密碼不符")]
        public string ConfirmPassword { get; set; }
    }

    public class RolesFunctionViewModel
    {
        public List<RoleDto> Roles { get; set; } = new List<RoleDto>();
        public List<FunctionDto> Functions { get; set; } = new List<FunctionDto>();
        public List<RoleFunctionMatrixRow> Matrix { get; set; } = new List<RoleFunctionMatrixRow>();
    }

    public class RoleFunctionMatrixRow
    {
        public int RoleId { get; set; }
        public string RoleName { get; set; }
        public Dictionary<int, bool> FunctionStatus { get; set; } = new Dictionary<int, bool>(); // Key: FunctionId, Value: IsEnabled
    }

    public class AddRoleFunctionViewModel
    {
        [Required(ErrorMessage = "請選擇角色")]
        public int RoleId { get; set; }

        [Required(ErrorMessage = "請選擇功能")]
        public List<int> FunctionIds { get; set; } = new List<int>();
    }
}
