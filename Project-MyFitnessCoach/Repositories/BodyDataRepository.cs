using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IBodyDataRepository
    {
        IEnumerable<BodyRecord> GetAll(string searchName, DateTime? from, DateTime? to);
        IEnumerable<BodyRecord> GetByMemberId(int memberId);
    }

    public class BodyDataRepository : IBodyDataRepository
    {
        private readonly MyFitnessCoachDbContext _db;

        public BodyDataRepository(MyFitnessCoachDbContext db)
        {
            _db = db;
        }

        public IEnumerable<BodyRecord> GetAll(string searchName, DateTime? from, DateTime? to)
        {
            var query = _db.BodyRecords
                .Include(b => b.Member)
                    .ThenInclude(m => m.User)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchName))
                query = query.Where(b => b.Member.User.UserName.Contains(searchName));

            if (from.HasValue)
                query = query.Where(b => b.CreateAt >= from.Value);

            if (to.HasValue)
                query = query.Where(b => b.CreateAt <= to.Value.AddDays(1));

            return query.OrderByDescending(b => b.CreateAt).ToList();
        }

        public IEnumerable<BodyRecord> GetByMemberId(int memberId)
        {
            return _db.BodyRecords
                .Include(b => b.Member)
                    .ThenInclude(m => m.User)
                .Where(b => b.MemberId == memberId)
                .OrderBy(b => b.CreateAt)
                .ToList();
        }
    }
}
