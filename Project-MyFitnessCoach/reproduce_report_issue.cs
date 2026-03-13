
using Project_MyFitnessCoach.Models.EfModels;
using Project_MyFitnessCoach.Models.Enums;
using Project_MyFitnessCoach.Services;
using Project_MyFitnessCoach.Repositories;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;

public class ReproduceReportIssue
{
    public static async Task Run(IServiceProvider serviceProvider)
    {
        var db = serviceProvider.GetRequiredService<MyFitnessCoachDbContext>();
        var service = serviceProvider.GetRequiredService<ReviewService>();

        // 1. Create a review if not exists
        var review = await db.Reviews.FirstOrDefaultAsync();
        if (review == null)
        {
            Console.WriteLine("No review found to test.");
            return;
        }

        int reviewId = review.Id;
        int instructorUserId = 1; // Assume an instructor user id

        // 2. Report the review for the first time
        Console.WriteLine($"Reporting review {reviewId} for the first time with reason: 'First Reason'");
        await service.ReportReviewAsync(reviewId, instructorUserId, "First Reason");

        // 3. Report the review for the second time
        Console.WriteLine($"Reporting review {reviewId} for the second time with reason: 'Second Reason'");
        await service.ReportReviewAsync(reviewId, instructorUserId, "Second Reason");

        // 4. Check what AdminIndex shows
        var adminReviews = await service.GetAdminReviewsAsync();
        var testedReview = adminReviews.FirstOrDefault(r => r.Id == reviewId);

        if (testedReview != null)
        {
            Console.WriteLine($"Admin reports reason: '{testedReview.ReportMessage}'");
            if (testedReview.ReportMessage == "First Reason")
            {
                Console.WriteLine("ISSUE REPRODUCED: The reason was NOT overwritten by the second report.");
            }
            else if (testedReview.ReportMessage == "Second Reason")
            {
                Console.WriteLine("The reason was overwritten (or the latest was picked).");
            }
        }
        else
        {
            Console.WriteLine("Review not found in admin list.");
        }
    }
}
