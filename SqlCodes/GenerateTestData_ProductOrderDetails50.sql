USE [MyFitnessCoachDb]
GO

-- 1. 優先補齊沒有明細的訂單
DECLARE @MissingOrder TABLE (Id INT);
INSERT INTO @MissingOrder SELECT Id FROM ProductOrders WHERE Id NOT IN (SELECT DISTINCT ProductOrderId FROM ProductOrderDetails);

DECLARE @MissingId INT;
DECLARE cur CURSOR FOR SELECT Id FROM @MissingOrder;
OPEN cur;
FETCH NEXT FROM cur INTO @MissingId;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @ProductId INT = FLOOR(RAND() * 10) + 1;
    DECLARE @ProductName NVARCHAR(100), @UnitPrice DECIMAL(18, 0), @ImageURL NVARCHAR(300);
    SELECT @ProductName = [Name], @UnitPrice = [UnitPrice], @ImageURL = [ImageUrl] FROM [dbo].[Products] WHERE [Id] = @ProductId;
    
    INSERT INTO [dbo].[ProductOrderDetails] ([ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo])
    VALUES (@MissingId, @ProductId, @UnitPrice, 1, @UnitPrice, @UnitPrice, @ProductName, @ImageURL, N'系統自動補齊');
    
    FETCH NEXT FROM cur INTO @MissingId;
END
CLOSE cur;
DEALLOCATE cur;

-- 2. 補充至總共 50 筆資料 (隨機分佈)
DECLARE @i INT = 1;
DECLARE @TotalToGen INT = 50 - (SELECT COUNT(*) FROM @MissingOrder);
DECLARE @MinOrderId INT, @MaxOrderId INT;
SELECT @MinOrderId = MIN(Id), @MaxOrderId = MAX(Id) FROM [dbo].[ProductOrders];

WHILE @i <= @TotalToGen
BEGIN
    DECLARE @ProductOrderId INT = FLOOR(RAND() * (@MaxOrderId - @MinOrderId + 1)) + @MinOrderId;
    SET @ProductId = FLOOR(RAND() * 10) + 1;
    SELECT @ProductName = [Name], @UnitPrice = [UnitPrice], @ImageURL = [ImageUrl] FROM [dbo].[Products] WHERE [Id] = @ProductId;

    INSERT INTO [dbo].[ProductOrderDetails] ([ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo])
    VALUES (@ProductOrderId, @ProductId, @UnitPrice, FLOOR(RAND() * 2) + 1, @UnitPrice, @UnitPrice, @ProductName, @ImageURL, NULL);

    SET @i = @i + 1;
END

PRINT 'Successfully ensured all orders have details and added total 50 records.';
GO
