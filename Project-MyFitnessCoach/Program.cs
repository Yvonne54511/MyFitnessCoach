using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.Infra;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Models.Services;
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

            // Permission Management
            builder.Services.AddScoped<Project_MyFitnessCoach.Repositories.IRoleRepository, Project_MyFitnessCoach.Repositories.RoleRepository>();
            builder.Services.AddScoped<Project_MyFitnessCoach.Repositories.IFunctionRepository, Project_MyFitnessCoach.Repositories.FunctionRepository>();
            builder.Services.AddScoped<Project_MyFitnessCoach.Repositories.IRoleFunctionRepository, Project_MyFitnessCoach.Repositories.RoleFunctionRepository>();
            builder.Services.AddScoped<PermissionService>();

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
            builder.Services.AddScoped<IInstructorRepository, InstructorRepository>();
            builder.Services.AddScoped<IInstructorService, InstructorService>();

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


            // 註冊 Review 模組
            builder.Services.AddScoped<IReviewRepository, ReviewRepository>();
            builder.Services.AddScoped<ReviewService>();

            // 註冊 Notification 模組
            builder.Services.AddScoped<INotificationRepository, NotificationRepository>();
            builder.Services.AddScoped<NotificationService>();

            // 註冊 BodyData 模組
            builder.Services.AddScoped<IBodyDataRepository, BodyDataRepository>();
            builder.Services.AddScoped<IBodyDataService, BodyDataService>();

            // 註冊 KeyWord 模組
            builder.Services.AddScoped<IKeyWordRepository, KeyWordRepository>();
            builder.Services.AddScoped<IKeyWordService, KeyWordService>();

            // 註冊 MemberViolation 模組
            builder.Services.AddScoped<IMemberViolationRepository, MemberViolationRepository>();
            builder.Services.AddScoped<IMemberViolationService, MemberViolationService>();

            // 註冊 Salary 模組
            builder.Services.AddScoped<ISalaryService, SalaryService>();

			// 註冊使用Cookie驗證服務
			builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
				.AddCookie(options =>
				{
					options.Cookie.Name = "MyFitnessCoach.Auth";
					options.LoginPath = "/Account/Login";
					options.AccessDeniedPath = "/Home/Error/403"; // 修改：權限不足時導向自訂 403 頁面
					options.Cookie.HttpOnly = true;
					options.Cookie.SameSite = SameSiteMode.Lax; // 明確設定為 Lax
					options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest; // 根據請求自動判斷 (HTTP 下不強制 Secure)
				});

			var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (!app.Environment.IsDevelopment())
            {
                app.UseExceptionHandler("/Home/Error");
                app.UseHsts();
            }
            else
            {
                // 開發環境也啟用自訂錯誤頁面以便測試，或者你可以保持原樣
                app.UseExceptionHandler("/Home/Error");
            }

            app.UseStatusCodePagesWithReExecute("/Home/Error/{0}");

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

            app.MapRazorPages();

            app.MapControllerRoute(
                name: "default",
                pattern: "{controller=Account}/{action=Login}/{id?}");

            /* --- Seed Admin User ---
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

                    // 分配角色 (名稱為 "admin" 的角色)
                    var adminRole = db.Roles.FirstOrDefault(r => r.RoleName == "admin");
                    if (adminRole != null)
                    {
                        db.UserRoles.Add(new UserRole { UserId = adminUser.Id, RoleId = adminRole.Id });
                        db.SaveChanges();
                    }
                    else if (db.Roles.Any(r => r.Id == 5)) // Fallback to Id 5 if name check fails but Id 5 exists
                    {
                        db.UserRoles.Add(new UserRole { UserId = adminUser.Id, RoleId = 5 });
                        db.SaveChanges();
                    }
                }
            }
            */ 

            app.Run();
        }
    }
}
