using System;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.DTOs
{
    public class InstructorWalletDto
    {
        public int Id { get; set; }
        public int InstructorId { get; set; }
        public string InstructorName { get; set; }
        public decimal CurrentBalance { get; set; }
        public DateTime LastUpdated { get; set; }
        public List<InstructorWalletDetailDto> Details { get; set; } = new List<InstructorWalletDetailDto>();
    }

    public class InstructorWalletDetailDto
    {
        public int Id { get; set; }
        public string SalaryDate { get; set; }
        public decimal TotalAmount { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class InstructorWalletExportDto
    {
        public string? InstructorName { get; set; }
        public string? SalaryDate { get; set; }
        public decimal TotalAmount { get; set; }
    }
}
