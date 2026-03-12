namespace Project_MyFitnessCoach.Models.DTOs
{
    public class FunctionDto
    {
        public int Id { get; set; }
        public string FunctionName { get; set; }
        public string Description { get; set; }
        public string api_path { get; set; }
        public string ApiPath { get => api_path; set => api_path = value; }
        public bool IsActive { get; set; }
    }
}
