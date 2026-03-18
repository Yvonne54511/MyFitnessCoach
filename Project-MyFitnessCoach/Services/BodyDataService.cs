using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Repositories;
using System;
using System.Linq;

namespace Project_MyFitnessCoach.Services
{
    public interface IBodyDataService
    {
        /// <summary>取得身體數據列表（含統計摘要與趨勢資料）</summary>
        BodyDataResultDto GetBodyData(BodyDataQueryDto query);

        /// <summary>取得單一會員的完整身體數據歷史</summary>
        MemberHistoryDto GetMemberHistory(int memberId);
    }

    public class BodyDataService : IBodyDataService
    {
        private readonly IBodyDataRepository _bodyDataRepo;

        public BodyDataService(IBodyDataRepository bodyDataRepo)
        {
            _bodyDataRepo = bodyDataRepo;
        }

        public BodyDataResultDto GetBodyData(BodyDataQueryDto query)
        {
            DateTime? from = DateTime.TryParse(query.DateFrom, out var df) ? df : null;
            DateTime? to   = DateTime.TryParse(query.DateTo,   out var dt) ? dt : null;

            var records = _bodyDataRepo.GetAll(query.SearchName, from, to).ToList();

            var rows = records.Select(b => new BodyRecordDto
            {
                Id                 = b.Id,
                MemberId           = b.MemberId,
                MemberName         = b.Member?.User?.UserName ?? "未知",
                MemberTarget       = b.Member?.Target,
                Weight             = b.Weight,
                BodyFat            = b.BodyFat,
                SkeletalMuscle     = b.SkeletalMuscle,
                WaistCircumference = b.WaistCircumference,
                CreateAt           = b.CreateAt,
                Note               = b.Note,
                ImageUrl           = b.ImageUrl
            }).ToList();

            // 各會員趨勢資料（依時間升冪）
            var trends = records
                .GroupBy(b => b.MemberId)
                .ToDictionary(
                    g => g.Key,
                    g =>
                    {
                        var ordered = g.OrderBy(b => b.CreateAt).ToList();
                        return new MemberBodyTrendDto
                        {
                            MemberId        = g.Key,
                            MemberName      = ordered.First().Member?.User?.UserName ?? "未知",
                            Dates           = ordered.Select(b => b.CreateAt.ToString("MM/dd")).ToList(),
                            Weights         = ordered.Select(b => b.Weight).ToList(),
                            BodyFats        = ordered.Select(b => b.BodyFat.HasValue
                                                ? (double?)Convert.ToDouble(b.BodyFat.Value) : null).ToList(),
                            SkeletalMuscles = ordered.Select(b => b.SkeletalMuscle.HasValue
                                                ? (double?)Convert.ToDouble(b.SkeletalMuscle.Value) : null).ToList()
                        };
                    });

            double? avgWeight  = records.Any() ? records.Average(b => b.Weight) : null;
            double? avgBodyFat = records.Any(b => b.BodyFat.HasValue)
                ? (double?)Convert.ToDouble(records.Where(b => b.BodyFat.HasValue).Average(b => b.BodyFat!.Value))
                : null;

            return new BodyDataResultDto
            {
                Records      = rows,
                SearchName   = query.SearchName,
                DateFrom     = query.DateFrom,
                DateTo       = query.DateTo,
                TotalRecords = rows.Count,
                TotalMembers = rows.Select(r => r.MemberId).Distinct().Count(),
                AvgWeight    = avgWeight.HasValue  ? Math.Round(avgWeight.Value,  1) : null,
                AvgBodyFat   = avgBodyFat.HasValue ? Math.Round(avgBodyFat.Value, 1) : null,
                MemberTrends = trends
            };
        }

        public MemberHistoryDto GetMemberHistory(int memberId)
        {
            var records = _bodyDataRepo.GetByMemberId(memberId).ToList();
            if (!records.Any()) return null;

            var member = records.First().Member;
            var first  = records.First();
            var last   = records.Last();

            double? weightChange = records.Count > 1
                ? Math.Round(last.Weight - first.Weight, 1) : null;

            double? bodyFatChange = records.Count > 1 && last.BodyFat.HasValue && first.BodyFat.HasValue
                ? Math.Round(Convert.ToDouble(last.BodyFat.Value - first.BodyFat.Value), 1) : null;

            double? muscleChange = records.Count > 1 && last.SkeletalMuscle.HasValue && first.SkeletalMuscle.HasValue
                ? Math.Round(Convert.ToDouble(last.SkeletalMuscle.Value - first.SkeletalMuscle.Value), 1) : null;

            double? waistChange = records.Count > 1 && last.WaistCircumference.HasValue && first.WaistCircumference.HasValue
                ? Math.Round(Convert.ToDouble(last.WaistCircumference.Value - first.WaistCircumference.Value), 1) : null;

            string genderText = member?.Gender switch { 1 => "男", 2 => "女", _ => "未設定" };

            return new MemberHistoryDto
            {
                MemberId             = memberId,
                MemberName           = member?.User?.UserName ?? "未知",
                Gender               = genderText,
                Height               = member?.Height,
                Target               = member?.Target,
                ActivityLevel        = member?.ActivityLevel,
                Records              = records.OrderByDescending(b => b.CreateAt).Select(b => new BodyRecordDto
                {
                    Id                 = b.Id,
                    MemberId           = b.MemberId,
                    MemberName         = member?.User?.UserName ?? "未知",
                    MemberTarget       = member?.Target,
                    Weight             = b.Weight,
                    BodyFat            = b.BodyFat,
                    SkeletalMuscle     = b.SkeletalMuscle,
                    WaistCircumference = b.WaistCircumference,
                    CreateAt           = b.CreateAt,
                    Note               = b.Note,
                    ImageUrl           = b.ImageUrl
                }).ToList(),
                LatestWeight         = Math.Round(last.Weight, 1),
                LatestBodyFat        = last.BodyFat.HasValue
                    ? Math.Round(Convert.ToDouble(last.BodyFat.Value), 1) : null,
                LatestSkeletalMuscle = last.SkeletalMuscle.HasValue
                    ? Math.Round(Convert.ToDouble(last.SkeletalMuscle.Value), 1) : null,
                LatestWaist          = last.WaistCircumference.HasValue
                    ? Math.Round(Convert.ToDouble(last.WaistCircumference.Value), 1) : null,
                WeightChange         = weightChange,
                BodyFatChange        = bodyFatChange,
                SkeletalMuscleChange = muscleChange,
                WaistChange          = waistChange,
                Dates           = records.Select(b => b.CreateAt.ToString("MM/dd")).ToList(),
                Weights         = records.Select(b => b.Weight).ToList(),
                BodyFats        = records.Select(b => b.BodyFat.HasValue
                                    ? (double?)Convert.ToDouble(b.BodyFat.Value) : null).ToList(),
                SkeletalMuscles = records.Select(b => b.SkeletalMuscle.HasValue
                                    ? (double?)Convert.ToDouble(b.SkeletalMuscle.Value) : null).ToList(),
                Waists          = records.Select(b => b.WaistCircumference.HasValue
                                    ? (double?)Convert.ToDouble(b.WaistCircumference.Value) : null).ToList()
            };
        }
    }
}
