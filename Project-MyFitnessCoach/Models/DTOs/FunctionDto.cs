namespace Project_MyFitnessCoach.Models.DTOs
{
    public class FunctionDto
    {
        public int Id { get; set; }
        public string FunctionName { get; set; }
        public string Description { get; set; }
        public string ApiPath { get; set; }
        public bool IsActive { get; set; }
    }
}
