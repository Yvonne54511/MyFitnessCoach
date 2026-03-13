using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Models.DTOs
{
	public class PointsRecordDetailDto
	{
		public int Id { get; set; }

		public int PointOrderId { get; set; }

		public int UserWalletId { get; set; }

		public DateTime CreateAt { get; set; }

		public int PointAmount { get; set; }

		public string MerchandiseCategory { get; set; }

		public int? ReserveOrderId { get; set; }

		public virtual PointOrder PointOrder { get; set; }

		public virtual ReserveOrder ReserveOrder { get; set; }

		public virtual UserWallet UserWallet { get; set; }
	}
}
