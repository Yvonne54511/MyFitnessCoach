using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Models.DTOs
{
	public class UserWalletDto
	{
		public int Id { get; set; }

		public int MemberId { get; set; }

		public decimal CurrentBalance { get; set; }

		public DateTime LastUpdated { get; set; }

		public virtual Member Member { get; set; }

		public virtual ICollection<PointsRecordDetail> PointsRecordDetails { get; set; } = new List<PointsRecordDetail>();
	}
}
