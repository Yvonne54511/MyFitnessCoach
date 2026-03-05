using MyFitnessCoachDb.Models.EfModels;
using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.Repositories;
using Project_MyFitnessCoach.Models.Services;

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
