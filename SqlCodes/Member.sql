-- ============================================================
--  完整建表 + 範例資料 T-SQL 腳本 v2
-- ============================================================

USE MyFitnessCoachDb;  -- ← 請改成你的資料庫名稱
GO

-- ============================================================
-- 0. 清除舊表（依 FK 順序由子到父）
-- ============================================================
IF OBJECT_ID('RoleFunctions',       'U') IS NOT NULL DROP TABLE RoleFunctions;
IF OBJECT_ID('UserRoles',           'U') IS NOT NULL DROP TABLE UserRoles;
IF OBJECT_ID('UserExternalLogins',  'U') IS NOT NULL DROP TABLE UserExternalLogins;
IF OBJECT_ID('Instructors',         'U') IS NOT NULL DROP TABLE Instructors;
IF OBJECT_ID('UserWallets',         'U') IS NOT NULL DROP TABLE UserWallets;
IF OBJECT_ID('Members',             'U') IS NOT NULL DROP TABLE Members;
IF OBJECT_ID('Functions',           'U') IS NOT NULL DROP TABLE [Functions];
IF OBJECT_ID('Roles',               'U') IS NOT NULL DROP TABLE Roles;
IF OBJECT_ID('Users',               'U') IS NOT NULL DROP TABLE Users;
GO

-- ============================================================
-- 1. Users
-- ============================================================
CREATE TABLE Users (
    Id                             INT           PRIMARY KEY IDENTITY(1,1),
    Account                        NVARCHAR(50)  NULL,
    HashedPassword                 NVARCHAR(256) NULL,
    UserName                       NVARCHAR(30)  NOT NULL,
    Email                          NVARCHAR(200) NOT NULL,
    Mobile                         VARCHAR(10)   NULL,
    IsConfirmed                    BIT           NOT NULL DEFAULT 0,
    IsActive                       BIT           NOT NULL DEFAULT 0,
    NewMemberConfirmCode           VARCHAR(100)  NULL,
    NewMemberConfirmCodeExpiry     DATETIME2(0)  NULL,
    ResetPasswordConfirmCode       VARCHAR(100)  NULL,
    ResetPasswordConfirmCodeExpiry DATETIME2(0)  NULL,
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);
-- ? 過濾索引：只對非 NULL 的 Account 做唯一檢查，允許多個 NULL（Google 登入者）
CREATE UNIQUE INDEX UX_Users_Account ON Users(Account) WHERE Account IS NOT NULL;
GO

-- ============================================================
-- 1.5 UserExternalLogins
-- ============================================================
CREATE TABLE UserExternalLogins (
    Id                  INT           PRIMARY KEY IDENTITY(1,1),
    UserId              INT           NOT NULL,
    LoginProvider       NVARCHAR(50)  NOT NULL,
    ProviderKey         NVARCHAR(255) NOT NULL,
    ProviderDisplayName NVARCHAR(100) NULL,
    CONSTRAINT FK_ExternalLogins_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
);
GO

-- ============================================================
-- 2. Roles
-- ============================================================
CREATE TABLE Roles (
    Id       INT          PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(30) NOT NULL,
    IsActive BIT          NOT NULL DEFAULT 0
);
GO

-- ============================================================
-- 2.5 UserRoles
-- ============================================================
CREATE TABLE UserRoles (
    Id     INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    RoleId INT NOT NULL,
    CONSTRAINT UQ_UserRoles      UNIQUE (UserId, RoleId),
    CONSTRAINT FK_UserRoles_User FOREIGN KEY (UserId) REFERENCES Users(Id),
    CONSTRAINT FK_UserRoles_Role FOREIGN KEY (RoleId) REFERENCES Roles(Id)
);
GO

-- ============================================================
-- 3. Functions
-- ============================================================
CREATE TABLE [Functions] (
    Id           INT          PRIMARY KEY IDENTITY(1,1),
    FunctionName NVARCHAR(50) NOT NULL,
    IsActive     BIT          NOT NULL DEFAULT 0
);
GO

-- ============================================================
-- 4. RoleFunctions
-- ============================================================
CREATE TABLE RoleFunctions (
    Id         INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    RoleId     INT NOT NULL,
    FunctionId INT NOT NULL,
    CONSTRAINT UQ_RoleFunctions          UNIQUE (RoleId, FunctionId),
    CONSTRAINT FK_RoleFunctions_Role     FOREIGN KEY (RoleId)     REFERENCES Roles(Id),
    CONSTRAINT FK_RoleFunctions_Function FOREIGN KEY (FunctionId) REFERENCES [Functions](Id)
);
GO

