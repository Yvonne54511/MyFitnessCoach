using ClosedXML.Excel;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Project_MyFitnessCoach.Models;
using Project_MyFitnessCoach.Models.DTOs;
using Project_MyFitnessCoach.Models.Infra;
using Project_MyFitnessCoach.Models.ViewModels;
using Project_MyFitnessCoach.Services;
using Project_MyFitnessCoach.Repositories;
using Project_MyFitnessCoach.Models.Enums;
using System;
using System.IO;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Controllers
{
    [Authorize]
    public class SalaryController : Controller
    {
        private readonly ISalaryService _salaryService;
        private readonly IInstructorWalletService _walletService;
		private readonly IPayPalService _payPalService;
		private readonly NotificationService _notificationService;

		public SalaryController(
			ISalaryService salaryService, 
			IInstructorWalletService walletService, 
			IPayPalService payPalService, 
			NotificationService notificationService)
        {
            _salaryService = salaryService;
            _walletService = walletService;
			_payPalService = payPalService;
			_notificationService = notificationService;
		}

        [Function("view_Salary")]
        public async Task<IActionResult> Index()
        {
            var instructors = await _salaryService.GetInstructorsAsync();
            var rankings = await _salaryService.GetRankingsAsync();

            var viewModel = new SalaryIndexViewModel
            {
                Instructors = instructors,
                Rankings = rankings
            };

            return View(viewModel);
        }

        [Function("view_MyWallet")]
        public async Task<IActionResult> MyWallet()
        {
            var instructorIdClaim = User.FindFirst("InstructorId");
            if (instructorIdClaim == null || !int.TryParse(instructorIdClaim.Value, out int instructorId))
            {
                return RedirectToAction("Error", "Home", new { id = 403 });
            }

            var wallet = await _walletService.GetWalletByInstructorIdAsync(instructorId);
            if (wallet == null)
            {
                return View("Error", new ErrorViewModel { RequestId = "Wallet not found" });
            }

            return View(wallet);
        }

        [Function("view_Salary")]
        public async Task<IActionResult> AllWallets()
        {
            var instructors = await _salaryService.GetInstructorsAsync();
            return View(instructors);
        }

        public async Task<IActionResult> GetWalletDetail(int instructorId)
        {
            var wallet = await _walletService.GetWalletByInstructorIdAsync(instructorId);
            if (wallet == null) return NotFound();

            return PartialView("_WalletDetailPartial", wallet);
        }

        public async Task<IActionResult> GetSalaryDetail(int instructorId, int? year, int? month, double? monthlyBonusPool, double? annualBonusPool)
        {
            var lastMonth = DateTime.Now.AddMonths(-1);
            int queryYear = year ?? lastMonth.Year;
            int queryMonth = month ?? lastMonth.Month;
            double mPool = monthlyBonusPool ?? 0;
            double aPool = annualBonusPool ?? 0;

            var detail = await _salaryService.GetSalaryDetailAsync(instructorId, queryYear, queryMonth, mPool, aPool);
            if (detail == null) return NotFound();

            return PartialView("_SalaryDetailPartial", detail);
        }

        [Function("view_Salary")]
        public async Task<IActionResult> ExportToExcel()
        {
            var details = await _walletService.GetAllWalletDetailsForExportAsync();

            using (var workbook = new XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("教練薪資明細");
                var currentRow = 1;
                worksheet.Cell(currentRow, 1).Value = "員工";
                worksheet.Cell(currentRow, 2).Value = "月份";
                worksheet.Cell(currentRow, 3).Value = "交易類別";
                worksheet.Cell(currentRow, 4).Value = "金額";
                
                var headerRange = worksheet.Range(1, 1, 1, 4);
                headerRange.Style.Font.Bold = true;
                headerRange.Style.Fill.BackgroundColor = XLColor.LightGray;

                foreach (var detail in details)
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).Value = detail.InstructorName;
                    worksheet.Cell(currentRow, 2).Value = detail.SalaryDate;
                    worksheet.Cell(currentRow, 3).Value = detail.Category; // 直接顯示資料庫存的字串
                    worksheet.Cell(currentRow, 4).Value = detail.TotalAmount;
                    worksheet.Cell(currentRow, 4).Style.NumberFormat.Format = "$#,##0";
                }

                currentRow++;
                worksheet.Cell(currentRow, 3).Value = "總金額";
                worksheet.Cell(currentRow, 3).Style.Font.Bold = true;
                worksheet.Cell(currentRow, 4).FormulaA1 = $"=SUM(D2:D{currentRow - 1})";
                worksheet.Cell(currentRow, 4).Style.Font.Bold = true;
                worksheet.Cell(currentRow, 4).Style.NumberFormat.Format = "$#,##0";

                worksheet.Columns().AdjustToContents();

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();
                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", $"教練薪資錢包明細_{DateTime.Now:yyyyMMdd}.xlsx");
                }
            }
        }

		[HttpPost]
		[Function("view_Salary")] 
		public async Task<IActionResult> IssueMonthlySalary([FromBody] IssueSalaryRequest request)
		{
            var lastMonth = DateTime.Now.AddMonths(-1);
            string description = $"{lastMonth.Year}/{lastMonth.Month} 月度薪資結算";
            string notifyTitle = $"{lastMonth.Year}/{lastMonth.Month} 薪資已核發！";
            
            return await ProcessPayoutAsync(request, description, notifyTitle, isAnnual: false);
		}

		[HttpPost]
		[Function("view_Salary")] 
		public async Task<IActionResult> IssueAnnualBonus([FromBody] IssueSalaryRequest request)
		{
            var lastYear = DateTime.Now.Year - 1;
            string description = $"{lastYear} 年度績效獎金核發";
            string notifyTitle = $"{lastYear} 年度獎金已核發！";
            
            return await ProcessPayoutAsync(request, description, notifyTitle, isAnnual: true);
		}

        /// <summary>
        /// 核心撥款處理邏輯 (優雅整合)
        /// </summary>
        private async Task<IActionResult> ProcessPayoutAsync(IssueSalaryRequest request, string description, string notifyTitle, bool isAnnual)
        {
			try 
			{
				// 強制檢查：
                // 1. 月度薪資：每月 1 號
                // 2. 年度獎金：每年 1 月 1 號
				if (isAnnual)
                {
                    if (DateTime.Now.Month != 1 || DateTime.Now.Day != 1)
                    {
                        return Json(new { success = false, message = "目前非年度獎金核發日。年度獎金僅限於每年 1 月 1 號開放核發。" });
                    }
                }
                else
                {
                    if (DateTime.Now.Day != 1)
                    {
                        return Json(new { success = false, message = "目前非發薪日。月度薪資核發功能僅限於每月 1 號開放。" });
                    }
                }

				if (string.IsNullOrEmpty(request.ReceiverEmail) || request.Amount <= 0)
				{
					return Json(new { success = false, message = "未綁定 PayPal 帳號或金額無效" });
				}

				// 1. 匯率轉換
                var lastMonth = DateTime.Now.AddMonths(-1);
				var detail = await _salaryService.GetSalaryDetailAsync(request.InstructorId, lastMonth.Year, lastMonth.Month);
				double rate = detail?.TwdToUsdRate ?? 32.0;
				decimal amountUsd = (decimal)((double)request.Amount / rate);

				// 2. PayPal 轉帳
				var (isPayPalSuccess, payPalError) = await _payPalService.CreatePayoutAsync(
					request.ReceiverEmail,
					amountUsd,
					request.Note ?? description
				);

				if (isPayPalSuccess)
				{
					// 3. 寫入錢包
                    var category = isAnnual ? "年終獎金" : "月薪與加給";
					var dbRecordSuccess = await _walletService.AddSalaryEntryAsync(
						request.InstructorId,
						request.Amount,
						description,
                        category
					);

					if (dbRecordSuccess)
					{
						// 4. 發送通知 (直接 await 確保通知一定能發出)
						try
						{
							int userId = await _salaryService.GetUserIdByInstructorIdAsync(request.InstructorId);
							if (userId > 0)
							{
								await _notificationService.SendAsync(
									userId, 
									null, 
									NotifyType.Salary,
									$"{notifyTitle} 金額：NT$ {request.Amount:N0} (約 {amountUsd:F2} USD)，請至我的錢包查看。",
									"/Salary/MyWallet"
								);
							}
						}
						catch (Exception ex) { Console.WriteLine($"Notification Error: {ex.Message}"); }

						return Json(new { success = true, message = $"已成功透過 PayPal 匯款 {amountUsd:F2} USD (匯率: {rate})，並已記錄至教練錢包。" });
					}
					return Json(new { success = true, message = $"PayPal 匯款成功 ({amountUsd:F2} USD)，但系統紀錄更新失敗，請手動校核。" });
				}
				return Json(new { success = false, message = $"PayPal 轉帳失敗：{payPalError}" });
			}
			catch (Exception ex)
			{
				return Json(new { success = false, message = "伺服器內部錯誤：" + ex.Message });
			}
        }

		public class IssueSalaryRequest
		{
			public int InstructorId { get; set; }
			public string ReceiverEmail { get; set; } = "";
			public decimal Amount { get; set; }
			public string? Note { get; set; }
		}
	}
}
