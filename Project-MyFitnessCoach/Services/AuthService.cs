using Microsoft.AspNetCore.Identity;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Repositories;

namespace Project_MyFitnessCoach.Services
{
    public interface IAuthService
    {
        (bool Success, string Message) Register(RegisterViewModel model);
        (bool Success, string Message) Activate(int userId, string confirmCode);
    }

    public class AuthService : IAuthService
    {
        private readonly IAuthRepository _repo;
        private readonly PasswordHasher<User> _passwordHasher;
        private readonly MyFitnessCoachDbContext _db; // Needed for transaction if repo doesn't handle it

        public AuthService(IAuthRepository repo, MyFitnessCoachDbContext db)
        {
            _repo = repo;
            _db = db;
            _passwordHasher = new PasswordHasher<User>();
        }

        public (bool Success, string Message) Activate(int userId, string confirmCode)
        {
            var user = _db.Users.FirstOrDefault(u => u.Id == userId);
            if (user == null) return (false, "找不到使用者");
            if (user.IsConfirmed) return (true, "帳號已驗證成功");
            if (user.NewMemberConfirmCode != confirmCode) return (false, "驗證碼不正確");
            if (user.NewMemberConfirmCodeExpiry < DateTime.Now) return (false, "驗證碼已過期");

            user.IsConfirmed = true;
            user.NewMemberConfirmCode = null;
            user.NewMemberConfirmCodeExpiry = null;
            _db.SaveChanges();

            return (true, "驗證成功，您可以登入了");
        }

        public (bool Success, string Message) Register(RegisterViewModel model)
        {
            if (_repo.IsAccountExist(model.Account))
            {
                return (false, "此帳號已存在");
            }

            if (_repo.IsEmailExist(model.Email))
            {
                return (false, "此電子郵件已註冊過");
            }

            using (var transaction = _db.Database.BeginTransaction())
            {
                try
                {
                    var user = new User
                    {
                        Account = model.Account,
                        UserName = model.UserName,
                        Email = model.Email,
                        Mobile = model.Mobile,
                        IsConfirmed = false, // 改為 false，需驗證
                        NewMemberConfirmCode = Guid.NewGuid().ToString(), // 產生驗證碼
                        NewMemberConfirmCodeExpiry = DateTime.Now.AddHours(24), // 24小時有效
                        HashedPassword = "" // Placeholder
                    };

                    user.HashedPassword = _passwordHasher.HashPassword(user, model.Password);

                    _db.Users.Add(user);
                    _db.SaveChanges(); // Save to get the UserId

                    // Create Member record
                    var member = new Member
                    {
                        UserId = user.Id,
                        CancelCount = 0
                        // Other fields can be null as per schema
                    };
                    _db.Members.Add(member);

                    // Add default role: member (Id=1 as per your SQL snippet)
                    var userRole = new UserRole
                    {
                        UserId = user.Id,
                        RoleId = 1 
                    };
                    _db.UserRoles.Add(userRole);

                    _db.SaveChanges();
                    transaction.Commit();

                    return (true, "註冊成功");
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return (false, $"註冊發生錯誤: {ex.Message}");
                }
            }
        }
    }
}
