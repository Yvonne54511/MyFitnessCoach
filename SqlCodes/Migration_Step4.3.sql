-- ============================================================
-- 步驟 4.3 資料庫遷移腳本
-- 假別餘額重構 + 精確到小時的請假時間
-- 執行前請先備份資料庫！
-- ============================================================

USE MyFitnessCoachDb;
GO

-- ============================================================
-- 1. LeaveTypes 新增欄位：QuotaType、WarnThresholdDays
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LeaveTypes' AND COLUMN_NAME = 'QuotaType')
BEGIN
    ALTER TABLE LeaveTypes ADD QuotaType NVARCHAR(20) NOT NULL DEFAULT 'PreAllocated';
    PRINT '✔ LeaveTypes.QuotaType 已新增';
END
ELSE
    PRINT '⏭ LeaveTypes.QuotaType 已存在，跳過';
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LeaveTypes' AND COLUMN_NAME = 'WarnThresholdDays')
BEGIN
    ALTER TABLE LeaveTypes ADD WarnThresholdDays INT NULL;
    PRINT '✔ LeaveTypes.WarnThresholdDays 已新增';
END
ELSE
    PRINT '⏭ LeaveTypes.WarnThresholdDays 已存在，跳過';
GO

-- ============================================================
-- 2. 建立 Holidays 表（國定假日排除）
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Holidays')
BEGIN
    CREATE TABLE Holidays (
        Id          INT IDENTITY(1,1) PRIMARY KEY,
        HolidayDate DATE NOT NULL,
        Name        NVARCHAR(50) NOT NULL,
        Year        INT NOT NULL,
        IsActive    BIT NOT NULL DEFAULT 1
    );

    CREATE UNIQUE INDEX IX_Holidays_Date ON Holidays(HolidayDate);
    PRINT '✔ Holidays 表已建立';
END
ELSE
    PRINT '⏭ Holidays 表已存在，跳過';
GO

-- ============================================================
-- 3. 建立 LeaveBalanceHistories 表（餘額異動審計紀錄）
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'LeaveBalanceHistories')
BEGIN
    CREATE TABLE LeaveBalanceHistories (
        Id              INT IDENTITY(1,1) PRIMARY KEY,
        LeaveBalanceId  INT NOT NULL,
        ChangeType      NVARCHAR(20) NOT NULL,
        ChangeDays      DECIMAL(18,2) NOT NULL,
        OldTotalDays    DECIMAL(18,2) NOT NULL,
        NewTotalDays    DECIMAL(18,2) NOT NULL,
        OldUsedDays     DECIMAL(18,2) NOT NULL,
        NewUsedDays     DECIMAL(18,2) NOT NULL,
        Reason          NVARCHAR(300) NULL,
        OperatorId      INT NOT NULL,
        CreatedAt       DATETIME2 NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_LeaveBalanceHistories_LeaveBalance
            FOREIGN KEY (LeaveBalanceId) REFERENCES LeaveBalances(Id),
        CONSTRAINT FK_LeaveBalanceHistories_Operator
            FOREIGN KEY (OperatorId) REFERENCES Employees(Id)
    );
    PRINT '✔ LeaveBalanceHistories 表已建立';
END
ELSE
    PRINT '⏭ LeaveBalanceHistories 表已存在，跳過';
GO

-- ============================================================
-- 4. 修改精度：DaysUsed decimal(18,1) → decimal(18,2)
--    RemainingDays 是計算欄位 (TotalDays - UsedDays)，
--    必須先刪除才能 ALTER 其依賴的 TotalDays/UsedDays
-- ============================================================
ALTER TABLE LeaveRequests ALTER COLUMN DaysUsed DECIMAL(18,2);
PRINT '✔ LeaveRequests.DaysUsed 精度已改為 (18,2)';
GO

-- 4a. 先刪除計算欄位
IF EXISTS (SELECT 1 FROM sys.computed_columns WHERE object_id = OBJECT_ID('LeaveBalances') AND name = 'RemainingDays')
BEGIN
    ALTER TABLE LeaveBalances DROP COLUMN RemainingDays;
    PRINT '✔ LeaveBalances.RemainingDays 計算欄位已暫時刪除';