-- ============================================================
-- 5. Members（移除 UserWalletId 及對應 FK）
-- ============================================================
CREATE TABLE Members (
    Id            INT           PRIMARY KEY IDENTITY(1,1),
    UserId        INT           NOT NULL,
    Gender        TINYINT       NULL,    -- 0=未填, 1=男, 2=女, 3=其他
    DateOfBirth   DATETIME2(0)  NULL,
    Weight        FLOAT         NULL,
    Height        FLOAT         NULL,
    ActivityLevel NVARCHAR(50)  NULL,
    Target        NVARCHAR(50)  NULL,
    BMR           FLOAT         NULL,
    TDEE          FLOAT         NULL,
    ImageUrl      NVARCHAR(300) NULL,
    CancelCount   INT           NOT NULL DEFAULT 0,
    CONSTRAINT FK_Members_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
);
GO

-- ============================================================
-- UserWallets（? 改為對應 MemberId）
-- ============================================================
CREATE TABLE UserWallets (
    Id             INT           NOT NULL PRIMARY KEY IDENTITY(1,1),
    MemberId       INT           NOT NULL,
    CurrentBalance DECIMAL(10,2) NOT NULL DEFAULT 0,
    LastUpdated    DATETIME2(0)  NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_UserWallets_Members FOREIGN KEY (MemberId) REFERENCES Members(Id),
    CONSTRAINT UQ_UserWallets_Member  UNIQUE (MemberId)   -- 一個 Member 只有一個錢包
);
GO

-- ============================================================
-- 6. Instructors
-- ============================================================
CREATE TABLE Instructors (
    Id          INT           PRIMARY KEY IDENTITY(1,1),
    UserId      INT           NOT NULL,
    ImageUrl    NVARCHAR(300) NOT NULL,
    Description NVARCHAR(500) NOT NULL,
    HourWage    INT           NOT NULL,
    CancelCount INT           NOT NULL DEFAULT 0,
    IsActive    BIT           NOT NULL DEFAULT 1,
    CONSTRAINT FK_Instructors_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
);
GO


-- ============================================================
-- ██ INSERT 範例資料
-- ============================================================

-- ============================================================
-- Users
-- ============================================================
INSERT INTO Users (Account, HashedPassword, UserName, Email, Mobile, IsConfirmed, IsActive)
VALUES
-- 一般會員 (已驗證)
(N'alice01',     '$2b$12$AAAbbbCCCdddEEEfffGGGhhhIIIjjjKKKlllMMMnnnOOO', N'Alice Wang',   'alice@example.com',   '0912345601', 1, 1),
(N'bob02',       '$2b$12$BBBcccDDDeeeFFFgggHHHiiiJJJkkkLLLmmmNNNooo111', N'Bob Chen',     'bob@example.com',     '0912345602', 1, 1),
(N'carol03',     '$2b$12$CCCdddEEEffFFFgggHHHiiiJJJkkkLLLmmmNNNooo222', N'Carol Lin',    'carol@example.com',   '0912345603', 1, 1),
-- 營養師
(N'inst_david',  '$2b$12$DDDeeeFFfgggHHHiiiJJJkkkLLLmmmNNNooo333444555', N'David Lee',    'david@example.com',   '0912345604', 1, 1),
(N'inst_emma',   '$2b$12$EEEffgggHHHiiiJJJkkkLLLmmmNNNooo444555666777', N'Emma Huang',   'emma@example.com',    '0912345605', 1, 1),
-- 採購人員
(N'pur_frank',   '$2b$12$FFFghhHHHiiiJJJkkkLLLmmmNNNooo555666777888999', N'Frank Wu',     'frank@example.com',   '0912345606', 1, 1),
(N'pur_grace',   '$2b$12$GGGhiiIIIjjjKKKlllMMMnnnOOOppp666777888999aaa', N'Grace Tsai',   'grace@example.com',   '0912345607', 1, 1),
-- 行銷人員
(N'mkt_henry',   '$2b$12$HHHijjJJJkkkLLLmmmNNNooo777888999aaabbbccc111', N'Henry Chang',  'henry@example.com',   '0912345608', 1, 1),
(N'mkt_iris',    '$2b$12$IIIjkkKKKlllMMMnnnOOOppp888999aaabbbccc222333', N'Iris Chou',    'iris@example.com',    '0912345609', 1, 1),
-- Admin
(N'admin_jack',  '$2b$12$JJJkllLLLmmmNNNoooOOO999aaabbbccc333444555666', N'Jack Admin',   'jack.admin@example.com','0912345610', 1, 1),
-- Google 登入會員
(NULL, NULL, N'Kevin Google',  'kevin.google@gmail.com',  '0912345611', 1, 1),
(NULL, NULL, N'Linda Google',  'linda.google@gmail.com',  '0912345612', 1, 1);
GO

-- ============================================================
-- UserExternalLogins
-- ============================================================
INSERT INTO UserExternalLogins (UserId, LoginProvider, ProviderKey, ProviderDisplayName)
VALUES
(11, N'Google', N'109876543210987654321', N'Kevin Google'),
(12, N'Google', N'208765432109876543210', N'Linda Google');
GO

