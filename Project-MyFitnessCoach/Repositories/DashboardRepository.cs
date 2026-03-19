using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.EfModels;
using System.Collections.Generic;
using System.Linq;

namespace Project_MyFitnessCoach.Repositories
{
    public interface IDashboardRepository
    {
        int GetTotalUsers();
        int GetActiveUsers();
        int GetPendingUsers();
        int GetActiveRoles();
        int GetActiveFunctions();
        int GetActiveInstructors();
        
        // Monthly stats
        int GetMonthlyOrdersCount(int year, int month);
        decimal GetMonthlyRevenue(int year, int month);
        int GetMonthlyReviewsCount(int year, int month);
        int GetMonthlyActiveMembers(int year, int month);

        // Yearly stats
        decimal[] GetMonthlyRevenueTrendData(int year);

        IEnumerable<InstructorRatingDto> GetInstructorRatings(int year, int month);
        GlobalRatingDto GetGlobalRating(int year, int month);
        IEnumerable<KeyWordFrequencyDto> GetKeyWordFrequencies(int year, int month);
    }

    public class DashboardRepository : IDashboardRepository
    {
        private readonly MyFitnessCoachDbContext _db;

        public DashboardRepository(MyFitnessCoachDbContext db)
        {
            _db = db;
        }

        public int GetTotalUsers() => _db.Users.Count();
        public int GetActiveUsers() => _db.Users.Count(x => x.IsActive);
        public int GetPendingUsers() => _db.Users.Count(x => !x.IsConfirmed);
        public int GetActiveRoles() => _db.Roles.Count(x => x.IsActive);
        public int GetActiveFunctions() => _db.Functions.Count(x => x.IsActive);
        public int GetActiveInstructors() => _db.Instructors.Count(x => x.IsActive);

        public int GetMonthlyOrdersCount(int year, int month)
        {
            int pOrders = _db.ProductOrders.Count(x => x.CreateAt.Year == year && (month == 0 || x.CreateAt.Month == month));
            int rOrders = _db.ReserveOrders.Count(x => x.CreateAt.Year == year && (month == 0 || x.CreateAt.Month == month));
            return pOrders + rOrders;
        }

        public decimal GetMonthlyRevenue(int year, int month)
        {
            decimal pRev = _db.ProductOrders
                .Where(x => x.CreateAt.Year == year && (month == 0 || x.CreateAt.Month == month))
                .Sum(x => (decimal?)(x.OriginalAmount - x.DiscountAmount)) ?? 0;
            
            decimal rRev = _db.ReserveOrders
                .Where(x => x.CreateAt.Year == year && (month == 0 || x.CreateAt.Month == month))
                .Sum(x => (decimal?)x.Price) ?? 0;

            decimal ptRev = _db.PointOrders
                .Where(x => x.CreateAt.Year == year && (month == 0 || x.CreateAt.Month == month))
                .Sum(x => (decimal?)x.DiscountedPrice) ?? 0;

            return pRev + rRev + ptRev;
        }

        public int GetMonthlyReviewsCount(int year, int month)
        {
            return _db.Reviews.Count(x => x.CreatedAt.Year == year && (month == 0 || x.CreatedAt.Month == month));
        }

        public int GetMonthlyActiveMembers(int year, int month)
        {
            var pMembers = _db.ProductOrders.Where(x => x.CreateAt.Year == year && (month == 0 || x.CreateAt.Month == month)).Select(x => x.MemberId);
            var rMembers = _db.ReserveOrders.Where(x => x.CreateAt.Year == year && (month == 0 || x.CreateAt.Month == month)).Select(x => x.MemberId);
            var rvMembers = _db.Reviews.Where(x => x.CreatedAt.Year == year && (month == 0 || x.CreatedAt.Month == month)).Select(x => x.MemberId);
            var ptMembers = _db.PointOrders.Where(x => x.CreateAt.Year == year && (month == 0 || x.CreateAt.Month == month)).Select(x => x.MemberId);

            return pMembers.Union(rMembers).Union(rvMembers).Union(ptMembers).Distinct().Count();
        }

        public decimal[] GetMonthlyRevenueTrendData(int year)
        {
            var pOrders = _db.ProductOrders.Where(x => x.CreateAt.Year == year).Select(x => new { x.CreateAt.Month, Revenue = x.OriginalAmount - x.DiscountAmount }).ToList();
            var rOrders = _db.ReserveOrders.Where(x => x.CreateAt.Year == year).Select(x => new { x.CreateAt.Month, Revenue = x.Price }).ToList();
            var ptOrders = _db.PointOrders.Where(x => x.CreateAt.Year == year).Select(x => new { x.CreateAt.Month, Revenue = x.DiscountedPrice }).ToList();

            decimal[] trend = new decimal[12];
            for (int i = 1; i <= 12; i++)
            {
                decimal pRev = pOrders.Where(x => x.Month == i).Sum(x => (decimal?)x.Revenue) ?? 0;
                decimal rRev = rOrders.Where(x => x.Month == i).Sum(x => (decimal?)x.Revenue) ?? 0;
                decimal ptRev = ptOrders.Where(x => x.Month == i).Sum(x => (decimal?)x.Revenue) ?? 0;
                trend[i - 1] = pRev + rRev + ptRev;
            }
            return trend;
        }

