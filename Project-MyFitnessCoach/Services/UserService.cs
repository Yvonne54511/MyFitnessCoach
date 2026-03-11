using Microsoft.AspNetCore.Identity;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.ViewModel;
using Project_MyFitnessCoach.Repositories;
using System.Text;
using System.Collections.Generic;
using System;
using System.Linq;

namespace Project_MyFitnessCoach.Services
{
    public interface IUserService
    {
        IEnumerable<StaffListItemViewModel> GetStaffList();
        StaffEditViewModel GetStaffEditModel(int id);
        bool InviteStaff(StaffInviteViewModel model, Func<string, string> generateUrl);
        bool UpdateStaff(StaffEditViewModel model);
        bool DeleteStaff(int id);
        IEnumerable<Role> GetActiveRoles();
        bool ActivateAccount(StaffActivateViewModel model);
        bool IsConfirmCodeValid(string code);
        bool AccountExists(string account);
    }

    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
        private readonly IEmailService _emailService;
        private readonly PasswordHasher<User> _passwordHasher;

        public UserService(IUserRepository userRepository, IEmailService emailService)
        {
            _userRepository = userRepository;
            _emailService = emailService;
            _passwordHasher = new PasswordHasher<User>();
        }

        public IEnumerable<StaffListItemViewModel> GetStaffList()
        {
            return _userRepository.GetAllUsers().Select(u => new StaffListItemViewModel
            {
                Id = u.Id,
                UserName = u.UserName,
                Email = u.Email,
                Account = u.Account,
                IsConfirmed = u.IsConfirmed,
                IsActive = u.IsActive,
                Roles = u.UserRoles.Select(ur => ur.Role.RoleName).ToList()
            });
        }

        public StaffEditViewModel GetStaffEditModel(int id)
        {
            var user = _userRepository.GetUserById(id);
            if (user == null) return null;

            return new StaffEditViewModel
            {
                Id = user.Id,
                UserName = user.UserName,
                Email = user.Email,
                IsActive = user.IsActive,
                RoleIds = user.UserRoles.Select(ur => ur.RoleId).ToList()
            };
        }

        public bool InviteStaff(StaffInviteViewModel model, Func<string, string> generateUrl)
        {
            var existingUser = _userRepository.GetUserByEmail(model.Email);
            if (existingUser != null) return false;

            var confirmCode = Guid.NewGuid().ToString();
            var user = new User
            {
                UserName = model.UserName,
                Email = model.Email,
                IsConfirmed = false,
                IsActive = true,
                NewMemberConfirmCode = confirmCode,
                NewMemberConfirmCodeExpiry = DateTime.Now.AddDays(7)
            };

            _userRepository.CreateUser(user, model.RoleIds);

            var invitationUrl = generateUrl(confirmCode);
            return _emailService.SendStaffInvitationEmail(model.Email, model.UserName, invitationUrl);
        }

        public bool UpdateStaff(StaffEditViewModel model)
        {
            var user = new User
            {
                Id = model.Id,
                UserName = model.UserName,
                Email = model.Email,
                IsActive = model.IsActive
            };

            _userRepository.UpdateUser(user, model.RoleIds);
            return true;
        }

        public bool DeleteStaff(int id)
        {
            _userRepository.DeleteUser(id);
            return true;
        }

        public IEnumerable<Role> GetActiveRoles()
        {
            return _userRepository.GetAllRoles();
        }

        public bool ActivateAccount(StaffActivateViewModel model)
        {
            var user = _userRepository.GetUserByConfirmCode(model.Code);
            if (user == null || (user.NewMemberConfirmCodeExpiry.HasValue && user.NewMemberConfirmCodeExpiry < DateTime.Now))
            {
                return false;
            }

            user.Account = model.Account;
            user.HashedPassword = _passwordHasher.HashPassword(user, model.Password);
            user.IsConfirmed = true;
            user.IsActive = true;

            _userRepository.UpdateUser(user, null); // Roles won't be updated here
            return true;
        }

        public bool IsConfirmCodeValid(string code)
        {
            var user = _userRepository.GetUserByConfirmCode(code);
            return user != null && (!user.NewMemberConfirmCodeExpiry.HasValue || user.NewMemberConfirmCodeExpiry > DateTime.Now);
        }

        public bool AccountExists(string account)
        {
            return _userRepository.AccountExists(account);
        }
    }
}
