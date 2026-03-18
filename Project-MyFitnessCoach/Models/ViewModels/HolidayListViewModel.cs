#nullable disable
using Microsoft.AspNetCore.Mvc.Rendering;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class HolidayListViewModel
    {
        public int YearFilter { get; set; }
        public List<HolidayItemDto> Holidays { get; set; } = new List<HolidayItemDto>();
        public List<SelectListItem> YearOptions { get; set; } = new List<SelectListItem>();
    }

    public class HolidayItemDto
    {
        public int Id { get; set; }
        public DateTime HolidayDate { get; set; }
        public string Name { get; set; }
        public int Year { get; set; }
        public bool IsActive { get; set; }
    }
}
