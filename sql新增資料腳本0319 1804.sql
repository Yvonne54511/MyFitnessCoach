USE [MyFitnessCoachDb]
GO

PRINT '開始清理 Shifts 重複資料並修復 ReserveOrders 對應...'

-- 1. 暫時停用外鍵約束，避免在更新或刪除過程中觸發 FK 錯誤
ALTER TABLE [dbo].[ReserveOrders] NOCHECK CONSTRAINT [FK_ReserveOrders_Shifts];
ALTER TABLE [dbo].[Reviews] NOCHECK CONSTRAINT [FK_Reviews_ReserveOrders];
ALTER TABLE [dbo].[PointsRecordDetails] NOCHECK CONSTRAINT [FK_PointsRecordDetails_ReserveOrders];
GO

-- 2. 處理 Shifts 中的重複資料 (同一位教練、同一天、同一個時段)
PRINT '清理 Shifts 重複資料及其關聯...'

-- 找出重複的 Shifts (每個組合只保留 Id 最小的那筆，其餘收集到暫存表中準備刪除)
SELECT [Id] INTO #DuplicateShifts 
FROM (
    SELECT [Id], 
           ROW_NUMBER() OVER(PARTITION BY [InstructorId], [ScheduleDate], [TimeSlot] ORDER BY [Id] ASC) as RowNum
    FROM [dbo].[Shifts]
) t
WHERE t.RowNum > 1;