-- ============================================================
-- Roles
-- Id: 1=member, 2=instructor, 3=purchasor, 4=marketor, 5=admin
-- ============================================================
INSERT INTO Roles (RoleName, IsActive) VALUES
(N'member', 1),      -- 1
(N'instructor', 1),  -- 2
(N'purchasor', 1),   -- 3
(N'marketor', 1),    -- 4
(N'admin', 1);       -- 5
GO

-- ============================================================
-- UserRoles
-- ============================================================
INSERT INTO UserRoles (UserId, RoleId) VALUES
(1,  1),   -- alice   → member
(2,  1),   -- bob     → member
(3,  1),   -- carol   → member
(4,  2),   -- david   → instructor
(5,  2),   -- emma    → instructor
(6,  3),   -- frank   → purchasor
(7,  3),   -- grace   → purchasor
(8,  4),   -- henry   → marketor
(9,  4),   -- iris    → marketor
(10, 5),   -- jack    → admin
(11, 1),   -- kevin   → member (Google)
(12, 1);   -- linda   → member (Google)
GO

-- ============================================================
-- Functions
-- ============================================================
INSERT INTO [Functions] (FunctionName, IsActive) VALUES
-- Instructor 功能
(N'ManageOwnProfile', 1),          -- 1  營養師資料維護
(N'ManageSchedule', 1),            -- 2  排班表管理
(N'ViewOwnAppointments', 1),       -- 3  查看自己被預約時段
(N'ReportComment', 1),             -- 4  檢舉評論區
-- Purchasor 功能
(N'ManageProducts', 1),            -- 5  商品上架
(N'ManageCategories', 1),          -- 6  類別管理
(N'ManageOrders', 1),              -- 7  訂單管理
-- Marketor 功能
(N'ManageTopUpPlans', 1),          -- 8  儲值方案管理
(N'ManageTopUpOrders', 1),         -- 9  儲值訂單管理
(N'QueryMemberBalance', 1),        -- 10 客戶點數查詢
-- Admin 專屬功能
(N'ToggleInstructorActive', 1),    -- 11 上下架營養師
(N'SuspendStaff', 1);              -- 12 對員工停權
GO

-- ============================================================
-- RoleFunctions
-- ============================================================
INSERT INTO RoleFunctions (RoleId, FunctionId) VALUES
-- instructor (RoleId=2)
(2, 1), (2, 2), (2, 3), (2, 4),
-- purchasor (RoleId=3)
(3, 5), (3, 6), (3, 7),
-- marketor (RoleId=4)
(4, 8), (4, 9), (4, 10),
-- admin (RoleId=5)：繼承所有 + 專屬功能
(5, 1), (5, 2),  (5, 3),  (5, 4),
(5, 5), (5, 6),  (5, 7),
(5, 8), (5, 9),  (5, 10),
(5, 11),(5, 12);
GO

-- ============================================================
-- Members
-- ============================================================
INSERT INTO Members (UserId, Gender, DateOfBirth, Weight, Height,
                     ActivityLevel, Target, BMR, TDEE, ImageUrl)
VALUES
(1,  2, '1995-03-15', 58.0, 163.0, N'輕度活動', N'維持體重', 1368.5, 1873.8, N'/images/members/alice.jpg'),
(2,  1, '1990-07-22', 75.0, 178.0, N'中度活動', N'增肌',      1806.0, 2797.8, N'/images/members/bob.jpg'),
(3,  2, '1998-11-05', 52.0, 158.0, N'久坐',     N'減重',      1271.2, 1525.4, N'/images/members/carol.jpg'),
(11, 1, '1993-04-10', 70.0, 175.0, N'中度活動', N'增肌',      1720.0, 2666.0, N'/images/members/kevin.jpg'),
(12, 2, '1997-09-25', 54.0, 161.0, N'輕度活動', N'維持體重',  1310.0, 1794.7, N'/images/members/linda.jpg');
GO
-- Members.Id: 1=alice, 2=bob, 3=carol, 4=kevin, 5=linda

-- ============================================================
-- UserWallets（對應 MemberId）
-- ============================================================
INSERT INTO UserWallets (MemberId, CurrentBalance, LastUpdated) VALUES
(1, 500.00,   GETDATE()),
(2, 1200.00,  GETDATE()),
(3, 300.00,   GETDATE()),
(4, 750.00,   GETDATE()),
(5, 0.00,     GETDATE());
GO

-- ============================================================
-- Instructors
-- ============================================================
INSERT INTO Instructors (UserId, ImageUrl, Description, HourWage, CancelCount, IsActive)
VALUES
(4, N'/images/instructors/david.jpg',
   N'專長：運動員飲食規劃、增肌減脂。擁有 10 年臨床營養師經驗，曾服務多支職業球隊。',
   1200, 0, 1),
(5, N'/images/instructors/emma.jpg',
   N'專長：孕期營養、嬰幼兒副食品諮詢。持有國際認證泌乳顧問 (IBCLC) 資格。',
   1000, 1, 1);
GO

-- ============================================================
PRINT '所有資料表建立並插入範例資料完畢（v2）。';
GO
