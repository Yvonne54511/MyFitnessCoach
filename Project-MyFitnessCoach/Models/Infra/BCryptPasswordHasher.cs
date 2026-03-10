using Microsoft.AspNetCore.Identity;
using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Models.Infra
{
    public class BCryptPasswordHasher : IPasswordHasher<User>
    {
        private readonly PasswordHasher<User> _legacyPasswordHasher = new();

        public string HashPassword(User user, string password)
        {
            return HashWithBCrypt(password);
        }

        public PasswordVerificationResult VerifyHashedPassword(User user, string hashedPassword, string providedPassword)
        {
            if (string.IsNullOrWhiteSpace(hashedPassword))
            {
                return PasswordVerificationResult.Failed;
            }

            if (IsBCryptHash(hashedPassword))
            {
                return VerifyWithBCrypt(providedPassword, hashedPassword)
                    ? PasswordVerificationResult.Success
                    : PasswordVerificationResult.Failed;
            }

            var legacyResult = _legacyPasswordHasher.VerifyHashedPassword(user, hashedPassword, providedPassword);
            return legacyResult == PasswordVerificationResult.Failed
                ? PasswordVerificationResult.Failed
                : PasswordVerificationResult.SuccessRehashNeeded;
        }

        public string HashWithBCrypt(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password);
        }

        public bool VerifyWithBCrypt(string password, string hashedPassword)
        {
            return BCrypt.Net.BCrypt.Verify(password, hashedPassword);
        }

        private static bool IsBCryptHash(string hashedPassword)
        {
            return hashedPassword.StartsWith("$2a$")
                || hashedPassword.StartsWith("$2b$")
                || hashedPassword.StartsWith("$2x$")
                || hashedPassword.StartsWith("$2y$");
        }
    }
}
