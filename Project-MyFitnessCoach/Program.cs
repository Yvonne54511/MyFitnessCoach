using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Repos;
using Project_MyFitnessCoach.Services;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.EntityFrameworkCore;
using System.IO;

namespace Project_MyFitnessCoach
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            builder.Services.AddControllersWithViews();

            // 註冊 DbContext
            builder.Services.AddDbContext<ResRevContext>(option =>
            {
                option.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
            });

			// 註冊 ShiftRepository
			builder.Services.AddScoped<IShiftRepository, ShiftRepository>();

			// 註冊 Reservation 模組
			builder.Services.AddScoped<IReservationRepository, ReservationRepository>();
			builder.Services.AddScoped<ReservationService>();

			// 註冊 AdminRepository 與 AdminService
			builder.Services.AddScoped<IAdminRepository, AdminRepository>();
			builder.Services.AddScoped<IAdminService, AdminService>();

			// 註冊 BLL Service
			builder.Services.AddScoped<ShiftService>();

			// 註冊 LoginService
			builder.Services.AddScoped<LoginService>();
			// 註冊 LoginRepository（新增：介面與實作）
			builder.Services.AddScoped<ILoginRepository, LoginRepository>();

			// 註冊使用Cookie驗證服務
			builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
				.AddCookie(options =>
				{
					options.Cookie.Name = "ReservationDemo";
					options.LoginPath = "/Login/Index";
					options.AccessDeniedPath = "/Login/Index"; // 新增：權限不足時引導回登入頁
					options.Cookie.HttpOnly = true;
					options.Cookie.SameSite = SameSiteMode.Lax; // 明確設定為 Lax
					options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest; // 根據請求自動判斷 (HTTP 下不強制 Secure)
				});

			var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (!app.Environment.IsDevelopment())
            {
                app.UseExceptionHandler("/Home/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            // Serve static files and ensure text-based assets include charset=utf-8
            app.UseStaticFiles(new StaticFileOptions
            {
                OnPrepareResponse = ctx =>
                {
                    try
                    {
                        var path = ctx.File?.PhysicalPath ?? string.Empty;
                        var ext = string.IsNullOrEmpty(path) ? string.Empty : Path.GetExtension(path).ToLowerInvariant();
                        if (ext == ".js" || ext == ".css" || ext == ".json")
                        {
                            var ct = ctx.Context.Response.ContentType ?? string.Empty;
                            if (!ct.Contains("charset", StringComparison.OrdinalIgnoreCase))
                            {
                                if (!string.IsNullOrEmpty(ct))
                                {
                                    ctx.Context.Response.ContentType = ct + "; charset=utf-8";
                                }
                                else
                                {
                                    // fallback
                                    ctx.Context.Response.ContentType = ext == ".css" ? "text/css; charset=utf-8" : "application/javascript; charset=utf-8";
                                }
                            }
                        }
                    }
                    catch { /* ignore any error here to not break static file serving */ }
                }
            });

            app.UseRouting();

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapControllerRoute(
                name: "default",
                pattern: "{controller=Home}/{action=Index}/{id?}");

            app.Run();
        }
    }
}
