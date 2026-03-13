namespace Project_MyFitnessCoach.Models.DTOs
{
	public class ProductDto
	{
		public int Id { get; set; }

		public int CategoryId { get; set; }

		public string Name { get; set; } = string.Empty;

		public string? ImageUrl { get; set; }

		public decimal OriginalPrice { get; set; }

		public decimal UnitPrice { get; set; }

		public string? Description { get; set; }

		public int SortOrder { get; set; }

		public bool IsActive { get; set; }

		public string? CategoryName { get; set; }
	}
}
