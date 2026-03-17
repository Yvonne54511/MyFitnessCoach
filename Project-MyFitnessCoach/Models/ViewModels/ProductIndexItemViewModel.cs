using System.ComponentModel.DataAnnotations;

namespace Project_MyFitnessCoach.Models.ViewModels
{
	public class ProductIndexItemViewModel
	{
		[Display(Name = "編號")]
		public int Id { get; set; }

		[Display(Name = "分類編號")]
		public int CategoryId { get; set; }

		[Display(Name = "商品名稱")]
		[Required(ErrorMessage = "{0} 為必填")]
		public string Name { get; set; } = string.Empty;

		[Display(Name = "圖片")]
		public string? ImageUrl { get; set; }

		[Display(Name = "原價")]
		[Range(0, 1000000, ErrorMessage = "{0} 必須在 {1} 與 {2} 之間")]
		public decimal OriginalPrice { get; set; }

		[Display(Name = "單價")]
		[Range(0, 1000000, ErrorMessage = "{0} 必須在 {1} 與 {2} 之間")]
		public decimal UnitPrice { get; set; }

		[Display(Name = "描述")]
		public string? Description { get; set; }

		[Display(Name = "排序")]
		public int SortOrder { get; set; }

		[Display(Name = "是否上架")]
		public bool IsActive { get; set; }

		[Display(Name = "分類名稱")]
		public string? CategoryName { get; set; }
		[Display(Name = "商品圖片檔案")]
		public Microsoft.AspNetCore.Http.IFormFile? ProductImage { get; set; }
	}
}
