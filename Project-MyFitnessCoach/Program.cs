using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.Infra;
using Project_MyFitnessCoach.Models.Repositories;
using Project_MyFitnessCoach.Models.Services;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Repositories;
using Project_MyFitnessCoach.Services;

namespace Project_MyFitnessCoach
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            builder.Services.AddControllersWithViews();
            builder.Services.AddRazorPages();

            // Register DbContext
            builder.Services.AddDbContext<MyFitnessCoachDbContext>(options =>
                options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

            // 註冊三層式架構組件
            builder.Services.AddScoped<IProductOrderRepository, ProductOrderRepository>();
            builder.Services.AddScoped<ProductOrderService>();

            builder.Services.AddScoped<IProductRepository, ProductRepository>();
            builder.Services.AddScoped<ProductService>();
            builder.Services.AddScoped<ICategoryRepository, CategoryRepository>();
            builder.Services.AddScoped<CategoryService>();
            builder.Services.AddScoped<ITopUpPlanRepository, TopUpPlanRepository>();
            builder.Services.AddScoped<TopUpPlanService>();

            builder.Services
                .AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
                .AddCookie(options =>
                {
                    options.LoginPath = "/Account/Login";
                    options.AccessDeniedPath = "/Account/Login";
                });

            builder.Services.AddScoped<IAuthRepository, AuthRepository>();
            builder.Services.AddScoped<IAuthService, AuthService>();
            builder.Services.AddScoped<IAccountRepository, AccountRepository>();
            builder.Services.AddScoped<BCryptPasswordHasher>();
            //builder.Services.AddScoped<Microsoft.AspNetCore.Identity.IPasswordHasher<User>>(sp => sp.GetRequiredService<BCryptPasswordHasher>());
			builder.Services.AddScoped<IPasswordHasher<User>, PasswordHasher<User>>();
			builder.Services.AddScoped<IMemberAccountService, MemberAccountService>();
            builder.Services.AddScoped<IEmailService, EmailService>();
            builder.Services.AddScoped<IDashboardRepository, DashboardRepository>();
            builder.Services.AddScoped<IDashboardService, DashboardService>();
            builder.Services.AddScoped<IUserRepository, UserRepository>();
            builder.Services.AddScoped<IUserService, UserService>();

            var app = builder.Build();

            if (!app.Environment.IsDevelopment())
            {
                app.UseExceptionHandler("/Home/Error");
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapRazorPages();

            app.MapControllerRoute(
                name: "default",
                pattern: "{controller=Home}/{action=Index}/{id?}");

            // --- Seed Admin User ---
            using (var scope = app.Services.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<MyFitnessCoachDbContext>();
                
                // 如果 admin 帳號不存在，才進行建立
                if (!db.Users.Any(u => u.Account == "admin"))
                {
                    var hasher = scope.ServiceProvider.GetRequiredService<Microsoft.AspNetCore.Identity.IPasswordHasher<User>>();
                    var adminUser = new User
                    {
                        Account = "admin",
                        UserName = "系統管理員",
                        Email = "admin@myfitnesscoach.com",
                        IsConfirmed = true,
                        IsActive = true
                    };
                    
                    // 由程式產生符合當前環境的正確雜湊值
                    adminUser.HashedPassword = hasher.HashPassword(adminUser, "123456");

                    db.Users.Add(adminUser);
                    db.SaveChanges();

                    // 分配角色 (Id 為 1 的角色)
                    if (db.Roles.Any(r => r.Id == 1))
                    {
                        db.UserRoles.Add(new UserRole { UserId = adminUser.Id, RoleId = 1 });
                        db.SaveChanges();
                    }
                }
            }
            // -----------------------

            app.Run();
        }
    }
}
