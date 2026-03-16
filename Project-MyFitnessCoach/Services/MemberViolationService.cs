using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Repositories;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Services
{
    public interface IMemberViolationService
    {
        List<MemberViolationDto> GetAll();
        MemberViolationDto GetById(int id);
        void Create(MemberViolationDto dto);
        void Update(MemberViolationDto dto);
        void Delete(int id);
        List<Member> GetMembersAvailableForViolation();
    }

    public class MemberViolationService : IMemberViolationService
    {
        private readonly IMemberViolationRepository _repository;

        public MemberViolationService(IMemberViolationRepository repository)
        {
            _repository = repository;
        }

        public List<MemberViolationDto> GetAll()
        {
            return _repository.GetAll();
        }

        public MemberViolationDto GetById(int id)
        {
            return _repository.GetById(id);
        }

        public void Create(MemberViolationDto dto)
        {
            _repository.Create(dto);
        }

        public void Update(MemberViolationDto dto)
        {
            _repository.Update(dto);
        }

        public void Delete(int id)
        {
            _repository.Delete(id);
        }

        public List<Member> GetMembersAvailableForViolation()
        {
            return _repository.GetMembersWithoutViolations();
        }
    }
}