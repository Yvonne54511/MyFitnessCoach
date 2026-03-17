-- =============================================
-- BodyRecords (身體量測記錄) 建表 + 測試資料
-- 依據 Members 資料延伸設計
-- =============================================

-- -----------------------------------------------
-- 建立資料表
-- -----------------------------------------------
IF OBJECT_ID('dbo.BodyRecords', 'U') IS NOT NULL
    DROP TABLE [dbo].[BodyRecords];
GO

CREATE TABLE [dbo].[BodyRecords] (
    [Id]                 INT              NOT NULL IDENTITY(1,1),
    [MemberId]           INT              NOT NULL,
    [Weight]             FLOAT            NOT NULL,
    [BodyFat]            DECIMAL(4, 1)    NULL,
    [SkeletalMuscle]     DECIMAL(4, 1)    NULL,
    [WaistCircumference] DECIMAL(5, 1)    NULL,
    [CreateAt]           DATETIME2(0)     NOT NULL  CONSTRAINT [DF_BodyRecords_CreateAt] DEFAULT (GETDATE()),
    [Note]               NVARCHAR(200)    NULL,
    [ImageUrl]           NVARCHAR(300)    NULL,
    CONSTRAINT [PK_BodyRecords] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_BodyRecords_Members] FOREIGN KEY ([MemberId]) REFERENCES [dbo].[Members] ([Id])
);
GO

-- -----------------------------------------------
-- 插入測試資料
-- 對應 Members 資料：
--   Id=1  Female 58kg/163cm 輕度活動 目標:維持體重
--   Id=2  Male   75kg/178cm 中度活動 目標:增肌
--   Id=3  Female 52kg/158cm 久坐     目標:減重
--   Id=4  Male   70kg/175cm 中度活動 目標:增肌
--   Id=5  Female 54kg/161cm 輕度活動 目標:維持體重
--   Id=7  Female 68kg/180cm 中度活動 目標:維持體重
--   Id=8  Male   62kg/169cm 中度活動 目標:維持體重
-- -----------------------------------------------
SET IDENTITY_INSERT [dbo].[BodyRecords] ON
GO

-- Member 1：Female, 58kg, 維持體重 (體重維持穩定，體脂緩降)
INSERT [dbo].[BodyRecords] ([Id],[MemberId],[Weight],[BodyFat],[SkeletalMuscle],[WaistCircumference],[CreateAt],[Note],[ImageUrl]) VALUES
 (1,  1, 58.0, 25.5, 24.8, 72.0, CAST(N'2025-10-05T09:00:00' AS DATETIME2), N'初次量測', NULL),
 (2,  1, 57.8, 25.2, 25.0, 71.5, CAST(N'2025-11-05T09:00:00' AS DATETIME2), N'體重略降，持續維持中', NULL),
 (3,  1, 58.1, 25.0, 25.2, 71.0, CAST(N'2025-12-05T09:00:00' AS DATETIME2), N'體重回穩，肌肉量微增', NULL);

-- Member 2：Male, 75kg, 增肌 (體重漸增，體脂下降，肌肉明顯增加)
INSERT [dbo].[BodyRecords] ([Id],[MemberId],[Weight],[BodyFat],[SkeletalMuscle],[WaistCircumference],[CreateAt],[Note],[ImageUrl]) VALUES
 (4,  2, 75.0, 18.5, 38.2, 82.0, CAST(N'2025-10-03T10:00:00' AS DATETIME2), N'訓練初期基準量測', NULL),
 (5,  2, 76.5, 17.8, 39.5, 81.5, CAST(N'2025-11-03T10:00:00' AS DATETIME2), N'增肌效果顯著，體脂續降', NULL),
 (6,  2, 77.8, 17.0, 41.0, 81.0, CAST(N'2025-12-03T10:00:00' AS DATETIME2), N'肌肉量達成階段目標', NULL);

