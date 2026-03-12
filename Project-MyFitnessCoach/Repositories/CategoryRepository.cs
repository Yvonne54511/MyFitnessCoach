using Project_MyFitnessCoach.Models.Dtos;
using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using Project_MyFitnessCoach.Models.DTOs;

namespace Project_MyFitnessCoach.Repositories
{
    public interface ICategoryRepository
    {
        List<CategoryDto> GetAll();
        CategoryDto GetById(int id);
        void Create(CategoryDto dto);
        void Update(CategoryDto dto);
        void Deactivate(int id);
    }

    public class CategoryRepository : ICategoryRepository
    {
        private readonly MyFitnessCoachDbContext _context;

        public CategoryRepository(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        public List<CategoryDto> GetAll()
        {
            return _context.ProductCategories
                .AsNoTracking()
                .OrderBy(c => c.SortOrder)
                .Select(c => c.ToDto())
                .ToList();
        }

        public CategoryDto GetById(int id)
        {
            var category = _context.ProductCategories
                .AsNoTracking()
                .FirstOrDefault(c => c.Id == id);
            return category?.ToDto();
        }

        public void Create(CategoryDto dto)
        {
            var entity = dto.ToEntity();
            _context.ProductCategories.Add(entity);
            _context.SaveChanges();
        }

        public void Update(CategoryDto dto)
        {
            var entity = _context.ProductCategories.Find(dto.Id);
            if (entity == null) return;

            entity.CategoryName = dto.CategoryName;
            entity.SortOrder = dto.SortOrder;
            entity.IsActive = dto.IsActive;

            _context.SaveChanges();
        }

        public void Deactivate(int id)
        {
            var entity = _context.ProductCategories.Find(id);
            if (entity == null) return;

            entity.IsActive = false;
            _context.SaveChanges();
        }
    }
}
