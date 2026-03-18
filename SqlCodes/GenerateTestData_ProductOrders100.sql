USE [MyFitnessCoachDb]
GO

-- 關閉 IDENTITY_INSERT 以便手動指定 ID (若有需要) 或直接讓資料庫遞增
-- 這裡我們直接 INSERT，讓資料庫自動生成 ID

DECLARE @i INT = 1;
DECLARE @MemberId INT;
DECLARE @CreateAt DATETIME2(7);
DECLARE @OriginalAmount DECIMAL(18, 0);
DECLARE @DiscountAmount DECIMAL(18, 0);
DECLARE @Receiver NVARCHAR(30);
DECLARE @Address NVARCHAR(500);
DECLARE @Mobile VARCHAR(20);
DECLARE @Status INT;
DECLARE @TaxNumber INT;

-- 預設一些範本資料用於隨機組合
DECLARE @FirstNames TABLE (Name NVARCHAR(10));
INSERT INTO @FirstNames VALUES (N'王'), (N'李'), (N'張'), (N'劉'), (N'陳'), (N'楊'), (N'黃'), (N'趙'), (N'吳'), (N'周');
DECLARE @LastNames TABLE (Name NVARCHAR(10));
INSERT INTO @LastNames VALUES (N'大明'), (N'小芬'), (N'志豪'), (N'美玲'), (N'冠宇'), (N'雅婷'), (N'家豪'), (N'淑惠'), (N'俊宏'), (N'怡君');
DECLARE @Districts TABLE (Name NVARCHAR(50));
INSERT INTO @Districts VALUES (N'台北市信義區'), (N'新北市板橋區'), (N'台中市西屯區'), (N'高雄市苓雅區'), (N'桃園市中壢區'), (N'台南市東區'), (N'新竹市東區');

WHILE @i <= 100
BEGIN
    SET @MemberId = FLOOR(RAND() * 100) + 1; -- 隨機會員 1-100
    SET @CreateAt = DATEADD(SECOND, -FLOOR(RAND() * 31536000), GETDATE()); -- 最近一年內
    SET @OriginalAmount = FLOOR(RAND() * 4901) + 100; -- 100 - 5000
    SET @DiscountAmount = FLOOR(RAND() * (@OriginalAmount * 0.2)); -- 最高 20% 折扣
    
    SELECT TOP 1 @Receiver = (SELECT TOP 1 Name FROM @FirstNames ORDER BY NEWID()) + (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
    SELECT TOP 1 @Address = (SELECT TOP 1 Name FROM @Districts ORDER BY NEWID()) + N'某某路' + CAST(FLOOR(RAND() * 900) + 1 AS NVARCHAR(10)) + N'號';
    
    SET @Mobile = '09' + CAST(FLOOR(RAND() * 90000000) + 10000000 AS VARCHAR(10));
    SET @Status = FLOOR(RAND() * 6); -- 0-5
    SET @TaxNumber = CASE WHEN RAND() > 0.8 THEN FLOOR(RAND() * 90000000) + 10000000 ELSE NULL END; -- 20% 機率有統編

    INSERT INTO [dbo].[ProductOrders] ([MemberId], [CreateAt], [OriginalAmount], [DiscountAmount], [Receiver], [Address], [Mobile], [TaxNumber], [Status], [Memo])
    VALUES (@MemberId, @CreateAt, @OriginalAmount, @DiscountAmount, @Receiver, @Address, @Mobile, @TaxNumber, @Status, NULL);

    SET @i = @i + 1;
END

PRINT 'Successfully generated 100 records for ProductOrders.';
GO
