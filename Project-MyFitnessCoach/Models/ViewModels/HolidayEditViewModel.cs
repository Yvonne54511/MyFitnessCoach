#nullable disable
using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class HolidayEditViewModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "日期為必填")]
        [DataType(DataType.Date)]
        [Display(Name = "假日日期")]
        public DateTime HolidayDate { get; set; } = DateTime.Today;

        [Required(ErrorMessage = "名稱為必填")]
        [MaxLength(50)]
        [Display(Name = "假日名稱")]
        public string Name { get; set; }

        [Display(Name = "啟用")]
        public bool IsActive { get; set; } = true;
    }
}
