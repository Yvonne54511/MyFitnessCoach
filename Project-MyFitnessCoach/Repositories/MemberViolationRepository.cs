using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using System.Collections.Generic;
using System.Linq;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IMemberViolationRepository
    {
        List<MemberViolationDto> GetAll();
        MemberViolationDto GetById(int id);
        void Create(MemberViolationDto dto);
        void Update(MemberViolationDto dto);
        void Delete(int id);
        List<Member> GetMembersWithoutViolations();
    }

    public class MemberViolationRepository : IMemberViolationRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public MemberViolationRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public List<MemberViolationDto> GetAll()
        {
            return _context.MemberViolations
                .Include(mv => mv.Member)
                .ThenInclude(m => m.User)
                .Select(mv => mv.ToDto())
                .ToList();
        }

        public MemberViolationDto GetById(int id)
        {
            var entity = _context.MemberViolations
                .Include(mv => mv.Member)
                .ThenInclude(m => m.User)
                .FirstOrDefault(mv => mv.Id == id);
            return entity?.ToDto();
        }

        public void Create(MemberViolationDto dto)
        {
            var entity = dto.ToEntity();
            _context.MemberViolations.Add(entity);
            _context.SaveChanges();
        }

        public void Update(MemberViolationDto dto)
        {
            var entity = _context.MemberViolations
                .Include(mv => mv.Member)
                .ThenInclude(m => m.User)
                .FirstOrDefault(mv => mv.Id == dto.Id);

            if (entity != null)
            {
                entity.WarningCount = dto.WarningCount;
                entity.IsSuspended = dto.IsSuspended;
                entity.LastWarningAt = dto.LastWarningAt;
                entity.SuspendedAt = dto.SuspendedAt;
                entity.Reason = dto.Reason;

                _context.SaveChanges();
            }
        }

        public void Delete(int id)
        {
            var entity = _context.MemberViolations.Find(id);
            if (entity != null)
            {
                _context.MemberViolations.Remove(entity);
                _context.SaveChanges();
            }
        }

        public List<Member> GetMembersWithoutViolations()
        {
            // Get members who don't have a violation record yet
            var violationMemberIds = _context.MemberViolations.Select(mv => mv.MemberId).ToList();
            return _context.Members
                .Include(m => m.User)
                .Where(m => !violationMemberIds.Contains(m.Id))
                .ToList();
        }
    }
}