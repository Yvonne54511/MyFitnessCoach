namespace Project_MyFitnessCoach.Models.DTOs
{
    public class CategoryDto
    {
        public int Id { get; set; }
        public string CategoryName { get; set; }
        public int SortOrder { get; set; }
        public bool IsActive { get; set; }
    }
}
