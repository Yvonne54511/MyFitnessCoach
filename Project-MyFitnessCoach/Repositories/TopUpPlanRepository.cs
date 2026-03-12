using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using Project_MyFitnessCoach.Models.DTOs;

namespace Project_MyFitnessCoach.Repositories
{
    public interface ITopUpPlanRepository
    {
        List<TopUpPlanDto> GetAll();
        TopUpPlanDto GetById(int id);
        void Create(TopUpPlanDto dto);
        void Update(TopUpPlanDto dto);
        void Deactivate(int id);
    }

    public class TopUpPlanRepository : ITopUpPlanRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public TopUpPlanRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public List<TopUpPlanDto> GetAll()
        {
            return _context.TopUpPlans
                .AsNoTracking()
                .OrderBy(p => p.SortOrder)
                .Select(p => p.ToDto())
                .ToList();
        }

        public TopUpPlanDto GetById(int id)
        {
            var plan = _context.TopUpPlans
                .AsNoTracking()
                .FirstOrDefault(p => p.Id == id);
            return plan?.ToDto();
        }

        public void Create(TopUpPlanDto dto)
        {
            var entity = dto.ToEntity();
            _context.TopUpPlans.Add(entity);
            _context.SaveChanges();
        }

        public void Update(TopUpPlanDto dto)
        {
            var entity = _context.TopUpPlans.Find(dto.Id);
            if (entity == null) return;

            entity.PlanName = dto.PlanName;
            entity.Price = dto.Price ?? 0;
            entity.Points = dto.Points ?? 0;
            entity.Description = dto.Description;
            entity.IsActive = dto.IsActive;
            entity.SortOrder = dto.SortOrder ?? 0;

            _context.SaveChanges();
        }

        public void Deactivate(int id)
        {
            var entity = _context.TopUpPlans.Find(id);
            if (entity == null) return;

            entity.IsActive = false;
            _context.SaveChanges();
        }
    }
}
