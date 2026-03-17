USE [MyFitnessCoachDb]
GO

DECLARE @i INT = 1;
DECLARE @ProductOrderId INT;
DECLARE @ProductId INT;
DECLARE @UnitPrice DECIMAL(18, 0);
DECLARE @Qty INT;
DECLARE @SubTotal DECIMAL(18, 0);
DECLARE @ProductName NVARCHAR(50);
DECLARE @ImageURL NVARCHAR(300);

-- 獲取現有訂單 ID 範圍
DECLARE @MinOrderId INT, @MaxOrderId INT;
SELECT @MinOrderId = MIN(Id), @MaxOrderId = MAX(Id) FROM [dbo].[ProductOrders];

WHILE @i <= 100
BEGIN
    -- 1. 隨機選一個現有訂單
    SET @ProductOrderId = FLOOR(RAND() * (@MaxOrderId - @MinOrderId + 1)) + @MinOrderId;
    
    -- 2. 隨機選一個現有商品 (1-10) 並讀取快照資訊
    SET @ProductId = FLOOR(RAND() * 10) + 1;
    
    SELECT @ProductName = [Name], 
           @UnitPrice = [UnitPrice], 
           @ImageURL = [ImageUrl] 
    FROM [dbo].[Products] 
    WHERE [Id] = @ProductId;

    -- 3. 隨機數量與金額計算
    SET @Qty = FLOOR(RAND() * 3) + 1; -- 1-3 份
    SET @SubTotal = @UnitPrice * @Qty;

    INSERT INTO [dbo].[ProductOrderDetails] ([ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo])
    VALUES (@ProductOrderId, @ProductId, @UnitPrice, @Qty, @SubTotal, @SubTotal, @ProductName, @ImageURL, NULL);

    SET @i = @i + 1;
END

PRINT 'Successfully generated 100 records for ProductOrderDetails.';
GO
