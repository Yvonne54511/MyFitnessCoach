USE [MyFitnessCoachDb]
GO

-- 1. 建立優惠券定義表 (Coupons)
CREATE TABLE [dbo].[Coupons] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [CouponCode] NVARCHAR(50) NOT NULL, -- 優惠代碼 (例如: SAVE100)
    [CouponName] NVARCHAR(100) NOT NULL, -- 優惠券名稱
    [Description] NVARCHAR(500) NULL, -- 描述/使用規則
    [Type] INT NOT NULL, -- 折扣類型: 1=固定金額, 2=百分比折扣
    [DiscountValue] DECIMAL(18, 2) NOT NULL, -- 折扣數值 (例如: 100 或 0.9)
    [MinimumSpend] DECIMAL(18, 2) DEFAULT 0 NOT NULL, -- 最低消費門檻
    [MaxDiscountAmount] DECIMAL(18, 2) NULL, -- 最高折扣上限 (百分比折扣用)
    [TotalQuantity] INT DEFAULT 0 NOT NULL, -- 總發放數量 (0表示不限)
    [IssuedQuantity] INT DEFAULT 0 NOT NULL, -- 已領取數量
    [StartDate] DATETIME2(7) NOT NULL, -- 開始日期
    [EndDate] DATETIME2(7) NOT NULL, -- 結束日期
    [IsActive] BIT DEFAULT 1 NOT NULL, -- 是否啟用
    [CreatedAt] DATETIME2(7) DEFAULT GETDATE() NOT NULL,
    CONSTRAINT [PK_Coupons] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UK_Coupons_Code] UNIQUE ([CouponCode])
);
GO

-- 2. 建立會員領取紀錄表 (MemberCoupons)
CREATE TABLE [dbo].[MemberCoupons] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [MemberId] INT NOT NULL, -- 會員ID
    [CouponId] INT NOT NULL, -- 優惠券ID
    [IsUsed] BIT DEFAULT 0 NOT NULL, -- 是否已使用
    [UsedDate] DATETIME2(7) NULL, -- 使用日期
    [ProductOrderId] INT NULL, -- 關聯的訂單ID
    [ReceivedAt] DATETIME2(7) DEFAULT GETDATE() NOT NULL, -- 領取日期
    CONSTRAINT [PK_MemberCoupons] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_MemberCoupons_Members] FOREIGN KEY ([MemberId]) REFERENCES [dbo].[Members] ([Id]),
    CONSTRAINT [FK_MemberCoupons_Coupons] FOREIGN KEY ([CouponId]) REFERENCES [dbo].[Coupons] ([Id])
);
GO

-- 3. 為 ProductOrders 增加 CouponId 欄位 (紀錄這筆訂單用了哪張券)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ProductOrders]') AND name = N'CouponId')
BEGIN
    ALTER TABLE [dbo].[ProductOrders] ADD [CouponId] INT NULL;
    
    -- 建立外鍵關聯
    ALTER TABLE [dbo].[ProductOrders] WITH CHECK ADD CONSTRAINT [FK_ProductOrders_Coupons] FOREIGN KEY ([CouponId])
    REFERENCES [dbo].[Coupons] ([Id]);
END
GO

-- 4. 插入一些測試資料
-- 滿 1000 折 100 固定金額券
INSERT INTO [dbo].[Coupons] ([CouponCode], [CouponName], [Type], [DiscountValue], [MinimumSpend], [TotalQuantity], [StartDate], [EndDate])
VALUES (N'WELCOME100', N'新會員歡迎禮', 1, 100, 1000, 1000, '2024-01-01', '2026-12-31');

-- 全館 9 折券
INSERT INTO [dbo].[Coupons] ([CouponCode], [CouponName], [Type], [DiscountValue], [MinimumSpend], [TotalQuantity], [StartDate], [EndDate])
VALUES (N'HAPPY90', N'週年慶 9 折券', 2, 0.9, 0, 0, '2024-01-01', '2026-12-31');
GO