        public IEnumerable<KeyWordFrequencyDto> GetKeyWordFrequencies(int year, int month)
        {
            var rawReviews = _db.Reviews
                .Where(r => !r.IsBanned && !string.IsNullOrEmpty(r.Comment) && r.CreatedAt.Year == year && (month == 0 || r.CreatedAt.Month == month))
                .Select(r => r.Comment)
                .ToList();
            var dbKeyWords = _db.KeyWords.ToList();
            var dbWordSet = new HashSet<string>(dbKeyWords.Select(k => k.Word));

            // 內建常用廢詞庫 (停用詞)
            var stopWords = new HashSet<string> { 
                "的", "了", "在", "是", "我", "你", "他", "她", "它", "們", 
                "這", "那", "有", "也", "就", "不", "都", "而", "及", "與", 
                "著", "或", "之", "還", "又", "可以", "覺得", "非常", "真的", 
                "一個", "這裡", "在那", "因為", "所以", "但是", "如果"
            };

            // 讀取本地手動忽略清單 (不進資料庫的詞)
            string ignoredPath = System.IO.Path.Combine(System.IO.Directory.GetCurrentDirectory(), "ignored_words.txt");
            if (System.IO.File.Exists(ignoredPath))
            {
                var manualIgnored = System.IO.File.ReadAllLines(ignoredPath);
                foreach (var w in manualIgnored) stopWords.Add(w);
            }

            // 1. 統計資料庫已有關鍵字的次數
            var results = dbKeyWords
                .Where(kw => kw.Category != 0)
                .Select(kw => new KeyWordFrequencyDto
            {
                Word = kw.Word,
                Category = kw.Category,
                Count = rawReviews.Sum(r => (r.Length - r.Replace(kw.Word, "").Length) / kw.Word.Length)
            }).Where(k => k.Count > 0).ToList();

            // 2. 挖掘新的高頻詞彙 (重複出現 > 5次，長度 2~5)
            var nGramCounts = new Dictionary<string, int>();
            char[] separators = new[] { ' ', ',', '.', '!', '?', '(', ')', '[', ']', '，', '。', '！', '？', '\r', '\n', '\t', '、', '：', '；' };

            foreach (var review in rawReviews)
            {
                var segments = review.Split(separators, StringSplitOptions.RemoveEmptyEntries);
                foreach (var segment in segments)
                {
                    if (segment.Length < 2) continue;

                    for (int len = 2; len <= 5; len++)
                    {
                        for (int i = 0; i <= segment.Length - len; i++)
                        {
                            string gram = segment.Substring(i, len);
                            // 排除純數字、空格、或包含在停用詞中的詞
                            if (string.IsNullOrWhiteSpace(gram) || gram.All(char.IsDigit) || stopWords.Contains(gram)) continue;
                            
                            if (nGramCounts.ContainsKey(gram)) nGramCounts[gram]++;
                            else nGramCounts[gram] = 1;
                        }
                    }
                }
            }

            // 3. 過濾出重複 > 5次 且 不在資料庫裡的字詞 (也排除停用詞)
            var rawDiscovered = nGramCounts
                .Where(kvp => kvp.Value >= 5 && !dbWordSet.Contains(kvp.Key) && !stopWords.Contains(kvp.Key))
                .Select(kvp => new KeyWordFrequencyDto
                {
                    Word = kvp.Key,
                    Category = null, // 未分類
                    Count = kvp.Value
                })
                .OrderByDescending(k => k.Word.Length)
                .ToList();

            // 4. 過濾冗餘子字串 (考慮新詞與資料庫既有詞)
            var discoveredGrams = new List<KeyWordFrequencyDto>();
            // 建立一個包含「既有詞」與「新詞」的參考清單，用來做比較
            var allReferenceWords = results.Concat(rawDiscovered).ToList();

            foreach (var current in rawDiscovered)
            {
                // 檢查是否已被包含在一個更長且次數接近的字詞中 (既有詞或新詞皆列入考慮)
                bool isRedundant = allReferenceWords.Any(longer => 
                    longer.Word.Length > current.Word.Length && 
                    longer.Word.Contains(current.Word) && 
                    longer.Count >= current.Count * 0.9);

                if (!isRedundant)
                {
                    discoveredGrams.Add(current);
                }
            }

            // 5. 合併結果並排序
            return results.Concat(discoveredGrams).OrderByDescending(k => k.Count).ToList();
        }

