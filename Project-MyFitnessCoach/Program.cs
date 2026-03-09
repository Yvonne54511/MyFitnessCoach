using Microsoft.EntityFrameworkCore;
using MyFitnessCoachDb.Models.EfModels;
using MyFitnessCoachDb.Models.Repositories;
using MyFitnessCoachDb.Models.Services;

namespace Project_MyFitnessCoach
{
	public class Program
	{
		public static void Main(string[] args)
		{
			var builder = WebApplication.CreateBuilder(args);

			// Add services to the container.
			builder.Services.AddRazorPages();
			builder.Services.AddControllersWithViews();
			
			// Register DbContext
			builder.Services.AddDbContext<MyFitnessCoachDBContext>(options =>
				options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

			// 註冊三層式架構組件
			builder.Services.AddScoped<IProductOrderRepository, ProductOrderRepository>();
			builder.Services.AddScoped<ProductOrderService>();

			// �]�w��Ʈw�s��
			builder.Services.AddDbContext<MyFitnessCoachDbContext>(options =>
				options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

			// ���U���~�A��
			// U~A
			builder.Services.AddScoped<IProductRepository, ProductRepository>();
			builder.Services.AddScoped<ProductService>();
			builder.Services.AddScoped<ICategoryRepository, CategoryRepository>();
			builder.Services.AddScoped<CategoryService>();
			builder.Services.AddScoped<ITopUpPlanRepository, TopUpPlanRepository>();
			builder.Services.AddScoped<TopUpPlanService>();

			var app = builder.Build();

			// Configure the HTTP request pipeline.
			if (!app.Environment.IsDevelopment())
			{
				app.UseExceptionHandler("/Home/Error");
				// The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
				app.UseHsts();
			}

			app.UseHttpsRedirection();
			app.UseStaticFiles();

			app.UseRouting();

			app.UseAuthorization();

			app.MapRazorPages();

			app.MapControllerRoute(
				name: "default",
				pattern: "{controller=Home}/{action=Index}/{id?}");

			app.Run();
		}
	}
}
