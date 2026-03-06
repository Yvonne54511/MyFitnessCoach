using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach
{
	public class Program
	{
		public static void Main(string[] args)
		{
			var builder = WebApplication.CreateBuilder(args);

			// Add services to the container.
			builder.Services.AddControllersWithViews();
			builder.Services.AddDbContext<MyFitnessCoachDbContext>(options =>
options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

			// Register Auth Services and Repositories
			builder.Services.AddScoped<Project_MyFitnessCoach.Repositories.IAuthRepository, Project_MyFitnessCoach.Repositories.AuthRepository>();
			builder.Services.AddScoped<Project_MyFitnessCoach.Services.IAuthService, Project_MyFitnessCoach.Services.AuthService>();

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

			app.MapControllerRoute(
				name: "default",
				pattern: "{controller=Home}/{action=Index}/{id?}");

			app.Run();
		}
	}
}
