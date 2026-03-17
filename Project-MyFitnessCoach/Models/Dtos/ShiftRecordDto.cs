namespace Project_MyFitnessCoach.Models.Dtos
{
    public class ShiftRecordDto
	{   // 顯示講師自己的班表 (Instructor 模式)
		public System.DateOnly Date { get; set; }
        public string Slot { get; set; }
    }
}