-- Member 3：Female, 52kg, 減重 (體重持續下降，腰圍縮小)
INSERT [dbo].[BodyRecords] ([Id],[MemberId],[Weight],[BodyFat],[SkeletalMuscle],[WaistCircumference],[CreateAt],[Note],[ImageUrl]) VALUES
 (7,  3, 52.0, 28.0, 22.5, 70.0, CAST(N'2025-10-01T08:30:00' AS DATETIME2), N'減重計畫開始', NULL),
 (8,  3, 50.5, 27.2, 22.8, 68.5, CAST(N'2025-11-01T08:30:00' AS DATETIME2), N'體重下降1.5kg，狀況良好', NULL),
 (9,  3, 49.0, 26.5, 23.0, 67.0, CAST(N'2025-12-01T08:30:00' AS DATETIME2), N'腰圍明顯縮小，繼續加油', NULL);

-- Member 4：Male, 70kg, 增肌 (穩定增重，肌肉量上升)
INSERT [dbo].[BodyRecords] ([Id],[MemberId],[Weight],[BodyFat],[SkeletalMuscle],[WaistCircumference],[CreateAt],[Note],[ImageUrl]) VALUES
 (10, 4, 70.0, 20.0, 35.0, 80.0, CAST(N'2025-10-07T11:00:00' AS DATETIME2), N'增肌訓練基準點', NULL),
 (11, 4, 71.5, 19.2, 36.5, 79.5, CAST(N'2025-11-07T11:00:00' AS DATETIME2), N'肌肉量增加，體脂微降', NULL),
 (12, 4, 73.0, 18.5, 38.0, 79.0, CAST(N'2025-12-07T11:00:00' AS DATETIME2), N'訓練成效明顯，肌肉量持續增加', NULL);

-- Member 5：Female, 54kg, 維持體重 (體重穩定波動，體態維持)
INSERT [dbo].[BodyRecords] ([Id],[MemberId],[Weight],[BodyFat],[SkeletalMuscle],[WaistCircumference],[CreateAt],[Note],[ImageUrl]) VALUES
 (13, 5, 54.0, 24.0, 23.0, 68.0, CAST(N'2025-10-10T09:30:00' AS DATETIME2), N'體態維持中', NULL),
 (14, 5, 53.8, 23.8, 23.2, 67.5, CAST(N'2025-11-10T09:30:00' AS DATETIME2), N'略有進步', NULL),
 (15, 5, 54.2, 24.2, 23.0, 68.0, CAST(N'2025-12-10T09:30:00' AS DATETIME2), NULL, NULL);

-- Member 7：Female, 68kg, 維持體重
INSERT [dbo].[BodyRecords] ([Id],[MemberId],[Weight],[BodyFat],[SkeletalMuscle],[WaistCircumference],[CreateAt],[Note],[ImageUrl]) VALUES
 (16, 7, 68.0, 26.0, 28.5, 74.0, CAST(N'2025-11-15T10:00:00' AS DATETIME2), N'初次量測', NULL),
 (17, 7, 67.5, 25.5, 29.0, 73.5, CAST(N'2025-12-15T10:00:00' AS DATETIME2), N'體重略降，繼續維持', NULL);

-- Member 8：Male, 62kg, 維持體重
INSERT [dbo].[BodyRecords] ([Id],[MemberId],[Weight],[BodyFat],[SkeletalMuscle],[WaistCircumference],[CreateAt],[Note],[ImageUrl]) VALUES
 (18, 8, 62.0, 19.5, 30.2, 77.0, CAST(N'2025-11-20T14:00:00' AS DATETIME2), N'定期健康追蹤', NULL),
 (19, 8, 62.5, 19.0, 30.8, 76.5, CAST(N'2025-12-20T14:00:00' AS DATETIME2), N'肌肉量微增，體脂略降', NULL);

SET IDENTITY_INSERT [dbo].[BodyRecords] OFF
GO

-- -----------------------------------------------
-- 驗證查詢
-- -----------------------------------------------
SELECT
    br.Id,
    br.MemberId,
    m.Weight AS [Member初始體重],
    br.Weight AS [量測體重],
    br.BodyFat AS [體脂%],
    br.SkeletalMuscle AS [骨骼肌kg],
    br.WaistCircumference AS [腰圍cm],
    br.CreateAt AS [量測時間],
    br.Note
FROM [dbo].[BodyRecords] br
JOIN [dbo].[Members] m ON m.Id = br.MemberId
ORDER BY br.MemberId, br.CreateAt;
GO