        public IEnumerable<InstructorRatingDto> GetInstructorRatings(int year, int month)
        {
            var instructors = _db.Instructors
                .Include(i => i.User)
                .Include(i => i.Reviews.Where(r => !r.IsBanned && r.CreatedAt.Year == year && (month == 0 || r.CreatedAt.Month == month)))
                    .ThenInclude(r => r.Member)
                        .ThenInclude(m => m.User)
                .ToList();

            var keyWords = _db.KeyWords.ToList();
            // 合併所有關鍵字，並從長到短排序，確保長字詞（如「不專業」）優先於短字詞（如「專業」）被匹配
            var sortedAllKeywords = keyWords.OrderByDescending(k => k.Word.Length).ToList();

            return instructors.Select(i => {
                var posReviews = new List<ReviewSentimentDto>();
                var neuReviews = new List<ReviewSentimentDto>();
                var negReviews = new List<ReviewSentimentDto>();

                foreach (var review in i.Reviews)
                {
                    // Step 1: 基礎分
                    int score = 0;
                    if (review.Rating >= 4) score = 2;
                    else if (review.Rating <= 2) score = -2;
                    else score = 0;

                    // Step 2: 關鍵字加權 (一次掃描所有關鍵字)
                    if (!string.IsNullOrEmpty(review.Comment))
                    {
                        string tempComment = review.Comment;

                        foreach (var kw in sortedAllKeywords)
                        {
                            if (tempComment.Contains(kw.Word))
                            {
                                // 算出該字詞出現次數
                                int count = (tempComment.Length - tempComment.Replace(kw.Word, "").Length) / kw.Word.Length;
                                
                                // 根據分類加分或減分
                                if (kw.Category == 1) score += count * kw.Weight;
                                else if (kw.Category == -1) score -= count * kw.Weight;

                                // 將已匹配的字詞移除，避免短字詞重複匹配
                                tempComment = tempComment.Replace(kw.Word, new string(' ', kw.Word.Length));
                            }
                        }
                    }

                    var reviewDto = new ReviewSentimentDto
                    {
                        Comment = review.Comment,
                        Rating = review.Rating,
                        CalculatedScore = score,
                        MemberName = review.Member?.User?.UserName ?? "匿名會員",
                        CreatedAt = review.CreatedAt
                    };

                    // Step 3: 最終判定
                    if (score > 0) posReviews.Add(reviewDto);
                    else if (score < 0) negReviews.Add(reviewDto);
                    else neuReviews.Add(reviewDto);
                }

                return new InstructorRatingDto
                {
                    InstructorId = i.Id,
                    InstructorName = i.User.UserName,
                    ImageUrl = i.ImageUrl,
                    TotalReviews = i.Reviews.Count(),
                    AverageRating = i.Reviews.Any() ? i.Reviews.Average(r => r.Rating) : 0,
                    TotalScore = posReviews.Sum(r => r.CalculatedScore) + neuReviews.Sum(r => r.CalculatedScore) + negReviews.Sum(r => r.CalculatedScore),
                    Star5Count = i.Reviews.Count(r => r.Rating == 5),
                    Star4Count = i.Reviews.Count(r => r.Rating == 4),
                    Star3Count = i.Reviews.Count(r => r.Rating == 3),
                    Star2Count = i.Reviews.Count(r => r.Rating == 2),
                    Star1Count = i.Reviews.Count(r => r.Rating == 1),
                    PositiveCount = posReviews.Count,
                    NeutralCount = neuReviews.Count,
                    NegativeCount = negReviews.Count,
                    PositiveReviews = posReviews.OrderByDescending(r => r.CreatedAt).ToList(),
                    NeutralReviews = neuReviews.OrderByDescending(r => r.CreatedAt).ToList(),
                    NegativeReviews = negReviews.OrderByDescending(r => r.CreatedAt).ToList()
                };
            }).ToList();
        }

        public GlobalRatingDto GetGlobalRating(int year, int month)
        {
            var reviews = _db.Reviews.Where(r => !r.IsBanned && r.CreatedAt.Year == year && (month == 0 || r.CreatedAt.Month == month)).ToList();
            if (!reviews.Any()) return new GlobalRatingDto();

            return new GlobalRatingDto
            {
                TotalReviews = reviews.Count,
                AverageRating = reviews.Average(r => r.Rating),
                Star5Count = reviews.Count(r => r.Rating == 5),
                Star4Count = reviews.Count(r => r.Rating == 4),
                Star3Count = reviews.Count(r => r.Rating == 3),
                Star2Count = reviews.Count(r => r.Rating == 2),
                Star1Count = reviews.Count(r => r.Rating == 1)
            };
        }
    }
}
