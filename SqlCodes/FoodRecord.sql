-- ============================================================
--  食物模組 新增資料表 + Views
--  請在執行完 create_tables_v2.sql 之後再執行此檔
-- ============================================================

USE MyFitnessCoachDb;  -- ← 請改成你的資料庫名稱
GO

-- ============================================================
-- 清除（若重建）
-- ============================================================
IF OBJECT_ID('FoodRecords',    'U') IS NOT NULL DROP TABLE FoodRecords;
IF OBJECT_ID('Nutrients',      'U') IS NOT NULL DROP TABLE Nutrients;
IF OBJECT_ID('Foods',          'U') IS NOT NULL DROP TABLE Foods;
IF OBJECT_ID('FoodCategories', 'U') IS NOT NULL DROP TABLE FoodCategories;

IF OBJECT_ID('vw_UserRoleFunction',    'V') IS NOT NULL DROP VIEW vw_UserRoleFunction;
IF OBJECT_ID('vw_UserMemberFoodRecord','V') IS NOT NULL DROP VIEW vw_UserMemberFoodRecord;
GO

-- ============================================================
-- 17. FoodCategories
-- ============================================================
CREATE TABLE FoodCategories (
    Id           INT          PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(50) NOT NULL,
    IsActive     BIT          NOT NULL DEFAULT 1
);
GO

-- ============================================================
-- 18. Foods
-- ============================================================
CREATE TABLE Foods (
    Id         INT          PRIMARY KEY IDENTITY(1,1),
    CategoryId INT          NOT NULL,
    FoodName   NVARCHAR(50) NOT NULL,
    IsDeleted  BIT          NOT NULL DEFAULT 0,
    CONSTRAINT FK_Foods_FoodCategories FOREIGN KEY (CategoryId) REFERENCES FoodCategories(Id)
);
GO

-- ============================================================
-- 19. Nutrients
-- ============================================================
CREATE TABLE Nutrients (
    Id          INT          PRIMARY KEY IDENTITY(1,1),
    FoodId      INT          NOT NULL,
    BaseAmount  INT          NOT NULL,      -- 基準份量數值
    Measure     NVARCHAR(20) NOT NULL,      -- 單位，如 g / ml / 份
    Kcal        FLOAT        NULL,
    ProteinGram FLOAT        NULL,
    CarbGram    FLOAT        NULL,
    FatGram     FLOAT        NULL,
    CONSTRAINT FK_Nutrients_Foods FOREIGN KEY (FoodId) REFERENCES Foods(Id)
);
GO

-- ============================================================
-- 20. FoodRecords（飲食日誌明細）
-- ============================================================
CREATE TABLE FoodRecords (
    Id       INT          PRIMARY KEY IDENTITY(1,1),
    MemberId INT          NOT NULL,
    EatDT    DATETIME2(0) NOT NULL DEFAULT GETDATE(),
    MealType NVARCHAR(20) NOT NULL,   -- 早餐/午餐/晚餐/點心
    FoodId   INT          NOT NULL,
    Amount   FLOAT        NOT NULL,
    Measure  NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_FoodRecords_Members FOREIGN KEY (MemberId) REFERENCES Members(Id),
    CONSTRAINT FK_FoodRecords_Foods FOREIGN KEY (FoodId) REFERENCES Foods(Id)
);
GO


-- ============================================================
-- ██ INSERT 範例資料
-- ============================================================

-- FoodCategories（10 筆）
INSERT INTO FoodCategories (CategoryName, IsActive) VALUES
(N'全穀雜糧類', 1),   -- 1
(N'豆魚蛋肉類', 1),   -- 2
(N'乳品類',     1),   -- 3
(N'蔬菜類',     1),   -- 4
(N'水果類',     1),   -- 5
(N'油脂與堅果', 1),   -- 6
(N'飲料類',     1),   -- 7
(N'零食點心',   1),   -- 8
(N'速食類',     0),   -- 9  (已下架)
(N'補充品',     1);   -- 10
GO

-- Foods（每類至少 1 筆，共 12 筆）
INSERT INTO Foods (CategoryId, FoodName, IsDeleted) VALUES
(1, N'白飯',         0),   -- 1
(1, N'燕麥片',       0),   -- 2
(2, N'雞胸肉',       0),   -- 3
(2, N'水煮蛋',       0),   -- 4
(2, N'鮭魚',         0),   -- 5
(3, N'低脂牛奶',     0),   -- 6
(3, N'希臘優格',     0),   -- 7
(4, N'花椰菜',       0),   -- 8
(5, N'香蕉',         0),   -- 9
(6, N'橄欖油',       0),   -- 10
(7, N'黑咖啡',       0),   -- 11
(8, N'黑巧克力 85%', 0);   -- 12
GO

-- Nutrients（每食物一筆基準，以 100g 或常見份量為基準）
INSERT INTO Nutrients (FoodId, BaseAmount, Measure, Kcal, ProteinGram, CarbGram, FatGram) VALUES
(1,  100, N'g',  130.0,  2.7,  28.2,  0.3),   -- 白飯
(2,  100, N'g',  389.0, 16.9,  66.3,  6.9),   -- 燕麥片
(3,  100, N'g',  165.0, 31.0,   0.0,  3.6),   -- 雞胸肉
(4,    1, N'顆',  78.0,  6.3,   0.6,  5.3),   -- 水煮蛋
(5,  100, N'g',  208.0, 20.0,   0.0, 13.0),   -- 鮭魚
(6,  240, N'ml', 102.0,  8.2,  12.2,  2.4),   -- 低脂牛奶
(7,  170, N'g',  100.0, 17.0,   6.0,  0.7),   -- 希臘優格
(8,  100, N'g',   34.0,  2.8,   6.6,  0.4),   -- 花椰菜
(9,    1, N'根',  89.0,  1.1,  23.0,  0.3),   -- 香蕉
(10,  15, N'ml', 120.0,  0.0,   0.0, 14.0),   -- 橄欖油
(11, 240, N'ml',   5.0,  0.3,   0.0,  0.1),   -- 黑咖啡
(12,  30, N'g',  170.0,  2.2,  13.0, 12.0);   -- 黑巧克力
GO


