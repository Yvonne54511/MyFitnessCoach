using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
	public class ProductIndexItemViewModel
	{
		[Display(Name = "編號")]
		public int Id { get; set; }

		[Display(Name = "分類編號")]
		public int CategoryId { get; set; }

		[Display(Name = "產品名稱")]
		public string Name { get; set; }

		[Display(Name = "圖片網址")]
		public string ImageUrl { get; set; }

		[Display(Name = "原價")]
		public decimal OriginalPrice { get; set; }

		[Display(Name = "單價")]
		public decimal UnitPrice { get; set; }

		[Display(Name = "描述")]
		public string Description { get; set; }

		[Display(Name = "排序")]
		public int SortOrder { get; set; }

		[Display(Name = "是否啟用")]
		public bool IsActive { get; set; }

		[Display(Name = "分類名稱")]
		public string CategoryName { get; set; }
	}
}
