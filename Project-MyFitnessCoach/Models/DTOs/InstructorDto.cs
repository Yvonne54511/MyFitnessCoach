using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public class InstructorDto
    {
        public int Id { get; set; }
        
        [Required(ErrorMessage = "使用者ID為必填")]
        public int UserId { get; set; }
        
        [Display(Name = "營養師姓名")]
        public string? UserName { get; set; }
        
        [Display(Name = "形象照URL")]
        public string? ImageUrl { get; set; }
        
        [Display(Name = "個人簡介")]
        [StringLength(1000, ErrorMessage = "簡介不能超過1000字")]
        public string? Description { get; set; }
        
        [Required(ErrorMessage = "時薪為必填")]
        [Range(1, 10000, ErrorMessage = "時薪必須介於1到10000之間")]
        [Display(Name = "時薪")]
        public int HourWage { get; set; }
        
        [Display(Name = "取消次數")]
        public int CancelCount { get; set; }
        
        [Display(Name = "是否有效")]
        public bool IsActive { get; set; }
    }
}
