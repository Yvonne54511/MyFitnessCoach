using System;
using Project_MyFitnessCoach.Models.DTOs;
using System.Collections.Generic;

namespace Project_MyFitnessCoach.Models.ViewModels
{
    public class KeyWordAnalyticsViewModel
    {
        public IEnumerable<KeyWordFrequencyDto> AllKeyWords { get; set; } = new List<KeyWordFrequencyDto>();
        public IEnumerable<KeyWordFrequencyDto> PagedKeyWords { get; set; } = new List<KeyWordFrequencyDto>();
        
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 20;
        public int TotalItems { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalItems / (PageSize > 0 ? PageSize : 1));
        
        public int SelectedYear { get; set; }
        public int SelectedMonth { get; set; }
        
        public string? SelectedCategory { get; set; } // "all", "1", "-1", "null"
        public int MinCount { get; set; } = 0;

        // Top 10 lists for charts
        public IEnumerable<KeyWordFrequencyDto> Top10Positive { get; set; } = new List<KeyWordFrequencyDto>();
        public IEnumerable<KeyWordFrequencyDto> Top10Negative { get; set; } = new List<KeyWordFrequencyDto>();
    }
}