-- 2.1 刪除與「重複 Shifts」關聯的 Reviews (子表)
DELETE FROM [dbo].[Reviews]
WHERE [ReserveOrderId] IN (
    SELECT [Id] FROM [dbo].[ReserveOrders] WHERE [ShiftId] IN (SELECT [Id] FROM #DuplicateShifts)
);

-- 2.2 刪除與「重複 Shifts」關聯的 PointsRecordDetails (子表)
DELETE FROM [dbo].[PointsRecordDetails]
WHERE [ReserveOrderId] IN (
    SELECT [Id] FROM [dbo].[ReserveOrders] WHERE [ShiftId] IN (SELECT [Id] FROM #DuplicateShifts)
);

-- 2.3 刪除與「重複 Shifts」關聯的 ReserveOrders (父表/子表)
DELETE FROM [dbo].[ReserveOrders]
WHERE [ShiftId] IN (SELECT [Id] FROM #DuplicateShifts);

-- 2.4 刪除重複的 Shifts 本身
DELETE FROM [dbo].[Shifts]
WHERE [Id] IN (SELECT [Id] FROM #DuplicateShifts);

DROP TABLE #DuplicateShifts;
PRINT '重複資料及其關聯刪除完成！'
GO

-- 3. 利用 CTE 將清理後剩餘的 Shifts 與 ReserveOrders 依序配對
PRINT '開始重新配對 ShiftId...'
;WITH AvailableShifts AS (
    -- 取得清理後存在的排班，依照 Id 排序 (提供給訂單配對)
    SELECT 
        [Id] AS RealShiftId,
        ROW_NUMBER() OVER (ORDER BY [Id] ASC) AS RowNum
    FROM [dbo].[Shifts]
),
TargetOrders AS (
    -- 取得清理後剩餘的所有訂單，依照 Id 排序
    SELECT 
        [Id] AS OrderId,
        ROW_NUMBER() OVER (ORDER BY [Id] ASC) AS RowNum
    FROM [dbo].[ReserveOrders]
)
-- 執行更新：將 ReserveOrders 的 ShiftId 覆寫為 Shifts 表中真實存在的 Id
UPDATE ro
SET ro.ShiftId = s.RealShiftId
FROM [dbo].[ReserveOrders] ro
INNER JOIN TargetOrders o ON ro.Id = o.OrderId
INNER JOIN AvailableShifts s ON o.RowNum = s.RowNum;

PRINT 'ShiftId 動態對應更新完成！'
GO

-- 4. 確保 Shifts 表中的 IsBooked 狀態與訂單同步
PRINT '同步 Shifts 的 IsBooked 狀態...'
-- 先將所有排班的預約狀態歸零
UPDATE [dbo].[Shifts] SET IsBooked = 0;

-- 將有出現在 ReserveOrders 中的排班設為 1 (已預約)
UPDATE [dbo].[Shifts] 
SET IsBooked = 1 
WHERE [Id] IN (SELECT [ShiftId] FROM [dbo].[ReserveOrders]);
GO

-- 5. 修正未來時空的資料 (把 2026/03/19 之後卻已經完成或有評論的紀錄移到過去)
PRINT '修正未來時間的評論與訂單至 2026/03/19 之前...'

-- 5.1 將未來且有評論/已完成的排班日期，隨機往前移到 2025年底 ~ 2026/3/18 之間
UPDATE s
SET s.ScheduleDate = DATEADD(day, - (ABS(CHECKSUM(NEWID())) % 100 + 1), '2026-03-18')
FROM [dbo].[Shifts] s
INNER JOIN [dbo].[ReserveOrders] ro ON s.Id = ro.ShiftId
LEFT JOIN [dbo].[Reviews] r ON ro.Id = r.ReserveOrderId
WHERE (s.ScheduleDate >= '2026-03-19' OR r.CreatedAt >= '2026-03-19')
  AND (ro.Status = N'已完成' OR r.Id IS NOT NULL);

-- 5.2 根據修改後的排班日期，調整訂單建立時間 (排班日的 1~14 天前)
UPDATE ro
SET ro.CreateAt = DATEADD(day, - (ABS(CHECKSUM(NEWID())) % 14 + 1), s.ScheduleDate)
FROM [dbo].[ReserveOrders] ro
INNER JOIN [dbo].[Shifts] s ON ro.ShiftId = s.Id
WHERE ro.Status = N'已完成' OR EXISTS (SELECT 1 FROM [dbo].[Reviews] r WHERE r.ReserveOrderId = ro.Id);

-- 5.3 根據修改後的排班日期，調整評論建立時間 (排班日的 2~72 小時後)
UPDATE r
SET r.CreatedAt = DATEADD(hour, (ABS(CHECKSUM(NEWID())) % 72 + 2), CAST(s.ScheduleDate AS DATETIME2))
FROM [dbo].[Reviews] r
INNER JOIN [dbo].[ReserveOrders] ro ON r.ReserveOrderId = ro.Id
INNER JOIN [dbo].[Shifts] s ON ro.ShiftId = s.Id;
GO

-- 6. 隨機移除部分評論 (模擬部分會員不留評論的情境)
PRINT '隨機移除部分評論，但保留每位教練最少 15 則...'
;WITH RankedReviews AS (
    SELECT 
        [Id], 
        [InstructorId],
        -- 將每個教練的評論隨機排序並編號
        ROW_NUMBER() OVER(PARTITION BY [InstructorId] ORDER BY NEWID()) as RowNum
    FROM [dbo].[Reviews]
)
DELETE FROM [dbo].[Reviews]
WHERE [Id] IN (
    SELECT [Id] 
    FROM RankedReviews 
    WHERE RowNum > 15 -- 超過 15 則的部分
      AND (ABS(CHECKSUM(NEWID())) % 100) < 50 -- 50% 的機率被刪除
);
GO

-- 6.5 準備測試資料：為「胡青薇」新增未來 (3/19-3/31) 的「已預約」訂單 (不含評論)
PRINT '準備測試資料：新增胡青薇未來的已預約訂單...'
DECLARE @TestInstructorId INT;

-- 尋找胡青薇的 InstructorId
SELECT @TestInstructorId = i.Id 
FROM [dbo].[Instructors] i
JOIN [dbo].[Users] u ON i.UserId = u.Id
WHERE u.UserName = N'胡青薇';

IF @TestInstructorId IS NOT NULL
BEGIN
    DECLARE @NewShifts TABLE (NewShiftId INT);

    -- 插入 3 筆介於 3/19 - 3/31 的未來排班
    INSERT INTO [dbo].[Shifts] ([InstructorId], [ScheduleDate], [TimeSlot], [IsBooked])
    OUTPUT INSERTED.Id INTO @NewShifts
    VALUES 
    (@TestInstructorId, '2026-03-21', N'14-15 (午)', 1),
    (@TestInstructorId, '2026-03-25', N'18-19 (晚)', 1),
    (@TestInstructorId, '2026-03-29', N'09-10 (早)', 1);

    -- 取得隨機的一位 Member 做為預約人 (這裡抓第一筆確保一定有值)
    DECLARE @TestMemberId INT = (SELECT TOP 1 [Id] FROM [dbo].[Members]);

    -- 將剛插入的排班轉為預約訂單，並設定狀態為 '已預約'
    INSERT INTO [dbo].[ReserveOrders] ([MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum])
    SELECT 
        @TestMemberId, 
        NewShiftId, 
        '2026-03-15 10:00:00', -- 隨便壓個 3/19 之前的建立時間
        N'已預約', 
        N'信用卡', 
        N'預約狀態變更測試', 
        NULL, 
        1200, 
        N'專門提供給 Admin 測試狀態變更的訂單，無評論'
    FROM @NewShifts;
    
    PRINT '胡青薇的專屬測試資料新增完成！'
END
ELSE
BEGIN
    PRINT '找不到「胡青薇」的教練資料，略過測試資料新增。'
END
GO

-- 7. 重新啟用外鍵約束
PRINT '重新啟用外鍵約束...'
ALTER TABLE [dbo].[ReserveOrders] WITH CHECK CHECK CONSTRAINT [FK_ReserveOrders_Shifts];
ALTER TABLE [dbo].[Reviews] WITH CHECK CHECK CONSTRAINT [FK_Reviews_ReserveOrders];
ALTER TABLE [dbo].[PointsRecordDetails] WITH CHECK CHECK CONSTRAINT [FK_PointsRecordDetails_ReserveOrders];

PRINT '資料庫清理與時間軸修復完畢！'
GO