END
GO

-- 4b. 修改 TotalDays / UsedDays 精度
ALTER TABLE LeaveBalances ALTER COLUMN TotalDays DECIMAL(18,2);
ALTER TABLE LeaveBalances ALTER COLUMN UsedDays  DECIMAL(18,2);
PRINT '✔ LeaveBalances.TotalDays/UsedDays 精度已改為 (18,2)';
GO

-- 4c. 重建計算欄位（精度自動跟隨新的 decimal(18,2)）
--     PERSISTED 計算欄位需要 QUOTED_IDENTIFIER ON
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS (SELECT 1 FROM sys.computed_columns WHERE object_id = OBJECT_ID('LeaveBalances') AND name = 'RemainingDays')
BEGIN
    ALTER TABLE LeaveBalances ADD RemainingDays AS (TotalDays - UsedDays) PERSISTED;
    PRINT '✔ LeaveBalances.RemainingDays 計算欄位已重建';
END
GO

-- ============================================================
-- 5. 更新假別 QuotaType 與 WarnThresholdDays
-- ============================================================
UPDATE LeaveTypes SET QuotaType = 'PreAllocated'     WHERE Name = N'特休';
UPDATE LeaveTypes SET QuotaType = 'Unlimited'        WHERE Name IN (N'病假', N'事假', N'公假');
UPDATE LeaveTypes SET QuotaType = 'ApprovalRequired' WHERE Name IN (N'婚假', N'喪假');

-- 法定天數警示門檻
UPDATE LeaveTypes SET WarnThresholdDays = 30  WHERE Name = N'病假';
UPDATE LeaveTypes SET WarnThresholdDays = 14  WHERE Name = N'事假';

-- 非特休假別 DaysPerYear 改為 0（不再用於自動建立額度）
UPDATE LeaveTypes SET DaysPerYear = 0 WHERE Name IN (N'病假', N'事假', N'婚假', N'喪假', N'公假');
PRINT '✔ LeaveTypes QuotaType/WarnThresholdDays 已更新';
GO

-- ============================================================
-- 6. 清理現有 LeaveBalances：非特休的 TotalDays 設為 0
-- ============================================================
UPDATE lb SET lb.TotalDays = 0
FROM LeaveBalances lb
INNER JOIN LeaveTypes lt ON lb.LeaveTypeId = lt.Id
WHERE lt.Name != N'特休';
-- RemainingDays 是計算欄位 (TotalDays - UsedDays)，會自動更新
PRINT '✔ 非特休 LeaveBalances 已清零';
GO

-- ============================================================
-- 7. 現有 LeaveRequests 補上時間（00:00 → 09:00/18:00）
-- ============================================================
UPDATE LeaveRequests
SET StartDate = CAST(CAST(StartDate AS DATE) AS DATETIME) + CAST('09:00:00' AS DATETIME),
    EndDate   = CAST(CAST(EndDate AS DATE) AS DATETIME) + CAST('18:00:00' AS DATETIME)
WHERE CAST(StartDate AS TIME) = '00:00:00';
PRINT '✔ 現有 LeaveRequests StartDate/EndDate 已補上工作時間';
GO

-- ============================================================
-- 8. 插入 2026 年國定假日
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM Holidays WHERE Year = 2026)
BEGIN
    INSERT INTO Holidays (HolidayDate, Name, Year) VALUES
    ('2026-01-01', N'元旦', 2026),
    ('2026-01-26', N'除夕', 2026),
    ('2026-01-27', N'春節', 2026),
    ('2026-01-28', N'春節', 2026),
    ('2026-01-29', N'春節', 2026),
    ('2026-02-28', N'和平紀念日', 2026),
    ('2026-04-05', N'清明節', 2026),
    ('2026-05-31', N'端午節', 2026),
    ('2026-10-04', N'中秋節', 2026),
    ('2026-10-10', N'國慶日', 2026);
    PRINT '✔ 2026 年國定假日已插入';
END
ELSE
    PRINT '⏭ 2026 年國定假日已存在，跳過';
GO

PRINT '';
PRINT '========================================';
PRINT '步驟 4.3 資料庫遷移完成！';
PRINT '========================================';
GO
