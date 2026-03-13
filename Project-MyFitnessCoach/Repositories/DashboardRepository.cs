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
        IEnumerable<InstructorRatingDto> GetInstructorRatings();
        GlobalRatingDto GetGlobalRating();
        IEnumerable<KeyWordFrequencyDto> GetKeyWordFrequencies();
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

        public IEnumerable<KeyWordFrequencyDto> GetKeyWordFrequencies()
        {
            var rawReviews = _db.Reviews.Where(r => !r.IsBanned && !string.IsNullOrEmpty(r.Comment)).Select(r => r.Comment).ToList();
            var dbKeyWords = _db.KeyWords.ToList();
            var dbWordSet = new HashSet<string>(dbKeyWords.Select(k => k.Word));

            // 1. 統計資料庫已有關鍵字的次數
            var results = dbKeyWords.Select(kw => new KeyWordFrequencyDto
            {
                Word = kw.Word,
                Category = kw.Category,
                Count = rawReviews.Sum(r => (r.Length - r.Replace(kw.Word, "").Length) / kw.Word.Length)
            }).Where(k => k.Count > 0).ToList();

            // 2. 挖掘新的高頻詞彙 (重複出現 > 5次，長度 2~4)
            var nGramCounts = new Dictionary<string, int>();
            char[] separators = new[] { ' ', ',', '.', '!', '?', '(', ')', '[', ']', '，', '。', '！', '？', '\r', '\n', '\t', '、', '：', '；' };

            foreach (var review in rawReviews)
            {
                // 先根據標點符號切段，避免跨標點匹配
                var segments = review.Split(separators, StringSplitOptions.RemoveEmptyEntries);
                foreach (var segment in segments)
                {
                    if (segment.Length < 2) continue;

                    for (int len = 2; len <= 4; len++)
                    {
                        for (int i = 0; i <= segment.Length - len; i++)
                        {
                            string gram = segment.Substring(i, len);
                            // 排除純數字或空格
                            if (string.IsNullOrWhiteSpace(gram) || gram.All(char.IsDigit)) continue;
                            
                            if (nGramCounts.ContainsKey(gram)) nGramCounts[gram]++;
                            else nGramCounts[gram] = 1;
                        }
                    }
                }
            }

            // 3. 過濾出重複 > 5次 且 不在資料庫裡的字詞
            var discoveredGrams = nGramCounts
                .Where(kvp => kvp.Value >= 5 && !dbWordSet.Contains(kvp.Key))
                .Select(kvp => new KeyWordFrequencyDto
                {
                    Word = kvp.Key,
                    Category = null, // 未分類
                    Count = kvp.Value
                });

            // 4. 合併結果並排序
            return results.Concat(discoveredGrams).OrderByDescending(k => k.Count).ToList();
        }

        public IEnumerable<InstructorRatingDto> GetInstructorRatings()
        {
            var instructors = _db.Instructors
                .Include(i => i.User)
                .Include(i => i.Reviews.Where(r => !r.IsBanned))
                    .ThenInclude(r => r.Member)
                        .ThenInclude(m => m.User)
                .ToList();

            var keyWords = _db.KeyWords.ToList();
            // 防呆：依字數從長到短排序，優先匹配長字詞
            var sortedPositiveWords = keyWords.Where(k => k.Category == 1).OrderByDescending(k => k.Word.Length).ToList();
            var sortedNegativeWords = keyWords.Where(k => k.Category == -1).OrderByDescending(k => k.Word.Length).ToList();

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

                    // Step 2: 關鍵字加權 (具備防呆去重邏輯)
                    if (!string.IsNullOrEmpty(review.Comment))
                    {
                        string tempComment = review.Comment;

                        // 處理正向詞
                        foreach (var pw in sortedPositiveWords)
                        {
                            if (tempComment.Contains(pw.Word))
                            {
                                // 算出該字詞出現次數並加分
                                int count = (tempComment.Length - tempComment.Replace(pw.Word, "").Length) / pw.Word.Length;
                                score += count * pw.Weight;

                                // 防呆：將已匹配的字詞從暫存內容中移除（用空格取代），避免被後續較短的關鍵字重複匹配
                                tempComment = tempComment.Replace(pw.Word, new string(' ', pw.Word.Length));
                            }
                        }

                        // 處理負向詞 (使用剩下的字串繼續匹配)
                        foreach (var nw in sortedNegativeWords)
                        {
                            if (tempComment.Contains(nw.Word))
                            {
                                int count = (tempComment.Length - tempComment.Replace(nw.Word, "").Length) / nw.Word.Length;
                                score -= count * nw.Weight;
                                
                                tempComment = tempComment.Replace(nw.Word, new string(' ', nw.Word.Length));
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

        public GlobalRatingDto GetGlobalRating()
        {
            var reviews = _db.Reviews.Where(r => !r.IsBanned).ToList();
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