-- FoodRecords（12 筆，使用已存在的 MemberId 1, 2, 3）
INSERT INTO FoodRecords (MemberId, EatDT, MealType, FoodId, Amount, Measure) VALUES
-- Alice (MemberId=1) 今天
(1, '2026-03-04 07:30:00', N'早餐', 2,  80.0, N'g'),    -- 燕麥片
(1, '2026-03-04 07:30:00', N'早餐', 6, 240.0, N'ml'),   -- 低脂牛奶
(1, '2026-03-04 12:00:00', N'午餐', 1, 150.0, N'g'),    -- 白飯
(1, '2026-03-04 12:00:00', N'午餐', 3, 120.0, N'g'),    -- 雞胸肉
(1, '2026-03-04 18:30:00', N'晚餐', 8, 200.0, N'g'),    -- 花椰菜
-- Bob (MemberId=2)
(2, '2026-03-04 08:00:00', N'早餐', 4,   2.0, N'顆'),   -- 水煮蛋
(2, '2026-03-04 08:00:00', N'早餐', 11,  1.0, N'杯'),   -- 黑咖啡
(2, '2026-03-04 12:30:00', N'午餐', 5,  150.0, N'g'),   -- 鮭魚
(2, '2026-03-04 12:30:00', N'午餐', 1,  200.0, N'g'),   -- 白飯
(2, '2026-03-04 21:00:00', N'點心', 12,  30.0, N'g'),   -- 黑巧克力
-- Carol (MemberId=3)
(3, '2026-03-04 09:00:00', N'早餐', 7,  170.0, N'g'),   -- 希臘優格
(3, '2026-03-04 09:00:00', N'早餐', 9,    1.0, N'根');  -- 香蕉
GO


-- ============================================================
-- ██ VIEWS
-- ============================================================

-- ------------------------------------------------------------
-- View 1：vw_UserRoleFunction
-- 合併顯示：使用者 → 角色 → 功能權限
-- ------------------------------------------------------------
GO
CREATE VIEW vw_UserRoleFunction AS
SELECT
    u.Id           AS UserId,
    u.UserName,
    u.Email,
    r.Id           AS RoleId,
    r.RoleName,
    f.Id           AS FunctionId,
    f.FunctionName
FROM Users u
JOIN UserRoles     ur ON ur.UserId     = u.Id
JOIN Roles         r  ON r.Id          = ur.RoleId
JOIN RoleFunctions rf ON rf.RoleId     = r.Id
JOIN [Functions]   f  ON f.Id          = rf.FunctionId;
GO

-- ------------------------------------------------------------
-- View 2：vw_UserMemberFoodRecord
-- 合併顯示：使用者 → 會員資料 → 飲食日誌 → 食物名稱 → 營養成分
-- ------------------------------------------------------------
CREATE VIEW vw_UserMemberFoodRecord AS
SELECT
    u.Id               AS UserId,
    u.UserName,
    u.Email,
    -- 會員資料
    m.Id               AS MemberId,
    m.Gender,
    m.Weight,
    m.Height,
    m.BMR,
    m.TDEE,
    -- 飲食日誌
    fr.Id              AS FoodRecordId,
    fr.EatDT,
    fr.MealType,
    fr.Amount,
    fr.Measure         AS RecordMeasure,
    -- 食物
    fo.Id              AS FoodId,
    fo.FoodName,
    fc.CategoryName,
    -- 營養素（以記錄份量換算）
    n.BaseAmount,
    n.Measure          AS NutrientMeasure,
    ROUND(n.Kcal        * fr.Amount / n.BaseAmount, 2) AS TotalKcal,
    ROUND(n.ProteinGram * fr.Amount / n.BaseAmount, 2) AS TotalProtein,
    ROUND(n.CarbGram    * fr.Amount / n.BaseAmount, 2) AS TotalCarb,
    ROUND(n.FatGram     * fr.Amount / n.BaseAmount, 2) AS TotalFat
FROM Users u
JOIN Members       m  ON m.UserId     = u.Id
JOIN FoodRecords   fr ON fr.MemberId  = m.Id
JOIN Foods         fo ON fo.Id        = fr.FoodId
JOIN FoodCategories fc ON fc.Id       = fo.CategoryId
LEFT JOIN Nutrients n  ON n.FoodId    = fo.Id;
GO

-- ============================================================
PRINT '食物模組資料表與 Views 建立完畢。';
GO

-- ============================================================
-- 快速查詢範例
-- ============================================================

-- 查所有使用者的角色與功能
-- SELECT * FROM vw_UserRoleFunction ORDER BY UserId, RoleName;

-- 查 Alice 今天攝取的熱量總計
-- SELECT MealType, FoodName, Amount, RecordMeasure, TotalKcal, TotalProtein, TotalCarb, TotalFat
-- FROM vw_UserMemberFoodRecord
-- WHERE UserName = N'Alice Wang'
--   AND CAST(EatDT AS DATE) = '2026-03-04'
-- ORDER BY EatDT;