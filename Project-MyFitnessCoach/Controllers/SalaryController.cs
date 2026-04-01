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
                // 如果錢包不存在，可能需要初始化或顯示錯誤
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
            // 預設為上個月
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

                // Header
                worksheet.Cell(currentRow, 1).Value = "員工";
                worksheet.Cell(currentRow, 2).Value = "月份";
                worksheet.Cell(currentRow, 3).Value = "每一筆核薪金額";
                
                // Style header
                var headerRange = worksheet.Range(1, 1, 1, 3);
                headerRange.Style.Font.Bold = true;
                headerRange.Style.Fill.BackgroundColor = XLColor.LightGray;

                foreach (var detail in details)
                {
                    currentRow++;
                    worksheet.Cell(currentRow, 1).Value = detail.InstructorName;
                    worksheet.Cell(currentRow, 2).Value = detail.SalaryDate;
                    worksheet.Cell(currentRow, 3).Value = detail.TotalAmount;
                    worksheet.Cell(currentRow, 3).Style.NumberFormat.Format = "$#,##0";
                }

                // Total Row
                currentRow++;
                worksheet.Cell(currentRow, 2).Value = "總金額";
                worksheet.Cell(currentRow, 2).Style.Font.Bold = true;
                worksheet.Cell(currentRow, 3).FormulaA1 = $"=SUM(C2:C{currentRow - 1})";
                worksheet.Cell(currentRow, 3).Style.Font.Bold = true;
                worksheet.Cell(currentRow, 3).Style.NumberFormat.Format = "$#,##0";

                worksheet.Columns().AdjustToContents();

                using (var stream = new MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();

                    return File(
                        content,
                        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                        $"教練薪資錢包明細_{DateTime.Now:yyyyMMdd}.xlsx");
                }
            }
        }

		[HttpPost]
		[Function("view_Salary")] 
		public async Task<IActionResult> IssueMonthlySalary([FromBody] IssueSalaryRequest request)
		{
			try 
			{
				// 強制檢查：僅限每月 1 號
				if (DateTime.Now.Day != 1)
				{
					return Json(new { success = false, message = "目前非發薪日。薪資核發功能僅限於每月 1 號開放（結算前一月薪資）。" });
				}

				if (string.IsNullOrEmpty(request.ReceiverEmail) || request.Amount <= 0)
				{
					return Json(new { success = false, message = "未綁定 PayPal 帳號或核薪金額無效" });
				}

				// 1. 執行台幣轉美金匯率轉換
				// 獲取前一個月的細節以取得匯率
                var lastMonth = DateTime.Now.AddMonths(-1);
				var detail = await _salaryService.GetSalaryDetailAsync(request.InstructorId, lastMonth.Year, lastMonth.Month);
				double rate = detail?.TwdToUsdRate ?? 32.0;
				decimal amountUsd = (decimal)((double)request.Amount / rate);

				// 2. 呼叫 PayPal 服務執行轉帳 (發送美金金額)
				var (isPayPalSuccess, payPalError) = await _payPalService.CreatePayoutAsync(
					request.ReceiverEmail,
					amountUsd,
					request.Note ?? $"{lastMonth.Year}/{lastMonth.Month} 月度薪資結算"
				);

				if (isPayPalSuccess)
				{
					// 3. 轉帳成功！寫入教練錢包明細 (記錄原始台幣金額)
					var dbRecordSuccess = await _walletService.AddSalaryEntryAsync(
						request.InstructorId,
						request.Amount,
						request.Note ?? $"{lastMonth.Year}/{lastMonth.Month} 月度薪資結算"
					);

					if (dbRecordSuccess)
					{
						// 4. 非同步發送系統通知
						_ = Task.Run(async () =>
						{
							try
							{
								int userId = await _salaryService.GetUserIdByInstructorIdAsync(request.InstructorId);
								if (userId > 0)
								{
									await _notificationService.SendAsync(
										userId, 
										null, 
										NotifyType.Salary,
										$"{lastMonth.Year}/{lastMonth.Month} 薪資已核發！金額：NT$ {request.Amount:N0} (約 {amountUsd:F2} USD)，請至我的錢包查看。",
										"/Salary/MyWallet"
									);
								}
							}
							catch (Exception ex)
							{
								Console.WriteLine($"Background Notification Error: {ex.Message}");
							}
						});

						return Json(new { success = true, message = $"已成功透過 PayPal 匯款 {amountUsd:F2} USD (匯率: {rate}) 給教練，入帳通知處理中！" });
					}
					else
					{
						return Json(new { success = true, message = $"PayPal 匯款成功 ({amountUsd:F2} USD)，但系統更新教練 (ID: {request.InstructorId}) 的入帳紀錄失敗，請手動校核。" });
					}
				}
				else
				{
					return Json(new { success = false, message = $"PayPal 轉帳失敗：{payPalError}" });
				}
			}
			catch (Exception ex)
			{
				Console.WriteLine($"Critical Error in IssueMonthlySalary: {ex.Message}");
				Console.WriteLine(ex.StackTrace);
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
