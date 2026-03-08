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
        private readonly MyFitnessCoachDbContext _db;

        public AuthService(IAuthRepository repo, MyFitnessCoachDbContext db)
        {
            _repo = repo;
            _db = db;
            _passwordHasher = new PasswordHasher<User>();
        }

        public (bool Success, string Message) Activate(int userId, string confirmCode)
        {
            var user = _db.Users.FirstOrDefault(u => u.Id == userId);
            if (user == null) return (false, "找不到使用者資料");
            if (user.IsConfirmed) return (true, "帳號已驗證成功");
            if (user.NewMemberConfirmCode != confirmCode) return (false, "驗證碼錯誤");
            if (user.NewMemberConfirmCodeExpiry < DateTime.Now) return (false, "驗證碼已過期");

            user.IsConfirmed = true;
            user.IsActive = true;
            user.NewMemberConfirmCode = null;
            user.NewMemberConfirmCodeExpiry = null;
            _db.SaveChanges();

            return (true, "驗證成功，現在可以登入系統");
        }

        public (bool Success, string Message) Register(RegisterViewModel model)
        {
            if (_repo.IsAccountExist(model.Account))
            {
                return (false, "帳號已存在");
            }

            if (_repo.IsEmailExist(model.Email))
            {
                return (false, "電子信箱已被使用");
            }

            using var transaction = _db.Database.BeginTransaction();
            try
            {
                var user = new User
                {
                    Account = model.Account,
                    UserName = model.UserName,
                    Email = model.Email,
                    Mobile = model.Mobile,
                    IsConfirmed = false,
                    IsActive = false,
                    NewMemberConfirmCode = Guid.NewGuid().ToString(),
                    NewMemberConfirmCodeExpiry = DateTime.Now.AddHours(24),
                    HashedPassword = string.Empty
                };

                user.HashedPassword = _passwordHasher.HashPassword(user, model.Password);

                _db.Users.Add(user);
                _db.SaveChanges();

                var member = new Member
                {
                    UserId = user.Id,
                    CancelCount = 0
                };
                _db.Members.Add(member);

                var userRole = new UserRole
                {
                    UserId = user.Id,
                    RoleId = 1
                };
                _db.UserRoles.Add(userRole);

                _db.SaveChanges();
                transaction.Commit();

                return (true, "註冊成功，請前往信箱完成驗證");
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                return (false, $"註冊失敗: {ex.Message}");
            }
        }
    }
}
