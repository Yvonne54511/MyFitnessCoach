USE [MyFitnessCoachDb]
GO

SET IDENTITY_INSERT [dbo].[ProductOrders] ON 
GO

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

-- 預設一些姓名與地址範本用於隨機組合
DECLARE @FirstNames TABLE (Name NVARCHAR(10));
INSERT INTO @FirstNames VALUES (N'王'), (N'李'), (N'張'), (N'劉'), (N'陳'), (N'楊'), (N'黃'), (N'趙'), (N'吳'), (N'周');
DECLARE @LastNames TABLE (Name NVARCHAR(10));
INSERT INTO @LastNames VALUES (N'小明'), (N'大同'), (N'雅婷'), (N'志豪'), (N'淑芬'), (N'冠宇'), (N'美玲'), (N'建宏'), (N'怡君'), (N'俊賢');
DECLARE @Districts TABLE (Name NVARCHAR(20));
INSERT INTO @Districts VALUES (N'台北市信義區'), (N'台北市大安區'), (N'新北市板橋區'), (N'台中市西屯區'), (N'高雄市苓雅區'), (N'桃園市中壢區'), (N'台南市東區');

WHILE @i <= 100
BEGIN
    SET @MemberId = FLOOR(RAND() * 106) + 1; -- 隨機選擇 MemberId 1-106
    SET @CreateAt = DATEADD(DAY, -FLOOR(RAND() * 30), GETDATE()); -- 最近 30 天內的隨機日期
    SET @OriginalAmount = (FLOOR(RAND() * 20) + 5) * 100; -- 500 - 2500 之間的金額
    SET @DiscountAmount = @OriginalAmount - (FLOOR(RAND() * 3) * 50); -- 隨機折抵 0, 50, 100
    
    SELECT TOP 1 @Receiver = F.Name + L.Name FROM @FirstNames F, @LastNames L ORDER BY NEWID();
    SELECT TOP 1 @Address = Name + N'某某路' + CAST(FLOOR(RAND() * 200) + 1 AS NVARCHAR(10)) + N'號' FROM @Districts ORDER BY NEWID();
    
    SET @Mobile = '09' + CAST(FLOOR(RAND() * 90000000) + 10000000 AS VARCHAR(10));
    SET @Status = FLOOR(RAND() * 5) + 1; -- 狀態 1-5
    SET @TaxNumber = CASE WHEN RAND() > 0.8 THEN FLOOR(RAND() * 90000000) + 10000000 ELSE NULL END; -- 20% 機率有統編

    INSERT INTO [dbo].[ProductOrders] ([Id], [MemberId], [CreateAt], [OriginalAmount], [DiscountAmount], [Receiver], [Address], [Mobile], [TaxNumber], [Status], [Memo])
    VALUES (@i + 2, @MemberId, @CreateAt, @OriginalAmount, @DiscountAmount, @Receiver, @Address, @Mobile, @TaxNumber, @Status, NULL);

    SET @i = @i + 1;
END

SET IDENTITY_INSERT [dbo].[ProductOrders] OFF
GO
