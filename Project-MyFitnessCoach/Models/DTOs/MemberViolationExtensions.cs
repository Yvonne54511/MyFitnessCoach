using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using System.Linq;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public static class MemberViolationExtensions
    {
        public static MemberViolationDto ToDto(this MemberViolation entity)
        {
            if (entity == null) return null;

            return new MemberViolationDto
            {
                Id = entity.Id,
                MemberId = entity.MemberId,
                MemberName = entity.Member?.User?.UserName ?? "Unknown", // Assuming Member -> User -> UserName
                MemberEmail = entity.Member?.User?.Email ?? "Unknown",
                WarningCount = entity.WarningCount,
                IsSuspended = entity.IsSuspended,
                LastWarningAt = entity.LastWarningAt,
                SuspendedAt = entity.SuspendedAt,
                Reason = entity.Reason
            };
        }

        public static MemberViolation ToEntity(this MemberViolationDto dto)
        {
            if (dto == null) return null;

            return new MemberViolation
            {
                Id = dto.Id,
                MemberId = dto.MemberId,
                WarningCount = dto.WarningCount,
                IsSuspended = dto.IsSuspended,
                LastWarningAt = dto.LastWarningAt,
                SuspendedAt = dto.SuspendedAt,
                Reason = dto.Reason
            };
        }
    }
}