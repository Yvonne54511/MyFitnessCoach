USE [MyFitnessCoachDb]
GO
/****** Object:  Table [dbo].[Departments]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Departments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[ManagerId] [int] NULL,
 CONSTRAINT [PK_Departments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employees](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[DepartmentId] [int] NOT NULL,
	[ManagerId] [int] NULL,
	[WorkDelegateId] [int] NULL,
	[HiredDate] [date] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Account] [nvarchar](50) NULL,
	[HashedPassword] [nvarchar](256) NULL,
	[UserName] [nvarchar](30) NOT NULL,
	[Email] [nvarchar](200) NOT NULL,
	[Mobile] [varchar](10) NULL,
	[IsConfirmed] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[NewMemberConfirmCode] [varchar](100) NULL,
	[NewMemberConfirmCodeExpiry] [datetime2](0) NULL,
	[ResetPasswordConfirmCode] [varchar](100) NULL,
	[ResetPasswordConfirmCodeExpiry] [datetime2](0) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](30) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Description] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRoles]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_EmployeeDeptInfo]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_EmployeeDeptInfo] AS
  SELECT
      u.UserName,
      r.RoleName     AS Role,
      d.Name         AS DepartmentName,
      mgr_u.UserName AS ManagerName,
      del_u.UserName AS WorkDelegateName
  FROM      Employees   e
  JOIN      Users       u     ON  u.Id      = e.UserId
  JOIN      Departments d     ON  d.Id      = e.DepartmentId
  LEFT JOIN UserRoles   ur    ON  ur.UserId = u.Id
  LEFT JOIN Roles       r     ON  r.Id      = ur.RoleId
  LEFT JOIN Employees   mgr_e ON  mgr_e.Id  = e.ManagerId
  LEFT JOIN Users       mgr_u ON  mgr_u.Id  = mgr_e.UserId
  LEFT JOIN Employees   del_e ON  del_e.Id  = e.WorkDelegateId
  LEFT JOIN Users       del_u ON  del_u.Id  = del_e.UserId;
GO
/****** Object:  Table [dbo].[Functions]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Functions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FunctionName] [nvarchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Api_path] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleFunctions]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleFunctions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoleId] [int] NOT NULL,
	[FunctionId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_UserRoleFunctions]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- 2. 建立視圖 (Views)
-- ============================================================

CREATE VIEW [dbo].[vw_UserRoleFunctions] AS
SELECT u.UserName, u.Account, r.RoleName, f.FunctionName
FROM [dbo].[Users] u
JOIN [dbo].[UserRoles] ur ON u.Id = ur.UserId
JOIN [dbo].[Roles] r ON ur.RoleId = r.Id
JOIN [dbo].[RoleFunctions] rf ON r.Id = rf.RoleId
JOIN [dbo].[Functions] f ON rf.FunctionId = f.Id;
GO
/****** Object:  View [dbo].[vw_RoleFunctions]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_RoleFunctions] AS
SELECT r.RoleName, f.FunctionName
FROM [dbo].[Roles] r
JOIN [dbo].[RoleFunctions] rf ON r.Id = rf.RoleId
JOIN [dbo].[Functions] f ON rf.FunctionId = f.Id;
GO
/****** Object:  View [dbo].[vw_UserRoleFunction]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_UserRoleFunction] AS
SELECT u.Id AS UserId, u.UserName, u.Email, r.Id AS RoleId, r.RoleName, f.Id AS FunctionId, f.FunctionName
FROM Users u
JOIN UserRoles ur ON ur.UserId = u.Id
JOIN Roles r ON r.Id = ur.RoleId
JOIN RoleFunctions rf ON rf.RoleId = r.Id
JOIN [Functions] f ON f.Id = rf.FunctionId;
GO
/****** Object:  Table [dbo].[Members]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Members](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[Gender] [tinyint] NULL,
	[DateOfBirth] [datetime2](0) NULL,
	[Weight] [float] NULL,
	[Height] [float] NULL,
	[ActivityLevel] [nvarchar](50) NULL,
	[Target] [nvarchar](50) NULL,
	[BMR] [float] NULL,
	[TDEE] [float] NULL,
	[ImageUrl] [nvarchar](300) NULL,
	[CancelCount] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FoodCategories]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FoodCategories](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Foods]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Foods](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CategoryId] [int] NOT NULL,
	[FoodName] [nvarchar](50) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Nutrients]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Nutrients](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FoodId] [int] NOT NULL,
	[BaseAmount] [int] NOT NULL,
	[Measure] [nvarchar](20) NOT NULL,
	[Kcal] [float] NULL,
	[ProteinGram] [float] NULL,
	[CarbGram] [float] NULL,
	[FatGram] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FoodRecords]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FoodRecords](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MemberId] [int] NOT NULL,
	[EatDT] [datetime2](0) NOT NULL,
	[MealType] [nvarchar](20) NOT NULL,
	[FoodId] [int] NOT NULL,
	[Amount] [float] NOT NULL,
	[Measure] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_UserMemberFoodRecord]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_UserMemberFoodRecord] AS
SELECT u.Id AS UserId, u.UserName, u.Email, m.Id AS MemberId, m.Gender, m.Weight, m.Height, m.BMR, m.TDEE,
       fr.Id AS FoodRecordId, fr.EatDT, fr.MealType, fr.Amount, fr.Measure AS RecordMeasure,
       fo.Id AS FoodId, fo.FoodName, fc.CategoryName, n.BaseAmount, n.Measure AS NutrientMeasure,
       ROUND(n.Kcal * fr.Amount / n.BaseAmount, 2) AS TotalKcal,
       ROUND(n.ProteinGram * fr.Amount / n.BaseAmount, 2) AS TotalProtein,
       ROUND(n.CarbGram * fr.Amount / n.BaseAmount, 2) AS TotalCarb,
       ROUND(n.FatGram * fr.Amount / n.BaseAmount, 2) AS TotalFat
FROM Users u
JOIN Members m ON m.UserId = u.Id
JOIN FoodRecords fr ON fr.MemberId = m.Id
JOIN Foods fo ON fo.Id = fr.FoodId
JOIN FoodCategories fc ON fc.Id = fo.CategoryId
LEFT JOIN Nutrients n ON n.FoodId = fo.Id;
GO
/****** Object:  Table [dbo].[Instructors]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Instructors](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ImageUrl] [nvarchar](300) NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
	[HourWage] [int] NOT NULL,
	[CancelCount] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LeaveAttachments]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeaveAttachments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RequestId] [int] NOT NULL,
	[FileName] [nvarchar](200) NOT NULL,
	[FileUrl] [nvarchar](500) NOT NULL,
	[UploadedAt] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_LeaveAttachments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LeaveBalances]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeaveBalances](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeId] [int] NOT NULL,
	[LeaveTypeId] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[TotalDays] [decimal](4, 1) NOT NULL,
	[UsedDays] [decimal](4, 1) NOT NULL,
	[RemainingDays]  AS ([TotalDays]-[UsedDays]) PERSISTED,
 CONSTRAINT [PK_LeaveBalances] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LeaveRequests]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeaveRequests](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeId] [int] NOT NULL,
	[LeaveTypeId] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[DaysUsed] [decimal](4, 1) NOT NULL,
	[Reason] [nvarchar](500) NULL,
	[Status] [nvarchar](20) NOT NULL,
	[LeaveDelegateId] [int] NULL,
	[ApprovedBy] [int] NULL,
	[ApprovedAt] [datetime2](0) NULL,
	[RejectReason] [nvarchar](300) NULL,
	[CreatedAt] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_LeaveRequests] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LeaveTypes]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeaveTypes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](30) NOT NULL,
	[DaysPerYear] [int] NOT NULL,
	[CarryOver] [bit] NOT NULL,
	[RequiresDoc] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_LeaveTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MemberViolations]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MemberViolations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MemberId] [int] NOT NULL,
	[WarningCount] [int] NOT NULL,
	[IsSuspended] [bit] NOT NULL,
	[LastWarningAt] [datetime2](0) NULL,
	[SuspendedAt] [datetime2](0) NULL,
	[Reason] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notifications]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notifications](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[SenderId] [int] NULL,
	[NotifyType] [nvarchar](50) NOT NULL,
	[Title] [nvarchar](100) NOT NULL,
	[Content] [nvarchar](max) NOT NULL,
	[IsRead] [bit] NOT NULL,
	[ReferenceId] [int] NULL,
	[CreatedAt] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PointOrders]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PointOrders](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MemberId] [int] NOT NULL,
	[TopUpPlanId] [int] NOT NULL,
	[CreateAt] [datetime2](7) NOT NULL,
	[PointQty] [int] NOT NULL,
	[OriginalPrice] [decimal](18, 0) NOT NULL,
	[DiscountedPrice] [decimal](18, 0) NOT NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK__PointOrd__3214EC0746269E1A] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PointsRecordDetails]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PointsRecordDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PointOrderId] [int] NOT NULL,
	[UserWalletId] [int] NOT NULL,
	[CreateAt] [datetime2](0) NOT NULL,
	[PointAmount] [int] NOT NULL,
	[MerchandiseCategory] [nvarchar](50) NOT NULL,
	[ReserveOrderId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductCategories]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductCategories](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](50) NOT NULL,
	[SortOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductOrderDetails]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductOrderDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductOrderId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[UnitPrice] [decimal](18, 0) NOT NULL,
	[Qty] [int] NOT NULL,
	[SubTotal] [decimal](18, 0) NOT NULL,
	[DiscountedPrice] [decimal](18, 0) NOT NULL,
	[ProductName] [nvarchar](50) NOT NULL,
	[ImageURL] [nvarchar](300) NULL,
	[Memo] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductOrders]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductOrders](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MemberId] [int] NOT NULL,
	[CreateAt] [datetime2](7) NOT NULL,
	[OriginalAmount] [decimal](18, 0) NOT NULL,
	[DiscountAmount] [decimal](18, 0) NOT NULL,
	[Receiver] [nvarchar](30) NOT NULL,
	[Address] [nvarchar](500) NOT NULL,
	[Mobile] [varchar](20) NOT NULL,
	[TaxNumber] [int] NULL,
	[Status] [int] NOT NULL,
	[Memo] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CategoryId] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[ImageUrl] [nvarchar](max) NULL,
	[OriginalPrice] [decimal](18, 0) NOT NULL,
	[UnitPrice] [decimal](18, 0) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK__Products__3214EC0794CE8449] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReserveOrders]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReserveOrders](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MemberId] [int] NOT NULL,
	[ShiftId] [int] NOT NULL,
	[CreateAt] [datetime2](0) NOT NULL,
	[Status] [nvarchar](10) NOT NULL,
	[PaymentMethod] [nvarchar](10) NOT NULL,
	[Target] [nvarchar](300) NULL,
	[PointCost] [int] NULL,
	[Price] [decimal](10, 2) NULL,
	[Memorandum] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reviews]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reviews](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReserveOrderId] [int] NOT NULL,
	[InstructorId] [int] NOT NULL,
	[MemberId] [int] NOT NULL,
	[Rating] [int] NOT NULL,
	[Comment] [nvarchar](500) NULL,
	[CreatedAt] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SensitiveWords]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SensitiveWords](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Word] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Shifts]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Shifts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[InstructorId] [int] NOT NULL,
	[ScheduleDate] [date] NOT NULL,
	[TimeSlot] [nvarchar](20) NOT NULL,
	[IsBooked] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TopUpPlans]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TopUpPlans](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PlanName] [nvarchar](50) NOT NULL,
	[ImageUrl] [nvarchar](max) NULL,
	[Price] [decimal](18, 0) NOT NULL,
	[Points] [int] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK__TopUpPla__3214EC07E1DBA0D1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserExternalLogins]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserExternalLogins](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[LoginProvider] [nvarchar](50) NOT NULL,
	[ProviderKey] [nvarchar](255) NOT NULL,
	[ProviderDisplayName] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserWallets]    Script Date: 2026/3/16 下午 05:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserWallets](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MemberId] [int] NOT NULL,
	[CurrentBalance] [decimal](10, 2) NOT NULL,
	[LastUpdated] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Departments] ON 

INSERT [dbo].[Departments] ([Id], [Name], [ManagerId]) VALUES (1, N'採購部', 1)
INSERT [dbo].[Departments] ([Id], [Name], [ManagerId]) VALUES (2, N'行銷部', 3)
SET IDENTITY_INSERT [dbo].[Departments] OFF
GO
SET IDENTITY_INSERT [dbo].[Employees] ON 

INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (1, 2152, 1, NULL, 2, CAST(N'2016-04-01' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (2, 2153, 1, NULL, 1, CAST(N'2017-09-15' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (3, 2154, 2, NULL, 4, CAST(N'2015-11-20' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (4, 2155, 2, NULL, 3, CAST(N'2018-03-10' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (5, 2027, 1, 1, 8, CAST(N'2019-03-13' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (6, 2028, 1, 1, 9, CAST(N'2021-01-20' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (7, 2029, 1, 1, 10, CAST(N'2022-11-30' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (8, 2030, 1, 1, 11, CAST(N'2020-10-09' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (9, 2031, 1, 1, 12, CAST(N'2022-08-19' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (10, 2032, 1, 2, 13, CAST(N'2020-06-28' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (11, 2033, 1, 2, 14, CAST(N'2022-05-08' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (12, 2034, 1, 2, 5, CAST(N'2020-03-17' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (13, 2035, 1, 2, 6, CAST(N'2022-01-25' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (14, 2036, 1, 2, 7, CAST(N'2019-12-05' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (15, 2037, 2, 3, 18, CAST(N'2022-03-14' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (16, 2038, 2, 3, 19, CAST(N'2020-01-22' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (17, 2039, 2, 3, 20, CAST(N'2021-12-01' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (18, 2040, 2, 3, 21, CAST(N'2019-10-11' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (19, 2041, 2, 3, 22, CAST(N'2021-08-20' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (20, 2042, 2, 4, 23, CAST(N'2019-06-30' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (21, 2043, 2, 4, 24, CAST(N'2021-05-09' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (22, 2044, 2, 4, 15, CAST(N'2023-03-19' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (23, 2045, 2, 4, 16, CAST(N'2021-01-26' AS Date), 1)
INSERT [dbo].[Employees] ([Id], [UserId], [DepartmentId], [ManagerId], [WorkDelegateId], [HiredDate], [IsActive]) VALUES (24, 2046, 2, 4, 17, CAST(N'2022-12-06' AS Date), 1)
SET IDENTITY_INSERT [dbo].[Employees] OFF
GO
SET IDENTITY_INSERT [dbo].[Functions] ON 

INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (18, N'edit_Password', 1, N'修改個人自己的登入密碼', N'/Account/ResetPassword')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (19, N'edit_IntructorDetails', 1, N'修改教練自己的個人簡介', N'/Account/InstructorDetails')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (20, N'edit_InstructorShifts', 1, N'安排或修改教練自己的排班', N'/Shift/Index')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (21, N'view_InstructorShifts', 1, N'查看所有教練的排班情況', N'/Shift/AllShifts')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (22, N'edit_UserAccounts', 1, N'管理、設定、修改、停用、恢復所有使用者的帳號', N'/Staff/Index')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (23, N'edit_RoleFunctions', 1, N'設定每個角色可以使用哪些系統功能(設定每個角色的權限設定)', N'/Staff/RoleFunctions')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (24, N'edit_UserRoles', 1, N'新增或修改使用者的所屬角色', N'/Staff/UserRoles')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (25, N'edit_ProductCategories', 1, N'管理商品的商品分類', N'/ProductCategories/Index')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (26, N'edit_ProductItems', 1, N'管理商品的商品', N'/Products/Index')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (27, N'edit_ProductOrders', 1, N'處理商品的訂單', N'/ProductOrders/index')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (28, N'edit_Plans', 1, N'制定或修改促銷方案', N'/TopUpPlans/Index')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (29, N'edit_PlanOrders', 1, N'處理促銷方案或課程購買生成的訂單', N'/PointOrders/Index')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (30, N'view_PointRecords', 1, N'查看會員的點數取得及使用紀錄', N'/Member/PointsRecord')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (31, N'view_ClientFoodRecords', 1, N'查看會員每日的飲食紀錄', N'/Member/ViewFoodRecords')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (32, N'view_ClientBodyData', 1, N'查看會員生理數據變化', N'/Member/ViewFoodRecords')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (33, N'edit_Comments_admin', 1, N'系統管理員回覆評論或刪除', N'/Review/AdminIndex')
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (34, N'edit_Comments_instructor', 1, N'專業教練回覆評論', N'/Review/InstructorIndex')
SET IDENTITY_INSERT [dbo].[Functions] OFF
GO
SET IDENTITY_INSERT [dbo].[Instructors] ON 

INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (1, 2014, N'/img/instructors/2fdd6221-313a-41d0-a2a5-cabb850147b2.png', N'專精減脂', 1000, 0, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (2, 2013, N'/img/instructors/78841054-16e7-440b-8494-9cb6f4f2df54.png', N'糖尿病飲食', 1200, 3, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (3, 2015, N'/img/instructors/0e8d9a55-2963-43fb-9e3f-cfb265c1bc0b.png', N'專業營養諮詢服務 ', 1200, 0, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (4, 2016, N'/img/instructors/9ddf0472-0642-45ba-a592-e836cb85d3cf.png', N'專業營養諮詢服務', 1200, 0, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (5, 2017, N'/img/instructors/ffa16343-7f56-40f0-9282-b27b47108b65.png', N'專業營養諮詢服務
', 1200, 0, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (6, 2018, N'/img/instructors/7c1be7ee-b927-4a5b-a168-86b5510e1bca.png', N'專業營養諮詢服務', 1200, 0, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (7, 2019, N'/img/instructors/ebfc7e8f-6ea2-4179-9750-16191da13d6f.png', N'專業營養諮詢服務 ', 1200, 0, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (8, 2020, N'/img/instructors/d3fe64a5-6417-4f46-ba0f-333226917561.png', N'專業營養諮詢服務 ', 1200, 0, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (9, 2021, N'/img/instructors/cff505df-0738-42b1-a543-cc62e32a2106.png', N'專業營養諮詢服務
', 1200, 0, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (10, 2022, N'/img/instructors/efe17d3a-d611-42cb-89e9-feab0e77b90f.png', N'專業營養諮詢服務', 1200, 0, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (11, 2023, N'/img/instructors/1892576e-537d-4eb4-99a9-ed08450ffbc7.png', N'專業營養諮詢服務', 1200, 0, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (12, 2024, N'/img/instructors/f8ebf282-a4f7-49cf-9675-48ff13f34651.png', N'專業營養諮詢服務', 1200, 0, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (13, 2025, N'/img/instructors/86c45e51-9245-45f0-90c2-1d4cbec662f6.png', N'專業營養諮詢服務 ', 1200, 0, 1)
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (14, 2026, N'/img/instructors/3f5a8d07-3d26-451f-96ee-2e37b651be8c.png', N'專業營養諮詢服務', 1200, 0, 1)
SET IDENTITY_INSERT [dbo].[Instructors] OFF
GO
SET IDENTITY_INSERT [dbo].[LeaveAttachments] ON 

INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (1, 2, N'診斷證明_陳志明.pdf', N'/uploads/leave-docs/2.pdf', CAST(N'2026-01-31T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (2, 117, N'診斷證明_林辰書.pdf', N'/uploads/leave-docs/117.pdf', CAST(N'2026-02-08T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (3, 112, N'診斷證明_劉書沐.pdf', N'/uploads/leave-docs/112.pdf', CAST(N'2026-02-07T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (4, 107, N'診斷證明_孫安薇.pdf', N'/uploads/leave-docs/107.pdf', CAST(N'2026-02-06T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (5, 102, N'診斷證明_趙薇沐.pdf', N'/uploads/leave-docs/102.pdf', CAST(N'2026-02-05T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (6, 97, N'診斷證明_張朗薇.pdf', N'/uploads/leave-docs/97.pdf', CAST(N'2026-02-04T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (7, 92, N'診斷證明_孫楠清.pdf', N'/uploads/leave-docs/92.pdf', CAST(N'2026-02-03T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (8, 87, N'診斷證明_黃涵雅.pdf', N'/uploads/leave-docs/87.pdf', CAST(N'2026-02-02T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (9, 82, N'診斷證明_楊揚遠.pdf', N'/uploads/leave-docs/82.pdf', CAST(N'2026-02-01T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (10, 77, N'診斷證明_陳柔辰.pdf', N'/uploads/leave-docs/77.pdf', CAST(N'2026-01-31T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (11, 72, N'診斷證明_趙宇清.pdf', N'/uploads/leave-docs/72.pdf', CAST(N'2026-01-30T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (12, 67, N'診斷證明_黃揚航.pdf', N'/uploads/leave-docs/67.pdf', CAST(N'2026-02-13T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (13, 62, N'診斷證明_劉晨柔.pdf', N'/uploads/leave-docs/62.pdf', CAST(N'2026-02-12T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (14, 57, N'診斷證明_何雅澤.pdf', N'/uploads/leave-docs/57.pdf', CAST(N'2026-02-11T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (15, 52, N'診斷證明_吳青揚.pdf', N'/uploads/leave-docs/52.pdf', CAST(N'2026-02-10T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (16, 47, N'診斷證明_張霖瑾.pdf', N'/uploads/leave-docs/47.pdf', CAST(N'2026-02-09T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (17, 42, N'診斷證明_馬若瑤.pdf', N'/uploads/leave-docs/42.pdf', CAST(N'2026-02-08T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (18, 37, N'診斷證明_高詩寧.pdf', N'/uploads/leave-docs/37.pdf', CAST(N'2026-02-07T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (19, 32, N'診斷證明_趙晨庭.pdf', N'/uploads/leave-docs/32.pdf', CAST(N'2026-02-06T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (20, 27, N'診斷證明_王音寧.pdf', N'/uploads/leave-docs/27.pdf', CAST(N'2026-02-05T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (21, 22, N'診斷證明_高清星.pdf', N'/uploads/leave-docs/22.pdf', CAST(N'2026-02-04T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (22, 17, N'診斷證明_王淑芬.pdf', N'/uploads/leave-docs/17.pdf', CAST(N'2026-02-03T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (23, 12, N'診斷證明_張建國.pdf', N'/uploads/leave-docs/12.pdf', CAST(N'2026-02-02T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveAttachments] ([Id], [RequestId], [FileName], [FileUrl], [UploadedAt]) VALUES (24, 7, N'診斷證明_林美玲.pdf', N'/uploads/leave-docs/7.pdf', CAST(N'2026-02-01T00:00:00.0000000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[LeaveAttachments] OFF
GO
SET IDENTITY_INSERT [dbo].[LeaveBalances] ON 

INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (1, 1, 1, 2026, CAST(15.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (2, 1, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (3, 1, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (4, 1, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (5, 1, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (6, 1, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (7, 2, 1, 2026, CAST(15.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (8, 2, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (9, 2, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (10, 2, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (11, 2, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (12, 2, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (13, 3, 1, 2026, CAST(15.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (14, 3, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (15, 3, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (16, 3, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (17, 3, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (18, 3, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (19, 4, 1, 2026, CAST(15.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (20, 4, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (21, 4, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (22, 4, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (23, 4, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (24, 4, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (25, 5, 1, 2026, CAST(15.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (26, 5, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (27, 5, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (28, 5, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (29, 5, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (30, 5, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (31, 6, 1, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (32, 6, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (33, 6, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (34, 6, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (35, 6, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (36, 6, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (37, 7, 1, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (38, 7, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (39, 7, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (40, 7, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (41, 7, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (42, 7, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (43, 8, 1, 2026, CAST(15.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (44, 8, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (45, 8, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (46, 8, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (47, 8, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (48, 8, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (49, 9, 1, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (50, 9, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (51, 9, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (52, 9, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (53, 9, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (54, 9, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (55, 10, 1, 2026, CAST(15.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (56, 10, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (57, 10, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (58, 10, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (59, 10, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (60, 10, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (61, 11, 1, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (62, 11, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (63, 11, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (64, 11, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (65, 11, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (66, 11, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (67, 12, 1, 2026, CAST(15.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (68, 12, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (69, 12, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (70, 12, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (71, 12, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (72, 12, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (73, 13, 1, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (74, 13, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (75, 13, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (76, 13, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (77, 13, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (78, 13, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (79, 14, 1, 2026, CAST(15.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (80, 14, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (81, 14, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (82, 14, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (83, 14, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (84, 14, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (85, 15, 1, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (86, 15, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (87, 15, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (88, 15, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (89, 15, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (90, 15, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (91, 16, 1, 2026, CAST(15.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (92, 16, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (93, 16, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (94, 16, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (95, 16, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (96, 16, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (97, 17, 1, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (98, 17, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (99, 17, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
GO
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (100, 17, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (101, 17, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (102, 17, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (103, 18, 1, 2026, CAST(15.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (104, 18, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (105, 18, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (106, 18, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (107, 18, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (108, 18, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (109, 19, 1, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (110, 19, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (111, 19, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (112, 19, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (113, 19, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (114, 19, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (115, 20, 1, 2026, CAST(15.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (116, 20, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (117, 20, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (118, 20, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (119, 20, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (120, 20, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (121, 21, 1, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (122, 21, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (123, 21, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (124, 21, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (125, 21, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (126, 21, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (127, 22, 1, 2026, CAST(10.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (128, 22, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (129, 22, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (130, 22, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (131, 22, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (132, 22, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (133, 23, 1, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (134, 23, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (135, 23, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (136, 23, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (137, 23, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (138, 23, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (139, 24, 1, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (140, 24, 2, 2026, CAST(30.0 AS Decimal(4, 1)), CAST(1.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (141, 24, 3, 2026, CAST(14.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (142, 24, 4, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (143, 24, 5, 2026, CAST(8.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
INSERT [dbo].[LeaveBalances] ([Id], [EmployeeId], [LeaveTypeId], [Year], [TotalDays], [UsedDays]) VALUES (144, 24, 6, 2026, CAST(0.0 AS Decimal(4, 1)), CAST(0.0 AS Decimal(4, 1)))
SET IDENTITY_INSERT [dbo].[LeaveBalances] OFF
GO
SET IDENTITY_INSERT [dbo].[LeaveRequests] ON 

INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (1, 1, 1, CAST(N'2026-01-07T00:00:00.000' AS DateTime), CAST(N'2026-01-08T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 2, 2, CAST(N'2026-01-06T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-04T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (2, 1, 2, CAST(N'2026-02-03T00:00:00.000' AS DateTime), CAST(N'2026-02-04T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 2, 2, CAST(N'2026-02-02T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-31T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (3, 1, 3, CAST(N'2026-02-17T00:00:00.000' AS DateTime), CAST(N'2026-02-18T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 2, 2, CAST(N'2026-02-16T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-14T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (4, 1, 1, CAST(N'2026-04-08T00:00:00.000' AS DateTime), CAST(N'2026-04-09T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 2, NULL, NULL, NULL, CAST(N'2026-04-05T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (5, 1, 3, CAST(N'2026-03-03T00:00:00.000' AS DateTime), CAST(N'2026-03-03T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 2, NULL, NULL, NULL, CAST(N'2026-02-28T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (6, 2, 1, CAST(N'2026-01-08T00:00:00.000' AS DateTime), CAST(N'2026-01-09T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 1, 1, CAST(N'2026-01-07T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-05T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (7, 2, 2, CAST(N'2026-02-04T00:00:00.000' AS DateTime), CAST(N'2026-02-05T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 1, 1, CAST(N'2026-02-03T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-01T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (8, 2, 3, CAST(N'2026-02-18T00:00:00.000' AS DateTime), CAST(N'2026-02-19T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 1, 1, CAST(N'2026-02-17T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-15T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (9, 2, 1, CAST(N'2026-04-09T00:00:00.000' AS DateTime), CAST(N'2026-04-10T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 1, NULL, NULL, NULL, CAST(N'2026-04-06T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (10, 2, 3, CAST(N'2026-03-04T00:00:00.000' AS DateTime), CAST(N'2026-03-04T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 1, NULL, NULL, NULL, CAST(N'2026-03-01T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (11, 3, 1, CAST(N'2026-01-09T00:00:00.000' AS DateTime), CAST(N'2026-01-10T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 4, 4, CAST(N'2026-01-08T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-06T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (12, 3, 2, CAST(N'2026-02-05T00:00:00.000' AS DateTime), CAST(N'2026-02-06T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 4, 4, CAST(N'2026-02-04T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-02T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (13, 3, 3, CAST(N'2026-02-19T00:00:00.000' AS DateTime), CAST(N'2026-02-20T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 4, 4, CAST(N'2026-02-18T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-16T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (14, 3, 1, CAST(N'2026-04-10T00:00:00.000' AS DateTime), CAST(N'2026-04-11T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 4, NULL, NULL, NULL, CAST(N'2026-04-07T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (15, 3, 3, CAST(N'2026-03-05T00:00:00.000' AS DateTime), CAST(N'2026-03-05T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 4, NULL, NULL, NULL, CAST(N'2026-03-02T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (16, 4, 1, CAST(N'2026-01-10T00:00:00.000' AS DateTime), CAST(N'2026-01-11T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 3, 3, CAST(N'2026-01-09T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-07T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (17, 4, 2, CAST(N'2026-02-06T00:00:00.000' AS DateTime), CAST(N'2026-02-07T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 3, 3, CAST(N'2026-02-05T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-03T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (18, 4, 3, CAST(N'2026-02-20T00:00:00.000' AS DateTime), CAST(N'2026-02-21T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 3, 3, CAST(N'2026-02-19T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-17T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (19, 4, 1, CAST(N'2026-04-11T00:00:00.000' AS DateTime), CAST(N'2026-04-12T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 3, NULL, NULL, NULL, CAST(N'2026-04-08T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (20, 4, 3, CAST(N'2026-03-06T00:00:00.000' AS DateTime), CAST(N'2026-03-06T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 3, NULL, NULL, NULL, CAST(N'2026-03-03T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (21, 5, 1, CAST(N'2026-01-11T00:00:00.000' AS DateTime), CAST(N'2026-01-12T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 8, 1, CAST(N'2026-01-10T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-08T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (22, 5, 2, CAST(N'2026-02-07T00:00:00.000' AS DateTime), CAST(N'2026-02-08T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 8, 1, CAST(N'2026-02-06T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-04T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (23, 5, 3, CAST(N'2026-02-21T00:00:00.000' AS DateTime), CAST(N'2026-02-22T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 8, 1, CAST(N'2026-02-20T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-18T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (24, 5, 1, CAST(N'2026-04-12T00:00:00.000' AS DateTime), CAST(N'2026-04-13T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 8, NULL, NULL, NULL, CAST(N'2026-04-09T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (25, 5, 3, CAST(N'2026-03-07T00:00:00.000' AS DateTime), CAST(N'2026-03-07T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 8, NULL, NULL, NULL, CAST(N'2026-03-04T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (26, 6, 1, CAST(N'2026-01-12T00:00:00.000' AS DateTime), CAST(N'2026-01-13T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 9, 1, CAST(N'2026-01-11T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-09T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (27, 6, 2, CAST(N'2026-02-08T00:00:00.000' AS DateTime), CAST(N'2026-02-09T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 9, 1, CAST(N'2026-02-07T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-05T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (28, 6, 3, CAST(N'2026-02-22T00:00:00.000' AS DateTime), CAST(N'2026-02-23T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 9, 1, CAST(N'2026-02-21T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-19T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (29, 6, 1, CAST(N'2026-04-13T00:00:00.000' AS DateTime), CAST(N'2026-04-14T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 9, NULL, NULL, NULL, CAST(N'2026-04-10T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (30, 6, 3, CAST(N'2026-03-08T00:00:00.000' AS DateTime), CAST(N'2026-03-08T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 9, NULL, NULL, NULL, CAST(N'2026-03-05T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (31, 7, 1, CAST(N'2026-01-13T00:00:00.000' AS DateTime), CAST(N'2026-01-14T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 10, 1, CAST(N'2026-01-12T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-10T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (32, 7, 2, CAST(N'2026-02-09T00:00:00.000' AS DateTime), CAST(N'2026-02-10T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 10, 1, CAST(N'2026-02-08T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-06T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (33, 7, 3, CAST(N'2026-02-23T00:00:00.000' AS DateTime), CAST(N'2026-02-24T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 10, 1, CAST(N'2026-02-22T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-20T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (34, 7, 1, CAST(N'2026-04-14T00:00:00.000' AS DateTime), CAST(N'2026-04-15T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 10, NULL, NULL, NULL, CAST(N'2026-04-11T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (35, 7, 3, CAST(N'2026-03-09T00:00:00.000' AS DateTime), CAST(N'2026-03-09T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 10, NULL, NULL, NULL, CAST(N'2026-03-06T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (36, 8, 1, CAST(N'2026-01-14T00:00:00.000' AS DateTime), CAST(N'2026-01-15T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 11, 1, CAST(N'2026-01-13T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-11T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (37, 8, 2, CAST(N'2026-02-10T00:00:00.000' AS DateTime), CAST(N'2026-02-11T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 11, 1, CAST(N'2026-02-09T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-07T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (38, 8, 3, CAST(N'2026-02-24T00:00:00.000' AS DateTime), CAST(N'2026-02-25T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 11, 1, CAST(N'2026-02-23T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-21T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (39, 8, 1, CAST(N'2026-04-15T00:00:00.000' AS DateTime), CAST(N'2026-04-16T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 11, NULL, NULL, NULL, CAST(N'2026-04-12T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (40, 8, 3, CAST(N'2026-03-10T00:00:00.000' AS DateTime), CAST(N'2026-03-10T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 11, NULL, NULL, NULL, CAST(N'2026-03-07T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (41, 9, 1, CAST(N'2026-01-15T00:00:00.000' AS DateTime), CAST(N'2026-01-16T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 12, 1, CAST(N'2026-01-14T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-12T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (42, 9, 2, CAST(N'2026-02-11T00:00:00.000' AS DateTime), CAST(N'2026-02-12T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 12, 1, CAST(N'2026-02-10T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-08T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (43, 9, 3, CAST(N'2026-02-25T00:00:00.000' AS DateTime), CAST(N'2026-02-26T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 12, 1, CAST(N'2026-02-24T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-22T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (44, 9, 1, CAST(N'2026-04-16T00:00:00.000' AS DateTime), CAST(N'2026-04-17T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 12, NULL, NULL, NULL, CAST(N'2026-04-13T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (45, 9, 3, CAST(N'2026-03-11T00:00:00.000' AS DateTime), CAST(N'2026-03-11T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 12, NULL, NULL, NULL, CAST(N'2026-03-08T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (46, 10, 1, CAST(N'2026-01-16T00:00:00.000' AS DateTime), CAST(N'2026-01-17T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 13, 2, CAST(N'2026-01-15T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-13T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (47, 10, 2, CAST(N'2026-02-12T00:00:00.000' AS DateTime), CAST(N'2026-02-13T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 13, 2, CAST(N'2026-02-11T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-09T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (48, 10, 3, CAST(N'2026-02-16T00:00:00.000' AS DateTime), CAST(N'2026-02-17T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 13, 2, CAST(N'2026-02-15T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-13T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (49, 10, 1, CAST(N'2026-04-17T00:00:00.000' AS DateTime), CAST(N'2026-04-18T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 13, NULL, NULL, NULL, CAST(N'2026-04-14T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (50, 10, 3, CAST(N'2026-03-12T00:00:00.000' AS DateTime), CAST(N'2026-03-12T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 13, NULL, NULL, NULL, CAST(N'2026-03-09T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (51, 11, 1, CAST(N'2026-01-17T00:00:00.000' AS DateTime), CAST(N'2026-01-18T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 14, 2, CAST(N'2026-01-16T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-14T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (52, 11, 2, CAST(N'2026-02-13T00:00:00.000' AS DateTime), CAST(N'2026-02-14T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 14, 2, CAST(N'2026-02-12T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-10T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (53, 11, 3, CAST(N'2026-02-17T00:00:00.000' AS DateTime), CAST(N'2026-02-18T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 14, 2, CAST(N'2026-02-16T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-14T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (54, 11, 1, CAST(N'2026-04-18T00:00:00.000' AS DateTime), CAST(N'2026-04-19T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 14, NULL, NULL, NULL, CAST(N'2026-04-15T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (55, 11, 3, CAST(N'2026-03-13T00:00:00.000' AS DateTime), CAST(N'2026-03-13T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 14, NULL, NULL, NULL, CAST(N'2026-03-10T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (56, 12, 1, CAST(N'2026-01-18T00:00:00.000' AS DateTime), CAST(N'2026-01-19T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 5, 2, CAST(N'2026-01-17T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-15T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (57, 12, 2, CAST(N'2026-02-14T00:00:00.000' AS DateTime), CAST(N'2026-02-15T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 5, 2, CAST(N'2026-02-13T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-11T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (58, 12, 3, CAST(N'2026-02-18T00:00:00.000' AS DateTime), CAST(N'2026-02-19T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 5, 2, CAST(N'2026-02-17T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-15T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (59, 12, 1, CAST(N'2026-04-19T00:00:00.000' AS DateTime), CAST(N'2026-04-20T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 5, NULL, NULL, NULL, CAST(N'2026-04-16T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (60, 12, 3, CAST(N'2026-03-14T00:00:00.000' AS DateTime), CAST(N'2026-03-14T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 5, NULL, NULL, NULL, CAST(N'2026-03-11T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (61, 13, 1, CAST(N'2026-01-19T00:00:00.000' AS DateTime), CAST(N'2026-01-20T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 6, 2, CAST(N'2026-01-18T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-16T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (62, 13, 2, CAST(N'2026-02-15T00:00:00.000' AS DateTime), CAST(N'2026-02-16T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 6, 2, CAST(N'2026-02-14T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-12T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (63, 13, 3, CAST(N'2026-02-19T00:00:00.000' AS DateTime), CAST(N'2026-02-20T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 6, 2, CAST(N'2026-02-18T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-16T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (64, 13, 1, CAST(N'2026-04-20T00:00:00.000' AS DateTime), CAST(N'2026-04-21T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 6, NULL, NULL, NULL, CAST(N'2026-04-17T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (65, 13, 3, CAST(N'2026-03-15T00:00:00.000' AS DateTime), CAST(N'2026-03-15T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 6, NULL, NULL, NULL, CAST(N'2026-03-12T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (66, 14, 1, CAST(N'2026-01-20T00:00:00.000' AS DateTime), CAST(N'2026-01-21T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 7, 2, CAST(N'2026-01-19T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-17T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (67, 14, 2, CAST(N'2026-02-16T00:00:00.000' AS DateTime), CAST(N'2026-02-17T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 7, 2, CAST(N'2026-02-15T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-13T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (68, 14, 3, CAST(N'2026-02-20T00:00:00.000' AS DateTime), CAST(N'2026-02-21T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 7, 2, CAST(N'2026-02-19T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-17T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (69, 14, 1, CAST(N'2026-04-21T00:00:00.000' AS DateTime), CAST(N'2026-04-22T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 7, NULL, NULL, NULL, CAST(N'2026-04-18T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (70, 14, 3, CAST(N'2026-03-16T00:00:00.000' AS DateTime), CAST(N'2026-03-16T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 7, NULL, NULL, NULL, CAST(N'2026-03-13T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (71, 15, 1, CAST(N'2026-01-21T00:00:00.000' AS DateTime), CAST(N'2026-01-22T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 18, 3, CAST(N'2026-01-20T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-18T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (72, 15, 2, CAST(N'2026-02-02T00:00:00.000' AS DateTime), CAST(N'2026-02-03T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 18, 3, CAST(N'2026-02-01T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-30T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (73, 15, 3, CAST(N'2026-02-21T00:00:00.000' AS DateTime), CAST(N'2026-02-22T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 18, 3, CAST(N'2026-02-20T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-18T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (74, 15, 1, CAST(N'2026-04-22T00:00:00.000' AS DateTime), CAST(N'2026-04-23T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 18, NULL, NULL, NULL, CAST(N'2026-04-19T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (75, 15, 3, CAST(N'2026-03-02T00:00:00.000' AS DateTime), CAST(N'2026-03-02T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 18, NULL, NULL, NULL, CAST(N'2026-02-27T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (76, 16, 1, CAST(N'2026-01-22T00:00:00.000' AS DateTime), CAST(N'2026-01-23T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 19, 3, CAST(N'2026-01-21T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-19T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (77, 16, 2, CAST(N'2026-02-03T00:00:00.000' AS DateTime), CAST(N'2026-02-04T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 19, 3, CAST(N'2026-02-02T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-31T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (78, 16, 3, CAST(N'2026-02-22T00:00:00.000' AS DateTime), CAST(N'2026-02-23T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 19, 3, CAST(N'2026-02-21T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-19T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (79, 16, 1, CAST(N'2026-04-23T00:00:00.000' AS DateTime), CAST(N'2026-04-24T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 19, NULL, NULL, NULL, CAST(N'2026-04-20T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (80, 16, 3, CAST(N'2026-03-03T00:00:00.000' AS DateTime), CAST(N'2026-03-03T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 19, NULL, NULL, NULL, CAST(N'2026-02-28T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (81, 17, 1, CAST(N'2026-01-23T00:00:00.000' AS DateTime), CAST(N'2026-01-24T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 20, 3, CAST(N'2026-01-22T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-20T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (82, 17, 2, CAST(N'2026-02-04T00:00:00.000' AS DateTime), CAST(N'2026-02-05T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 20, 3, CAST(N'2026-02-03T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-01T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (83, 17, 3, CAST(N'2026-02-23T00:00:00.000' AS DateTime), CAST(N'2026-02-24T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 20, 3, CAST(N'2026-02-22T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-20T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (84, 17, 1, CAST(N'2026-04-24T00:00:00.000' AS DateTime), CAST(N'2026-04-25T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 20, NULL, NULL, NULL, CAST(N'2026-04-21T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (85, 17, 3, CAST(N'2026-03-04T00:00:00.000' AS DateTime), CAST(N'2026-03-04T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 20, NULL, NULL, NULL, CAST(N'2026-03-01T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (86, 18, 1, CAST(N'2026-01-24T00:00:00.000' AS DateTime), CAST(N'2026-01-25T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 21, 3, CAST(N'2026-01-23T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-21T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (87, 18, 2, CAST(N'2026-02-05T00:00:00.000' AS DateTime), CAST(N'2026-02-06T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 21, 3, CAST(N'2026-02-04T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-02T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (88, 18, 3, CAST(N'2026-02-24T00:00:00.000' AS DateTime), CAST(N'2026-02-25T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 21, 3, CAST(N'2026-02-23T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-21T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (89, 18, 1, CAST(N'2026-04-25T00:00:00.000' AS DateTime), CAST(N'2026-04-26T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 21, NULL, NULL, NULL, CAST(N'2026-04-22T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (90, 18, 3, CAST(N'2026-03-05T00:00:00.000' AS DateTime), CAST(N'2026-03-05T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 21, NULL, NULL, NULL, CAST(N'2026-03-02T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (91, 19, 1, CAST(N'2026-01-25T00:00:00.000' AS DateTime), CAST(N'2026-01-26T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 22, 3, CAST(N'2026-01-24T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-22T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (92, 19, 2, CAST(N'2026-02-06T00:00:00.000' AS DateTime), CAST(N'2026-02-07T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 22, 3, CAST(N'2026-02-05T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-03T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (93, 19, 3, CAST(N'2026-02-25T00:00:00.000' AS DateTime), CAST(N'2026-02-26T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 22, 3, CAST(N'2026-02-24T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-22T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (94, 19, 1, CAST(N'2026-04-26T00:00:00.000' AS DateTime), CAST(N'2026-04-27T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 22, NULL, NULL, NULL, CAST(N'2026-04-23T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (95, 19, 3, CAST(N'2026-03-06T00:00:00.000' AS DateTime), CAST(N'2026-03-06T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 22, NULL, NULL, NULL, CAST(N'2026-03-03T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (96, 20, 1, CAST(N'2026-01-06T00:00:00.000' AS DateTime), CAST(N'2026-01-07T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 23, 4, CAST(N'2026-01-05T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-03T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (97, 20, 2, CAST(N'2026-02-07T00:00:00.000' AS DateTime), CAST(N'2026-02-08T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 23, 4, CAST(N'2026-02-06T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-04T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (98, 20, 3, CAST(N'2026-02-16T00:00:00.000' AS DateTime), CAST(N'2026-02-17T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 23, 4, CAST(N'2026-02-15T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-13T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (99, 20, 1, CAST(N'2026-04-07T00:00:00.000' AS DateTime), CAST(N'2026-04-08T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 23, NULL, NULL, NULL, CAST(N'2026-04-04T00:00:00.0000000' AS DateTime2))
GO
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (100, 20, 3, CAST(N'2026-03-07T00:00:00.000' AS DateTime), CAST(N'2026-03-07T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 23, NULL, NULL, NULL, CAST(N'2026-03-04T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (101, 21, 1, CAST(N'2026-01-07T00:00:00.000' AS DateTime), CAST(N'2026-01-08T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 24, 4, CAST(N'2026-01-06T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-04T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (102, 21, 2, CAST(N'2026-02-08T00:00:00.000' AS DateTime), CAST(N'2026-02-09T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 24, 4, CAST(N'2026-02-07T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-05T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (103, 21, 3, CAST(N'2026-02-17T00:00:00.000' AS DateTime), CAST(N'2026-02-18T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 24, 4, CAST(N'2026-02-16T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-14T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (104, 21, 1, CAST(N'2026-04-08T00:00:00.000' AS DateTime), CAST(N'2026-04-09T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 24, NULL, NULL, NULL, CAST(N'2026-04-05T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (105, 21, 3, CAST(N'2026-03-08T00:00:00.000' AS DateTime), CAST(N'2026-03-08T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 24, NULL, NULL, NULL, CAST(N'2026-03-05T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (106, 22, 1, CAST(N'2026-01-08T00:00:00.000' AS DateTime), CAST(N'2026-01-09T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 15, 4, CAST(N'2026-01-07T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-05T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (107, 22, 2, CAST(N'2026-02-09T00:00:00.000' AS DateTime), CAST(N'2026-02-10T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 15, 4, CAST(N'2026-02-08T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-06T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (108, 22, 3, CAST(N'2026-02-18T00:00:00.000' AS DateTime), CAST(N'2026-02-19T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 15, 4, CAST(N'2026-02-17T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-15T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (109, 22, 1, CAST(N'2026-04-09T00:00:00.000' AS DateTime), CAST(N'2026-04-10T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 15, NULL, NULL, NULL, CAST(N'2026-04-06T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (110, 22, 3, CAST(N'2026-03-09T00:00:00.000' AS DateTime), CAST(N'2026-03-09T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 15, NULL, NULL, NULL, CAST(N'2026-03-06T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (111, 23, 1, CAST(N'2026-01-09T00:00:00.000' AS DateTime), CAST(N'2026-01-10T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 16, 4, CAST(N'2026-01-08T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-06T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (112, 23, 2, CAST(N'2026-02-10T00:00:00.000' AS DateTime), CAST(N'2026-02-11T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 16, 4, CAST(N'2026-02-09T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-07T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (113, 23, 3, CAST(N'2026-02-19T00:00:00.000' AS DateTime), CAST(N'2026-02-20T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 16, 4, CAST(N'2026-02-18T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-16T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (114, 23, 1, CAST(N'2026-04-10T00:00:00.000' AS DateTime), CAST(N'2026-04-11T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 16, NULL, NULL, NULL, CAST(N'2026-04-07T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (115, 23, 3, CAST(N'2026-03-10T00:00:00.000' AS DateTime), CAST(N'2026-03-10T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 16, NULL, NULL, NULL, CAST(N'2026-03-07T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (116, 24, 1, CAST(N'2026-01-10T00:00:00.000' AS DateTime), CAST(N'2026-01-11T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'個人休假', N'Approved', 17, 4, CAST(N'2026-01-09T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-01-07T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (117, 24, 2, CAST(N'2026-02-11T00:00:00.000' AS DateTime), CAST(N'2026-02-12T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'身體不適需就醫', N'Approved', 17, 4, CAST(N'2026-02-10T00:00:00.0000000' AS DateTime2), NULL, CAST(N'2026-02-08T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (118, 24, 3, CAST(N'2026-02-20T00:00:00.000' AS DateTime), CAST(N'2026-02-21T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'處理私人事務', N'Rejected', 17, 4, CAST(N'2026-02-19T00:00:00.0000000' AS DateTime2), N'該日部門人力不足，建議改期', CAST(N'2026-02-17T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (119, 24, 1, CAST(N'2026-04-11T00:00:00.000' AS DateTime), CAST(N'2026-04-12T00:00:00.000' AS DateTime), CAST(1.0 AS Decimal(4, 1)), N'家庭旅遊計畫', N'Pending', 17, NULL, NULL, NULL, CAST(N'2026-04-08T00:00:00.0000000' AS DateTime2))
INSERT [dbo].[LeaveRequests] ([Id], [EmployeeId], [LeaveTypeId], [StartDate], [EndDate], [DaysUsed], [Reason], [Status], [LeaveDelegateId], [ApprovedBy], [ApprovedAt], [RejectReason], [CreatedAt]) VALUES (120, 24, 3, CAST(N'2026-03-11T00:00:00.000' AS DateTime), CAST(N'2026-03-11T00:00:00.000' AS DateTime), CAST(0.5 AS Decimal(4, 1)), N'辦理個人事務（半天）', N'Cancelled', 17, NULL, NULL, NULL, CAST(N'2026-03-08T00:00:00.0000000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[LeaveRequests] OFF
GO
SET IDENTITY_INSERT [dbo].[LeaveTypes] ON 

INSERT [dbo].[LeaveTypes] ([Id], [Name], [DaysPerYear], [CarryOver], [RequiresDoc], [IsActive]) VALUES (1, N'特休', 15, 1, 0, 1)
INSERT [dbo].[LeaveTypes] ([Id], [Name], [DaysPerYear], [CarryOver], [RequiresDoc], [IsActive]) VALUES (2, N'病假', 30, 0, 1, 1)
INSERT [dbo].[LeaveTypes] ([Id], [Name], [DaysPerYear], [CarryOver], [RequiresDoc], [IsActive]) VALUES (3, N'事假', 14, 0, 0, 1)
INSERT [dbo].[LeaveTypes] ([Id], [Name], [DaysPerYear], [CarryOver], [RequiresDoc], [IsActive]) VALUES (4, N'婚假', 8, 0, 1, 1)
INSERT [dbo].[LeaveTypes] ([Id], [Name], [DaysPerYear], [CarryOver], [RequiresDoc], [IsActive]) VALUES (5, N'喪假', 8, 0, 1, 1)
INSERT [dbo].[LeaveTypes] ([Id], [Name], [DaysPerYear], [CarryOver], [RequiresDoc], [IsActive]) VALUES (6, N'公假', 0, 0, 1, 1)
SET IDENTITY_INSERT [dbo].[LeaveTypes] OFF
GO
SET IDENTITY_INSERT [dbo].[Members] ON 

INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (1, 1, 2, CAST(N'1995-03-15T00:00:00.0000000' AS DateTime2), 58, 163, N'輕度活動', N'維持體重', NULL, NULL, NULL, 1)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (2, 2, 1, CAST(N'1990-07-22T00:00:00.0000000' AS DateTime2), 75, 178, N'中度活動', N'增肌', NULL, NULL, NULL, 1)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (3, 3, 2, CAST(N'1998-11-05T00:00:00.0000000' AS DateTime2), 52, 158, N'久坐', N'減重', NULL, NULL, NULL, 1)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (4, 11, 1, CAST(N'1993-04-10T00:00:00.0000000' AS DateTime2), 70, 175, N'中度活動', N'增肌', NULL, NULL, NULL, 1)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (5, 12, 2, CAST(N'1997-09-25T00:00:00.0000000' AS DateTime2), 54, 161, N'輕度活動', N'維持體重', NULL, NULL, NULL, 1)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (6, 13, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (7, 2052, 2, CAST(N'1999-06-27T21:04:12.0000000' AS DateTime2), 68, 180, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (8, 2053, 1, CAST(N'1982-09-25T21:04:12.0000000' AS DateTime2), 62, 169, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (9, 2054, 1, CAST(N'1985-02-14T21:04:12.0000000' AS DateTime2), 83, 179, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (10, 2055, 2, CAST(N'1988-08-02T21:04:12.0000000' AS DateTime2), 85, 170, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (11, 2056, 1, CAST(N'2000-10-22T21:04:12.0000000' AS DateTime2), 81, 182, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (12, 2057, 1, CAST(N'1983-12-31T21:04:12.0000000' AS DateTime2), 87, 173, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (13, 2058, 1, CAST(N'2005-11-26T21:04:12.0000000' AS DateTime2), 64, 184, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (14, 2059, 1, CAST(N'2002-09-18T21:04:12.0000000' AS DateTime2), 76, 181, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (15, 2060, 2, CAST(N'1994-04-19T21:04:12.0000000' AS DateTime2), 67, 184, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (16, 2061, 2, CAST(N'1985-06-12T21:04:12.0000000' AS DateTime2), 66, 179, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (17, 2062, 2, CAST(N'1985-10-11T21:04:12.0000000' AS DateTime2), 60, 174, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (18, 2063, 1, CAST(N'2003-03-20T21:04:12.0000000' AS DateTime2), 69, 176, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (19, 2064, 2, CAST(N'2000-03-18T21:04:12.0000000' AS DateTime2), 64, 182, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (20, 2065, 2, CAST(N'1999-02-20T21:04:12.0000000' AS DateTime2), 66, 182, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (21, 2066, 1, CAST(N'1981-11-19T21:04:12.0000000' AS DateTime2), 88, 176, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (22, 2067, 1, CAST(N'1994-08-04T21:04:12.0000000' AS DateTime2), 86, 170, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (23, 2068, 1, CAST(N'1999-11-19T21:04:12.0000000' AS DateTime2), 78, 169, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (24, 2069, 1, CAST(N'1993-01-12T21:04:12.0000000' AS DateTime2), 72, 178, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (25, 2070, 2, CAST(N'1991-06-14T21:04:12.0000000' AS DateTime2), 68, 172, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (26, 2071, 2, CAST(N'1981-12-30T21:04:12.0000000' AS DateTime2), 85, 177, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (27, 2072, 2, CAST(N'1990-08-09T21:04:12.0000000' AS DateTime2), 83, 170, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (28, 2073, 2, CAST(N'1982-09-13T21:04:12.0000000' AS DateTime2), 87, 178, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (29, 2074, 2, CAST(N'1981-06-18T21:04:12.0000000' AS DateTime2), 81, 170, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (30, 2075, 1, CAST(N'2001-11-26T21:04:12.0000000' AS DateTime2), 76, 167, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (31, 2076, 2, CAST(N'2003-06-23T21:04:12.0000000' AS DateTime2), 65, 160, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (32, 2077, 1, CAST(N'2006-09-24T21:04:12.0000000' AS DateTime2), 63, 160, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (33, 2078, 1, CAST(N'1990-12-20T21:04:12.0000000' AS DateTime2), 65, 164, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (34, 2079, 2, CAST(N'1989-04-22T21:04:12.0000000' AS DateTime2), 88, 162, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (35, 2080, 1, CAST(N'1988-09-25T21:04:12.0000000' AS DateTime2), 75, 181, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (36, 2081, 2, CAST(N'1998-10-10T21:04:12.0000000' AS DateTime2), 73, 182, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (37, 2082, 1, CAST(N'1990-06-18T21:04:12.0000000' AS DateTime2), 73, 177, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (38, 2083, 1, CAST(N'1987-11-02T21:04:12.0000000' AS DateTime2), 78, 170, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (39, 2084, 2, CAST(N'2000-06-08T21:04:12.0000000' AS DateTime2), 65, 168, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (40, 2085, 1, CAST(N'1982-07-25T21:04:12.0000000' AS DateTime2), 79, 182, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (41, 2086, 1, CAST(N'2006-08-04T21:04:12.0000000' AS DateTime2), 66, 179, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (42, 2087, 2, CAST(N'1996-07-30T21:04:12.0000000' AS DateTime2), 85, 169, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (43, 2088, 2, CAST(N'2006-11-18T21:04:12.0000000' AS DateTime2), 65, 160, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (44, 2089, 2, CAST(N'1997-05-15T21:04:12.0000000' AS DateTime2), 77, 164, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (45, 2090, 1, CAST(N'2005-12-29T21:04:12.0000000' AS DateTime2), 75, 165, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (46, 2091, 1, CAST(N'1999-09-24T21:04:12.0000000' AS DateTime2), 75, 160, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (47, 2092, 1, CAST(N'1992-11-13T21:04:12.0000000' AS DateTime2), 87, 164, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (48, 2093, 1, CAST(N'1980-07-20T21:04:12.0000000' AS DateTime2), 85, 168, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (49, 2094, 2, CAST(N'1991-05-21T21:04:12.0000000' AS DateTime2), 79, 175, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (50, 2095, 2, CAST(N'1989-07-16T21:04:12.0000000' AS DateTime2), 86, 176, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (51, 2096, 2, CAST(N'1997-10-27T21:04:12.0000000' AS DateTime2), 71, 172, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (52, 2097, 2, CAST(N'1985-10-09T21:04:12.0000000' AS DateTime2), 76, 171, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (53, 2098, 1, CAST(N'2006-03-13T21:04:12.0000000' AS DateTime2), 78, 179, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (54, 2099, 2, CAST(N'1990-07-04T21:04:12.0000000' AS DateTime2), 73, 169, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (55, 2100, 2, CAST(N'2006-09-07T21:04:12.0000000' AS DateTime2), 72, 175, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (56, 2101, 2, CAST(N'2001-11-01T21:04:12.0000000' AS DateTime2), 86, 163, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (57, 2102, 1, CAST(N'1985-10-24T21:04:12.0000000' AS DateTime2), 89, 180, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (58, 2103, 2, CAST(N'1996-12-16T21:04:12.0000000' AS DateTime2), 82, 168, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (59, 2104, 2, CAST(N'2002-08-01T21:04:12.0000000' AS DateTime2), 81, 172, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (60, 2105, 2, CAST(N'1997-04-21T21:04:12.0000000' AS DateTime2), 72, 163, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (61, 2106, 2, CAST(N'1980-02-17T21:04:12.0000000' AS DateTime2), 87, 164, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (62, 2107, 2, CAST(N'1992-05-01T21:04:12.0000000' AS DateTime2), 65, 177, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (63, 2108, 1, CAST(N'1981-09-19T21:04:12.0000000' AS DateTime2), 71, 175, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (64, 2109, 2, CAST(N'1995-11-12T21:04:12.0000000' AS DateTime2), 84, 164, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (65, 2110, 1, CAST(N'1998-08-18T21:04:12.0000000' AS DateTime2), 69, 164, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (66, 2111, 2, CAST(N'1984-09-26T21:04:12.0000000' AS DateTime2), 77, 184, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (67, 2112, 2, CAST(N'2006-03-27T21:04:12.0000000' AS DateTime2), 78, 168, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (68, 2113, 2, CAST(N'1997-09-24T21:04:12.0000000' AS DateTime2), 61, 162, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (69, 2114, 2, CAST(N'1979-12-15T21:04:12.0000000' AS DateTime2), 75, 167, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (70, 2115, 2, CAST(N'1994-10-30T21:04:12.0000000' AS DateTime2), 75, 165, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (71, 2116, 2, CAST(N'2004-11-08T21:04:12.0000000' AS DateTime2), 67, 170, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (72, 2117, 1, CAST(N'1998-07-15T21:04:12.0000000' AS DateTime2), 85, 180, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (73, 2118, 1, CAST(N'1989-05-22T21:04:12.0000000' AS DateTime2), 63, 172, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (74, 2119, 1, CAST(N'1982-03-09T21:04:12.0000000' AS DateTime2), 83, 171, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (75, 2120, 1, CAST(N'1996-01-03T21:04:12.0000000' AS DateTime2), 66, 169, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (76, 2121, 1, CAST(N'1983-07-30T21:04:13.0000000' AS DateTime2), 72, 173, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (77, 2122, 2, CAST(N'1986-02-26T21:04:13.0000000' AS DateTime2), 68, 165, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (78, 2123, 2, CAST(N'1991-12-04T21:04:13.0000000' AS DateTime2), 76, 179, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (79, 2124, 1, CAST(N'1997-02-18T21:04:13.0000000' AS DateTime2), 66, 160, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (80, 2125, 2, CAST(N'2004-12-27T21:04:13.0000000' AS DateTime2), 65, 184, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (81, 2126, 2, CAST(N'1995-03-23T21:04:13.0000000' AS DateTime2), 69, 169, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (82, 2127, 1, CAST(N'2003-06-11T21:04:13.0000000' AS DateTime2), 60, 163, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (83, 2128, 2, CAST(N'2005-07-27T21:04:13.0000000' AS DateTime2), 71, 174, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (84, 2129, 2, CAST(N'1996-11-01T21:04:13.0000000' AS DateTime2), 77, 180, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (85, 2130, 1, CAST(N'1996-01-30T21:04:13.0000000' AS DateTime2), 78, 173, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (86, 2131, 2, CAST(N'1983-04-01T21:04:13.0000000' AS DateTime2), 60, 175, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (87, 2132, 2, CAST(N'2002-07-29T21:04:13.0000000' AS DateTime2), 63, 161, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (88, 2133, 1, CAST(N'1981-01-04T21:04:13.0000000' AS DateTime2), 62, 161, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (89, 2134, 2, CAST(N'1997-01-04T21:04:13.0000000' AS DateTime2), 86, 183, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (90, 2135, 2, CAST(N'2001-03-13T21:04:13.0000000' AS DateTime2), 86, 163, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (91, 2136, 1, CAST(N'1982-09-20T21:04:13.0000000' AS DateTime2), 65, 184, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (92, 2137, 1, CAST(N'1991-10-06T21:04:13.0000000' AS DateTime2), 79, 161, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (93, 2138, 1, CAST(N'1996-04-15T21:04:13.0000000' AS DateTime2), 83, 174, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (94, 2139, 2, CAST(N'2004-04-09T21:04:13.0000000' AS DateTime2), 77, 168, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (95, 2140, 1, CAST(N'1991-02-02T21:04:13.0000000' AS DateTime2), 63, 171, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (96, 2141, 2, CAST(N'2006-07-23T21:04:13.0000000' AS DateTime2), 76, 181, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (97, 2142, 2, CAST(N'2005-06-05T21:04:13.0000000' AS DateTime2), 71, 183, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (98, 2143, 1, CAST(N'2002-12-20T21:04:13.0000000' AS DateTime2), 85, 180, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (99, 2144, 2, CAST(N'2004-09-24T21:04:13.0000000' AS DateTime2), 66, 172, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
GO
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (100, 2145, 2, CAST(N'1986-01-19T21:04:13.0000000' AS DateTime2), 81, 168, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (101, 2146, 2, CAST(N'2005-06-14T21:04:13.0000000' AS DateTime2), 85, 179, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (102, 2147, 2, CAST(N'1990-03-07T21:04:13.0000000' AS DateTime2), 62, 167, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (103, 2148, 1, CAST(N'1985-10-15T21:04:13.0000000' AS DateTime2), 75, 177, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (104, 2149, 1, CAST(N'1983-07-28T21:04:13.0000000' AS DateTime2), 68, 175, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (105, 2150, 2, CAST(N'1991-08-07T21:04:13.0000000' AS DateTime2), 67, 173, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (106, 2151, 2, CAST(N'2000-05-18T21:04:13.0000000' AS DateTime2), 70, 170, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
SET IDENTITY_INSERT [dbo].[Members] OFF
GO
SET IDENTITY_INSERT [dbo].[MemberViolations] ON 

INSERT [dbo].[MemberViolations] ([Id], [MemberId], [WarningCount], [IsSuspended], [LastWarningAt], [SuspendedAt], [Reason]) VALUES (1, 1, 0, 0, NULL, NULL, NULL)
INSERT [dbo].[MemberViolations] ([Id], [MemberId], [WarningCount], [IsSuspended], [LastWarningAt], [SuspendedAt], [Reason]) VALUES (2, 2, 2, 0, CAST(N'2026-03-11T16:00:49.0000000' AS DateTime2), NULL, N'近期連續取消兩次營養師預約，系統自動發出警告。')
INSERT [dbo].[MemberViolations] ([Id], [MemberId], [WarningCount], [IsSuspended], [LastWarningAt], [SuspendedAt], [Reason]) VALUES (3, 3, 4, 1, CAST(N'2026-03-09T16:00:49.0000000' AS DateTime2), CAST(N'2026-03-11T16:00:49.0000000' AS DateTime2), N'惡意留負評且多次未取貨，經管理員判定予以停權處分。')
SET IDENTITY_INSERT [dbo].[MemberViolations] OFF
GO
SET IDENTITY_INSERT [dbo].[Notifications] ON 

INSERT [dbo].[Notifications] ([Id], [UserId], [SenderId], [NotifyType], [Title], [Content], [IsRead], [ReferenceId], [CreatedAt]) VALUES (1, 1014, 2014, N'Report', N'【系統警示】評價檢舉通知', N'營養師 ins1 檢舉了一則不當評價，請盡速前往後台評價管理區審核。', 1, 3, CAST(N'2026-03-11T16:32:30.0000000' AS DateTime2))
INSERT [dbo].[Notifications] ([Id], [UserId], [SenderId], [NotifyType], [Title], [Content], [IsRead], [ReferenceId], [CreatedAt]) VALUES (2, 1, NULL, N'Booking', N'預約成功通知', N'親愛的 Alice Wang 您好，您已成功預約 2026-03-01 18-19 (晚) 的營養諮詢！', 0, 5, CAST(N'2026-03-11T16:32:30.0000000' AS DateTime2))
INSERT [dbo].[Notifications] ([Id], [UserId], [SenderId], [NotifyType], [Title], [Content], [IsRead], [ReferenceId], [CreatedAt]) VALUES (3, 1014, 2013, N'Report1', N'評論檢舉通知', N'不好看 [Url:/Review/AdminIndex?id=3]', 1, NULL, CAST(N'2026-03-11T17:20:37.0000000' AS DateTime2))
INSERT [dbo].[Notifications] ([Id], [UserId], [SenderId], [NotifyType], [Title], [Content], [IsRead], [ReferenceId], [CreatedAt]) VALUES (4, 2013, 2013, N'Report1', N'評論檢舉通知', N'不好看 [Url:/Review/AdminIndex?id=3]', 1, NULL, CAST(N'2026-03-11T17:20:37.0000000' AS DateTime2))
INSERT [dbo].[Notifications] ([Id], [UserId], [SenderId], [NotifyType], [Title], [Content], [IsRead], [ReferenceId], [CreatedAt]) VALUES (5, 1014, 2013, N'Report1', N'評論檢舉通知', N'1 [Url:/Review/AdminIndex?id=3]', 1, NULL, CAST(N'2026-03-12T15:26:37.0000000' AS DateTime2))
INSERT [dbo].[Notifications] ([Id], [UserId], [SenderId], [NotifyType], [Title], [Content], [IsRead], [ReferenceId], [CreatedAt]) VALUES (6, 2013, 2013, N'Report1', N'評論檢舉通知', N'1 [Url:/Review/AdminIndex?id=3]', 1, NULL, CAST(N'2026-03-12T15:26:37.0000000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Notifications] OFF
GO
SET IDENTITY_INSERT [dbo].[PointOrders] ON 

INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (1, 1, 3, CAST(N'2026-03-11T14:51:48.5266667' AS DateTime2), 5, CAST(5000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 2)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (2, 2, 2, CAST(N'2026-03-11T14:51:48.5266667' AS DateTime2), 2, CAST(2000 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 3)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (3, 22, 1, CAST(N'2026-02-21T11:05:25.6733333' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (4, 52, 2, CAST(N'2026-03-05T11:05:25.6733333' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (5, 55, 3, CAST(N'2026-02-22T11:05:25.6766667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (6, 81, 4, CAST(N'2026-03-04T11:05:25.6766667' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (7, 36, 2, CAST(N'2026-02-20T11:05:25.6766667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (8, 60, 5, CAST(N'2026-03-15T11:05:25.6766667' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (9, 10, 5, CAST(N'2026-02-28T11:05:25.6766667' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (10, 85, 3, CAST(N'2026-03-06T11:05:25.6800000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (11, 61, 1, CAST(N'2026-02-21T11:05:25.6800000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (12, 103, 5, CAST(N'2026-03-07T11:05:25.6800000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (13, 98, 1, CAST(N'2026-02-15T11:05:25.6800000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (14, 94, 1, CAST(N'2026-03-07T11:05:25.6800000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (15, 83, 3, CAST(N'2026-03-06T11:05:25.6800000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (16, 76, 4, CAST(N'2026-02-19T11:05:25.6800000' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (17, 36, 2, CAST(N'2026-02-24T11:05:25.6800000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (18, 56, 2, CAST(N'2026-02-17T11:05:25.6833333' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (19, 34, 3, CAST(N'2026-02-24T11:05:25.6833333' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (20, 59, 4, CAST(N'2026-02-22T11:05:25.6833333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (21, 63, 1, CAST(N'2026-03-08T11:05:25.6833333' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (22, 68, 5, CAST(N'2026-03-03T11:05:25.6833333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (23, 86, 3, CAST(N'2026-03-01T11:53:44.5166667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (24, 27, 3, CAST(N'2026-02-26T11:53:44.5166667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (25, 81, 2, CAST(N'2026-02-18T11:53:44.5200000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (26, 74, 3, CAST(N'2026-03-13T11:53:44.5200000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (27, 81, 3, CAST(N'2026-02-23T11:53:44.5200000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (28, 29, 4, CAST(N'2026-02-26T11:53:44.5200000' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (29, 55, 3, CAST(N'2026-03-09T11:53:44.5200000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (30, 42, 1, CAST(N'2026-03-10T11:53:44.5200000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (31, 57, 1, CAST(N'2026-02-23T11:53:44.5200000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (32, 81, 2, CAST(N'2026-02-20T11:53:44.5200000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (33, 17, 3, CAST(N'2026-03-04T11:53:44.5200000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (34, 88, 1, CAST(N'2026-03-08T11:53:44.5200000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (35, 1, 1, CAST(N'2026-03-06T11:53:44.5200000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (36, 95, 5, CAST(N'2026-02-22T11:53:44.5200000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (37, 22, 2, CAST(N'2026-03-08T11:53:44.5200000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (38, 100, 5, CAST(N'2026-03-08T11:53:44.5233333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (39, 11, 3, CAST(N'2026-02-24T11:53:44.5233333' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (40, 97, 5, CAST(N'2026-03-13T11:53:44.5233333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (41, 35, 2, CAST(N'2026-02-27T11:53:44.5233333' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (42, 56, 5, CAST(N'2026-02-24T11:53:44.5233333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (43, 49, 1, CAST(N'2026-02-23T08:50:12.9233333' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (44, 22, 3, CAST(N'2026-03-02T04:15:12.9266667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (45, 48, 3, CAST(N'2026-02-18T12:27:12.9300000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (46, 80, 5, CAST(N'2026-02-15T20:19:12.9300000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (47, 36, 5, CAST(N'2026-02-23T14:05:12.9300000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (48, 75, 3, CAST(N'2026-02-21T21:01:12.9300000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (49, 106, 3, CAST(N'2026-02-22T01:12:12.9300000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (50, 21, 4, CAST(N'2026-03-12T13:47:12.9300000' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (51, 90, 4, CAST(N'2026-02-18T22:42:12.9333333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (52, 99, 4, CAST(N'2026-03-14T14:52:12.9333333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (53, 40, 2, CAST(N'2026-03-15T05:50:12.9333333' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (54, 55, 2, CAST(N'2026-03-15T07:51:12.9333333' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (55, 45, 4, CAST(N'2026-03-02T10:47:12.9333333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (56, 60, 4, CAST(N'2026-03-15T19:46:12.9333333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (57, 77, 1, CAST(N'2026-02-23T23:55:12.9366667' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (58, 71, 3, CAST(N'2026-02-16T05:56:12.9366667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (59, 13, 2, CAST(N'2026-02-18T07:12:12.9366667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (60, 57, 1, CAST(N'2026-02-16T05:27:12.9366667' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (61, 57, 2, CAST(N'2026-03-06T17:55:12.9366667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (62, 75, 5, CAST(N'2026-02-24T01:16:12.9366667' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (63, 71, 5, CAST(N'2026-02-15T02:17:12.9366667' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (64, 102, 2, CAST(N'2026-03-07T21:24:12.9400000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (65, 83, 2, CAST(N'2026-03-01T10:50:12.9400000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (66, 33, 3, CAST(N'2026-03-12T00:22:12.9400000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (67, 20, 1, CAST(N'2026-03-12T14:52:12.9400000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (68, 64, 2, CAST(N'2026-03-04T23:22:12.9400000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (69, 103, 5, CAST(N'2026-03-09T07:10:12.9400000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (70, 42, 1, CAST(N'2026-03-08T18:00:12.9400000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (71, 66, 1, CAST(N'2026-03-10T09:42:12.9400000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (72, 1, 2, CAST(N'2026-02-17T12:19:12.9400000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (73, 43, 5, CAST(N'2026-02-23T06:54:12.9433333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (74, 30, 4, CAST(N'2026-02-21T13:43:12.9433333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (75, 10, 5, CAST(N'2026-02-18T04:31:12.9433333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (76, 34, 1, CAST(N'2026-03-02T17:49:12.9433333' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (77, 60, 4, CAST(N'2026-03-09T19:34:12.9433333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (78, 29, 2, CAST(N'2026-02-18T04:39:12.9433333' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (79, 52, 5, CAST(N'2026-03-13T12:44:12.9433333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (80, 32, 3, CAST(N'2026-03-08T15:19:12.9466667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (81, 71, 5, CAST(N'2026-03-14T01:51:12.9466667' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (82, 58, 5, CAST(N'2026-03-09T11:15:12.9466667' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (83, 46, 4, CAST(N'2026-03-15T20:01:12.9466667' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (84, 75, 5, CAST(N'2026-03-03T09:22:12.9466667' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (85, 71, 1, CAST(N'2026-03-04T05:23:12.9466667' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (86, 75, 1, CAST(N'2026-03-15T06:06:12.9466667' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (87, 57, 4, CAST(N'2026-03-02T14:53:12.9500000' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (88, 12, 2, CAST(N'2026-03-04T21:00:12.9500000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (89, 29, 3, CAST(N'2026-02-28T03:47:12.9500000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (90, 52, 3, CAST(N'2026-02-24T17:24:12.9500000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (91, 100, 3, CAST(N'2026-02-23T22:02:12.9500000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (92, 70, 1, CAST(N'2026-03-07T05:47:12.9500000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (93, 47, 5, CAST(N'2026-03-08T06:50:12.9500000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (94, 49, 1, CAST(N'2026-02-23T22:30:12.9500000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (95, 72, 2, CAST(N'2026-03-16T05:58:12.9500000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (96, 18, 5, CAST(N'2026-03-09T13:29:12.9500000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (97, 105, 3, CAST(N'2026-03-07T17:29:12.9533333' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (98, 20, 4, CAST(N'2026-03-05T12:52:12.9533333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (99, 35, 4, CAST(N'2026-02-19T17:51:12.9533333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
GO
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (100, 78, 1, CAST(N'2026-03-11T11:16:12.9533333' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (101, 43, 4, CAST(N'2026-03-01T13:35:12.9533333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (102, 92, 5, CAST(N'2026-02-14T21:57:12.9533333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (103, 63, 3, CAST(N'2026-02-26T02:50:12.9533333' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (104, 46, 3, CAST(N'2026-02-28T12:06:12.9533333' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (105, 61, 3, CAST(N'2026-02-27T12:22:12.9566667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (106, 40, 4, CAST(N'2026-02-21T01:54:12.9566667' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (107, 25, 2, CAST(N'2026-03-10T01:50:12.9566667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (108, 106, 2, CAST(N'2026-03-05T11:28:12.9566667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (109, 75, 4, CAST(N'2026-03-14T10:07:12.9566667' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (110, 38, 5, CAST(N'2026-03-09T07:07:12.9566667' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (111, 15, 3, CAST(N'2026-02-24T03:07:12.9566667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (112, 46, 2, CAST(N'2026-03-05T16:06:12.9600000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (113, 58, 1, CAST(N'2026-03-15T00:53:12.9600000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (114, 86, 1, CAST(N'2026-03-02T22:38:12.9600000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (115, 52, 2, CAST(N'2026-02-15T03:41:12.9600000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (116, 105, 1, CAST(N'2026-03-08T08:59:12.9600000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (117, 50, 2, CAST(N'2026-02-26T05:25:12.9600000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (118, 67, 5, CAST(N'2026-03-02T07:58:12.9600000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (119, 52, 5, CAST(N'2026-02-27T13:42:12.9600000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (120, 46, 2, CAST(N'2026-02-23T07:13:12.9600000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (121, 81, 1, CAST(N'2026-02-20T16:35:12.9600000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (122, 46, 2, CAST(N'2026-03-11T18:45:12.9633333' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (123, 80, 5, CAST(N'2026-03-01T07:26:12.9633333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (124, 78, 3, CAST(N'2026-03-13T21:37:12.9633333' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (125, 91, 5, CAST(N'2026-03-12T07:32:12.9633333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (126, 15, 1, CAST(N'2026-03-12T00:15:12.9633333' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (127, 18, 5, CAST(N'2026-02-19T23:30:12.9633333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (128, 50, 4, CAST(N'2026-03-14T10:49:12.9633333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (129, 77, 2, CAST(N'2026-02-16T05:43:12.9666667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (130, 103, 2, CAST(N'2026-03-08T06:49:12.9666667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (131, 32, 2, CAST(N'2026-02-22T04:44:12.9666667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (132, 18, 3, CAST(N'2026-02-23T21:13:12.9666667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (133, 14, 2, CAST(N'2026-03-15T01:53:12.9666667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (134, 49, 4, CAST(N'2026-02-28T19:43:12.9666667' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (135, 85, 2, CAST(N'2026-03-05T23:20:12.9666667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (136, 93, 2, CAST(N'2026-03-04T08:11:12.9666667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (137, 78, 4, CAST(N'2026-02-19T22:02:12.9700000' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (138, 91, 2, CAST(N'2026-03-03T06:28:12.9700000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (139, 62, 5, CAST(N'2026-02-25T14:55:12.9700000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (140, 90, 4, CAST(N'2026-03-08T07:11:12.9700000' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (141, 8, 1, CAST(N'2026-03-06T09:53:12.9700000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (142, 97, 5, CAST(N'2026-03-09T10:03:12.9700000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (143, 2, 1, CAST(N'2026-03-03T06:02:38.7233333' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (144, 7, 5, CAST(N'2026-03-02T07:10:38.7233333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (145, 9, 5, CAST(N'2026-03-10T19:34:38.7266667' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (146, 16, 2, CAST(N'2026-02-24T22:03:38.7266667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (147, 19, 3, CAST(N'2026-03-14T20:19:38.7266667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (148, 23, 3, CAST(N'2026-02-15T08:57:38.7266667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (149, 24, 3, CAST(N'2026-03-09T08:47:38.7266667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (150, 26, 5, CAST(N'2026-02-21T22:12:38.7266667' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (151, 28, 4, CAST(N'2026-03-15T03:38:38.7300000' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (152, 31, 1, CAST(N'2026-02-20T05:18:38.7300000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (153, 37, 1, CAST(N'2026-03-03T23:03:38.7300000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (154, 39, 4, CAST(N'2026-03-01T22:52:38.7300000' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (155, 41, 4, CAST(N'2026-03-16T09:55:38.7300000' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (156, 44, 5, CAST(N'2026-03-12T23:19:38.7300000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (157, 51, 3, CAST(N'2026-03-10T02:23:38.7300000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (158, 53, 3, CAST(N'2026-02-25T04:46:38.7300000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (159, 54, 1, CAST(N'2026-03-04T01:46:38.7300000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (160, 65, 3, CAST(N'2026-03-01T02:32:38.7300000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (161, 69, 5, CAST(N'2026-02-28T03:08:38.7300000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (162, 73, 3, CAST(N'2026-03-12T17:55:38.7333333' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (163, 79, 3, CAST(N'2026-02-16T18:12:38.7333333' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (164, 82, 2, CAST(N'2026-03-16T01:35:38.7333333' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (165, 84, 1, CAST(N'2026-03-12T05:21:38.7333333' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (166, 87, 4, CAST(N'2026-03-13T11:47:38.7333333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (167, 89, 5, CAST(N'2026-03-12T07:10:38.7333333' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (168, 96, 3, CAST(N'2026-03-12T07:15:38.7333333' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (169, 101, 4, CAST(N'2026-02-22T13:53:38.7333333' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (170, 104, 1, CAST(N'2026-02-19T12:53:38.7333333' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (171, 105, 5, CAST(N'2026-02-23T09:20:38.7366667' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (172, 28, 4, CAST(N'2026-03-01T15:03:38.7366667' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (173, 54, 2, CAST(N'2026-02-28T08:37:38.7366667' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (174, 25, 5, CAST(N'2026-02-27T16:08:38.7366667' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (175, 88, 3, CAST(N'2026-03-09T15:37:38.7366667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (176, 85, 1, CAST(N'2026-02-26T19:08:38.7366667' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (177, 27, 3, CAST(N'2026-03-03T01:22:38.7366667' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (178, 60, 4, CAST(N'2026-02-25T18:36:38.7366667' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (179, 35, 5, CAST(N'2026-02-28T05:56:38.7400000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (180, 9, 5, CAST(N'2026-02-21T04:04:38.7400000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (181, 50, 1, CAST(N'2026-03-08T23:24:38.7400000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (182, 42, 1, CAST(N'2026-03-11T19:02:38.7400000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (183, 26, 2, CAST(N'2026-03-12T09:17:38.7400000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (184, 36, 2, CAST(N'2026-02-23T09:58:38.7400000' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (185, 9, 5, CAST(N'2026-03-03T00:43:38.7400000' AS DateTime2), 20, CAST(12000 AS Decimal(18, 0)), CAST(12000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (186, 56, 1, CAST(N'2026-03-11T16:26:38.7400000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (187, 101, 1, CAST(N'2026-03-11T20:27:38.7400000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (188, 61, 3, CAST(N'2026-03-12T03:24:38.7400000' AS DateTime2), 5, CAST(4000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (189, 73, 1, CAST(N'2026-03-12T16:11:38.7400000' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (190, 56, 4, CAST(N'2026-03-14T08:03:38.7400000' AS DateTime2), 10, CAST(7000 AS Decimal(18, 0)), CAST(7000 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (191, 21, 2, CAST(N'2026-02-27T10:18:38.7433333' AS DateTime2), 2, CAST(1800 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 1)
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (192, 53, 1, CAST(N'2026-02-26T21:03:38.7433333' AS DateTime2), 1, CAST(1000 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), 1)
SET IDENTITY_INSERT [dbo].[PointOrders] OFF
GO
SET IDENTITY_INSERT [dbo].[PointsRecordDetails] ON 

INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (1, 3, 18, CAST(N'2026-02-21T11:05:26.0000000' AS DateTime2), 1, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (2, 4, 48, CAST(N'2026-03-05T11:05:26.0000000' AS DateTime2), 2, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (3, 5, 51, CAST(N'2026-02-22T11:05:26.0000000' AS DateTime2), 5, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (4, 6, 77, CAST(N'2026-03-04T11:05:26.0000000' AS DateTime2), 10, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (5, 7, 32, CAST(N'2026-02-20T11:05:26.0000000' AS DateTime2), 2, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (6, 8, 56, CAST(N'2026-03-15T11:05:26.0000000' AS DateTime2), 20, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (7, 9, 6, CAST(N'2026-02-28T11:05:26.0000000' AS DateTime2), 20, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (8, 10, 81, CAST(N'2026-03-06T11:05:26.0000000' AS DateTime2), 5, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (9, 11, 57, CAST(N'2026-02-21T11:05:26.0000000' AS DateTime2), 1, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (10, 12, 99, CAST(N'2026-03-07T11:05:26.0000000' AS DateTime2), 20, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (11, 13, 94, CAST(N'2026-02-15T11:05:26.0000000' AS DateTime2), 1, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (12, 14, 90, CAST(N'2026-03-07T11:05:26.0000000' AS DateTime2), 1, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (13, 15, 79, CAST(N'2026-03-06T11:05:26.0000000' AS DateTime2), 5, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (14, 16, 72, CAST(N'2026-02-19T11:05:26.0000000' AS DateTime2), 10, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (15, 17, 32, CAST(N'2026-02-24T11:05:26.0000000' AS DateTime2), 2, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (16, 18, 52, CAST(N'2026-02-17T11:05:26.0000000' AS DateTime2), 2, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (17, 19, 30, CAST(N'2026-02-24T11:05:26.0000000' AS DateTime2), 5, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (18, 20, 55, CAST(N'2026-02-22T11:05:26.0000000' AS DateTime2), 10, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (19, 21, 59, CAST(N'2026-03-08T11:05:26.0000000' AS DateTime2), 1, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (20, 22, 64, CAST(N'2026-03-03T11:05:26.0000000' AS DateTime2), 20, N'儲值', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (21, 23, 82, CAST(N'2026-03-01T11:53:45.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (22, 24, 23, CAST(N'2026-02-26T11:53:45.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (23, 25, 77, CAST(N'2026-02-18T11:53:45.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (24, 26, 70, CAST(N'2026-03-13T11:53:45.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (25, 27, 77, CAST(N'2026-02-23T11:53:45.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (26, 28, 25, CAST(N'2026-02-26T11:53:45.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (27, 29, 51, CAST(N'2026-03-09T11:53:45.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (28, 30, 38, CAST(N'2026-03-10T11:53:45.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (29, 31, 53, CAST(N'2026-02-23T11:53:45.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (30, 32, 77, CAST(N'2026-02-20T11:53:45.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (31, 33, 13, CAST(N'2026-03-04T11:53:45.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (32, 34, 84, CAST(N'2026-03-08T11:53:45.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (33, 35, 1, CAST(N'2026-03-06T11:53:45.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (34, 36, 91, CAST(N'2026-02-22T11:53:45.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (35, 37, 18, CAST(N'2026-03-08T11:53:45.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (36, 38, 96, CAST(N'2026-03-08T11:53:45.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (37, 39, 7, CAST(N'2026-02-24T11:53:45.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (38, 40, 93, CAST(N'2026-03-13T11:53:45.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (39, 41, 31, CAST(N'2026-02-27T11:53:45.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (40, 42, 52, CAST(N'2026-02-24T11:53:45.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (41, 43, 45, CAST(N'2026-02-23T08:50:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (42, 44, 18, CAST(N'2026-03-02T04:15:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (43, 45, 44, CAST(N'2026-02-18T12:27:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (44, 46, 76, CAST(N'2026-02-15T20:19:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (45, 47, 32, CAST(N'2026-02-23T14:05:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (46, 48, 71, CAST(N'2026-02-21T21:01:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (47, 49, 102, CAST(N'2026-02-22T01:12:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (48, 50, 17, CAST(N'2026-03-12T13:47:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (49, 51, 86, CAST(N'2026-02-18T22:42:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (50, 52, 95, CAST(N'2026-03-14T14:52:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (51, 53, 36, CAST(N'2026-03-15T05:50:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (52, 54, 51, CAST(N'2026-03-15T07:51:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (53, 55, 41, CAST(N'2026-03-02T10:47:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (54, 56, 56, CAST(N'2026-03-15T19:46:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (55, 57, 73, CAST(N'2026-02-23T23:55:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (56, 58, 67, CAST(N'2026-02-16T05:56:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (57, 59, 9, CAST(N'2026-02-18T07:12:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (58, 60, 53, CAST(N'2026-02-16T05:27:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (59, 61, 53, CAST(N'2026-03-06T17:55:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (60, 62, 71, CAST(N'2026-02-24T01:16:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (61, 63, 67, CAST(N'2026-02-15T02:17:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (62, 64, 98, CAST(N'2026-03-07T21:24:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (63, 65, 79, CAST(N'2026-03-01T10:50:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (64, 66, 29, CAST(N'2026-03-12T00:22:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (65, 67, 16, CAST(N'2026-03-12T14:52:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (66, 68, 60, CAST(N'2026-03-04T23:22:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (67, 69, 99, CAST(N'2026-03-09T07:10:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (68, 70, 38, CAST(N'2026-03-08T18:00:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (69, 71, 62, CAST(N'2026-03-10T09:42:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (70, 72, 1, CAST(N'2026-02-17T12:19:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (71, 73, 39, CAST(N'2026-02-23T06:54:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (72, 74, 26, CAST(N'2026-02-21T13:43:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (73, 75, 6, CAST(N'2026-02-18T04:31:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (74, 76, 30, CAST(N'2026-03-02T17:49:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (75, 77, 56, CAST(N'2026-03-09T19:34:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (76, 78, 25, CAST(N'2026-02-18T04:39:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (77, 79, 48, CAST(N'2026-03-13T12:44:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (78, 80, 28, CAST(N'2026-03-08T15:19:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (79, 81, 67, CAST(N'2026-03-14T01:51:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (80, 82, 54, CAST(N'2026-03-09T11:15:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (81, 83, 42, CAST(N'2026-03-15T20:01:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (82, 84, 71, CAST(N'2026-03-03T09:22:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (83, 85, 67, CAST(N'2026-03-04T05:23:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (84, 86, 71, CAST(N'2026-03-15T06:06:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (85, 87, 53, CAST(N'2026-03-02T14:53:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (86, 88, 8, CAST(N'2026-03-04T21:00:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (87, 89, 25, CAST(N'2026-02-28T03:47:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (88, 90, 48, CAST(N'2026-02-24T17:24:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (89, 91, 96, CAST(N'2026-02-23T22:02:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (90, 92, 66, CAST(N'2026-03-07T05:47:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (91, 93, 43, CAST(N'2026-03-08T06:50:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (92, 94, 45, CAST(N'2026-02-23T22:30:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (93, 95, 68, CAST(N'2026-03-16T05:58:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (94, 96, 14, CAST(N'2026-03-09T13:29:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (95, 97, 101, CAST(N'2026-03-07T17:29:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (96, 98, 16, CAST(N'2026-03-05T12:52:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (97, 99, 31, CAST(N'2026-02-19T17:51:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (98, 100, 74, CAST(N'2026-03-11T11:16:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (99, 101, 39, CAST(N'2026-03-01T13:35:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
GO
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (100, 102, 88, CAST(N'2026-02-14T21:57:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (101, 103, 59, CAST(N'2026-02-26T02:50:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (102, 104, 42, CAST(N'2026-02-28T12:06:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (103, 105, 57, CAST(N'2026-02-27T12:22:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (104, 106, 36, CAST(N'2026-02-21T01:54:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (105, 107, 21, CAST(N'2026-03-10T01:50:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (106, 108, 102, CAST(N'2026-03-05T11:28:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (107, 109, 71, CAST(N'2026-03-14T10:07:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (108, 110, 34, CAST(N'2026-03-09T07:07:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (109, 111, 11, CAST(N'2026-02-24T03:07:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (110, 112, 42, CAST(N'2026-03-05T16:06:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (111, 113, 54, CAST(N'2026-03-15T00:53:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (112, 114, 82, CAST(N'2026-03-02T22:38:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (113, 115, 48, CAST(N'2026-02-15T03:41:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (114, 116, 101, CAST(N'2026-03-08T08:59:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (115, 117, 46, CAST(N'2026-02-26T05:25:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (116, 118, 63, CAST(N'2026-03-02T07:58:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (117, 119, 48, CAST(N'2026-02-27T13:42:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (118, 120, 42, CAST(N'2026-02-23T07:13:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (119, 121, 77, CAST(N'2026-02-20T16:35:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (120, 122, 42, CAST(N'2026-03-11T18:45:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (121, 123, 76, CAST(N'2026-03-01T07:26:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (122, 124, 74, CAST(N'2026-03-13T21:37:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (123, 125, 87, CAST(N'2026-03-12T07:32:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (124, 126, 11, CAST(N'2026-03-12T00:15:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (125, 127, 14, CAST(N'2026-02-19T23:30:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (126, 128, 46, CAST(N'2026-03-14T10:49:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (127, 129, 73, CAST(N'2026-02-16T05:43:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (128, 130, 99, CAST(N'2026-03-08T06:49:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (129, 131, 28, CAST(N'2026-02-22T04:44:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (130, 132, 14, CAST(N'2026-02-23T21:13:13.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (131, 133, 10, CAST(N'2026-03-15T01:53:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (132, 134, 45, CAST(N'2026-02-28T19:43:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (133, 135, 81, CAST(N'2026-03-05T23:20:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (134, 136, 89, CAST(N'2026-03-04T08:11:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (135, 137, 74, CAST(N'2026-02-19T22:02:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (136, 138, 87, CAST(N'2026-03-03T06:28:13.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (137, 139, 58, CAST(N'2026-02-25T14:55:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (138, 140, 86, CAST(N'2026-03-08T07:11:13.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (139, 141, 4, CAST(N'2026-03-06T09:53:13.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (140, 142, 93, CAST(N'2026-03-09T10:03:13.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (141, 143, 2, CAST(N'2026-03-03T06:02:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (142, 144, 3, CAST(N'2026-03-02T07:10:39.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (143, 145, 5, CAST(N'2026-03-10T19:34:39.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (144, 146, 12, CAST(N'2026-02-24T22:03:39.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (145, 147, 15, CAST(N'2026-03-14T20:19:39.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (146, 148, 19, CAST(N'2026-02-15T08:57:39.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (147, 149, 20, CAST(N'2026-03-09T08:47:39.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (148, 150, 22, CAST(N'2026-02-21T22:12:39.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (149, 151, 24, CAST(N'2026-03-15T03:38:39.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (150, 152, 27, CAST(N'2026-02-20T05:18:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (151, 153, 33, CAST(N'2026-03-03T23:03:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (152, 154, 35, CAST(N'2026-03-01T22:52:39.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (153, 155, 37, CAST(N'2026-03-16T09:55:39.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (154, 156, 40, CAST(N'2026-03-12T23:19:39.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (155, 157, 47, CAST(N'2026-03-10T02:23:39.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (156, 158, 49, CAST(N'2026-02-25T04:46:39.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (157, 159, 50, CAST(N'2026-03-04T01:46:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (158, 160, 61, CAST(N'2026-03-01T02:32:39.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (159, 161, 65, CAST(N'2026-02-28T03:08:39.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (160, 162, 69, CAST(N'2026-03-12T17:55:39.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (161, 163, 75, CAST(N'2026-02-16T18:12:39.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (162, 164, 78, CAST(N'2026-03-16T01:35:39.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (163, 165, 80, CAST(N'2026-03-12T05:21:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (164, 166, 83, CAST(N'2026-03-13T11:47:39.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (165, 167, 85, CAST(N'2026-03-12T07:10:39.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (166, 168, 92, CAST(N'2026-03-12T07:15:39.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (167, 169, 97, CAST(N'2026-02-22T13:53:39.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (168, 170, 100, CAST(N'2026-02-19T12:53:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (169, 171, 101, CAST(N'2026-02-23T09:20:39.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (170, 172, 24, CAST(N'2026-03-01T15:03:39.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (171, 173, 50, CAST(N'2026-02-28T08:37:39.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (172, 174, 21, CAST(N'2026-02-27T16:08:39.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (173, 175, 84, CAST(N'2026-03-09T15:37:39.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (174, 176, 81, CAST(N'2026-02-26T19:08:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (175, 177, 23, CAST(N'2026-03-03T01:22:39.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (176, 178, 56, CAST(N'2026-02-25T18:36:39.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (177, 179, 31, CAST(N'2026-02-28T05:56:39.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (178, 180, 5, CAST(N'2026-02-21T04:04:39.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (179, 181, 46, CAST(N'2026-03-08T23:24:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (180, 182, 38, CAST(N'2026-03-11T19:02:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (181, 183, 22, CAST(N'2026-03-12T09:17:39.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (182, 184, 32, CAST(N'2026-02-23T09:58:39.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (183, 185, 5, CAST(N'2026-03-03T00:43:39.0000000' AS DateTime2), 20, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (184, 186, 52, CAST(N'2026-03-11T16:26:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (185, 187, 97, CAST(N'2026-03-11T20:27:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (186, 188, 57, CAST(N'2026-03-12T03:24:39.0000000' AS DateTime2), 5, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (187, 189, 69, CAST(N'2026-03-12T16:11:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (188, 190, 52, CAST(N'2026-03-14T08:03:39.0000000' AS DateTime2), 10, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (189, 191, 17, CAST(N'2026-02-27T10:18:39.0000000' AS DateTime2), 2, N'Recharge', NULL)
INSERT [dbo].[PointsRecordDetails] ([Id], [PointOrderId], [UserWalletId], [CreateAt], [PointAmount], [MerchandiseCategory], [ReserveOrderId]) VALUES (190, 192, 49, CAST(N'2026-02-26T21:03:39.0000000' AS DateTime2), 1, N'Recharge', NULL)
SET IDENTITY_INSERT [dbo].[PointsRecordDetails] OFF
GO
SET IDENTITY_INSERT [dbo].[ProductCategories] ON 

INSERT [dbo].[ProductCategories] ([Id], [CategoryName], [SortOrder], [IsActive]) VALUES (1, N'雞胸肉', 1, 1)
INSERT [dbo].[ProductCategories] ([Id], [CategoryName], [SortOrder], [IsActive]) VALUES (2, N'蛋白粉', 2, 1)
INSERT [dbo].[ProductCategories] ([Id], [CategoryName], [SortOrder], [IsActive]) VALUES (3, N'各種維生素', 3, 1)
INSERT [dbo].[ProductCategories] ([Id], [CategoryName], [SortOrder], [IsActive]) VALUES (4, N'便當盒', 4, 1)
SET IDENTITY_INSERT [dbo].[ProductCategories] OFF
GO
SET IDENTITY_INSERT [dbo].[ProductOrderDetails] ON 

INSERT [dbo].[ProductOrderDetails] ([Id], [ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo]) VALUES (1, 1, 1, CAST(99 AS Decimal(18, 0)), 2, CAST(198 AS Decimal(18, 0)), CAST(198 AS Decimal(18, 0)), N'經典原味舒肥雞胸肉', N'/images/products/chicken_01.jpg', N'請幫我用紙箱包裝')
INSERT [dbo].[ProductOrderDetails] ([Id], [ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo]) VALUES (2, 1, 9, CAST(1200 AS Decimal(18, 0)), 1, CAST(1200 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), N'濃縮乳清蛋白 - 醇厚巧克力', N'/images/products/protein_01.jpg', NULL)
INSERT [dbo].[ProductOrderDetails] ([Id], [ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo]) VALUES (3, 2, 17, CAST(450 AS Decimal(18, 0)), 1, CAST(450 AS Decimal(18, 0)), CAST(450 AS Decimal(18, 0)), N'高單位活力B群', N'/images/products/vitamin_01.jpg', NULL)
INSERT [dbo].[ProductOrderDetails] ([Id], [ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo]) VALUES (4, 2, 24, CAST(350 AS Decimal(18, 0)), 2, CAST(700 AS Decimal(18, 0)), CAST(650 AS Decimal(18, 0)), N'304不鏽鋼分隔便當盒', N'/images/products/box_01.jpg', N'送禮用，請確認無刮痕')
INSERT [dbo].[ProductOrderDetails] ([Id], [ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo]) VALUES (5, 1, 6, CAST(109 AS Decimal(18, 0)), 3, CAST(327 AS Decimal(18, 0)), CAST(327 AS Decimal(18, 0)), N'川味麻辣雞胸肉', N'/images/products/chicken_06.jpg', NULL)
SET IDENTITY_INSERT [dbo].[ProductOrderDetails] OFF
GO
SET IDENTITY_INSERT [dbo].[ProductOrders] ON 

INSERT [dbo].[ProductOrders] ([Id], [MemberId], [CreateAt], [OriginalAmount], [DiscountAmount], [Receiver], [Address], [Mobile], [TaxNumber], [Status], [Memo]) VALUES (1, 1, CAST(N'2026-03-11T14:51:48.5233333' AS DateTime2), CAST(2000 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), N'陳小明', N'台北市信義區', N'0912345678', NULL, 1, NULL)
INSERT [dbo].[ProductOrders] ([Id], [MemberId], [CreateAt], [OriginalAmount], [DiscountAmount], [Receiver], [Address], [Mobile], [TaxNumber], [Status], [Memo]) VALUES (2, 2, CAST(N'2026-03-11T14:51:48.5266667' AS DateTime2), CAST(1500 AS Decimal(18, 0)), CAST(1500 AS Decimal(18, 0)), N'王大同', N'台北市大安區', N'0987654321', NULL, 5, NULL)
SET IDENTITY_INSERT [dbo].[ProductOrders] OFF
GO
SET IDENTITY_INSERT [dbo].[Products] ON 

INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (1, 1, N'經典原味舒肥雞胸肉', N'/images/products/chicken_01.jpg', CAST(120 AS Decimal(18, 0)), CAST(99 AS Decimal(18, 0)), N'鮮嫩多汁，低脂高蛋白，無過多調味', 1, 0)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (2, 1, N'黑胡椒海鹽雞胸肉', N'/images/products/chicken_02.jpg', CAST(120 AS Decimal(18, 0)), CAST(99 AS Decimal(18, 0)), N'使用天然海鹽與粗粒黑胡椒，經典百搭', 2, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (3, 1, N'蒜香風味雞胸肉', N'/images/products/chicken_03.jpg', CAST(120 AS Decimal(18, 0)), CAST(99 AS Decimal(18, 0)), N'濃郁蒜香，健身後補充的最佳首選', 3, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (4, 1, N'泰式檸檬雞胸肉', N'/images/products/chicken_04.jpg', CAST(130 AS Decimal(18, 0)), CAST(109 AS Decimal(18, 0)), N'微酸微辣，清爽解膩的泰式風味', 4, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (5, 1, N'印度咖哩雞胸肉', N'/images/products/chicken_05.jpg', CAST(130 AS Decimal(18, 0)), CAST(109 AS Decimal(18, 0)), N'濃郁咖哩香氣，異國風味口感豐富', 5, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (6, 1, N'川味麻辣雞胸肉', N'/images/products/chicken_06.jpg', CAST(130 AS Decimal(18, 0)), CAST(109 AS Decimal(18, 0)), N'嗜辣者必備，刺激味蕾好下飯', 6, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (7, 1, N'義式香草雞胸肉', N'/images/products/chicken_07.jpg', CAST(140 AS Decimal(18, 0)), CAST(119 AS Decimal(18, 0)), N'特選義式綜合香料醃製，香氣四溢', 7, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (8, 1, N'迷迭香烤雞胸肉', N'/images/products/chicken_08.jpg', CAST(140 AS Decimal(18, 0)), CAST(119 AS Decimal(18, 0)), N'高級餐廳等級口感，在家也能輕鬆享受', 8, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (9, 2, N'濃縮乳清蛋白 - 醇厚巧克力', N'/images/products/protein_01.jpg', CAST(1500 AS Decimal(18, 0)), CAST(1200 AS Decimal(18, 0)), N'每份含25g蛋白質，濃郁可可風味', 1, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (10, 2, N'濃縮乳清蛋白 - 經典香草', N'/images/products/protein_02.jpg', CAST(1500 AS Decimal(18, 0)), CAST(1200 AS Decimal(18, 0)), N'百搭香草風味，適合搭配牛奶或燕麥', 2, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (11, 2, N'分離乳清蛋白 - 鮮採草莓', N'/images/products/protein_03.jpg', CAST(1800 AS Decimal(18, 0)), CAST(1450 AS Decimal(18, 0)), N'乳糖不耐症適用，酸甜草莓口感', 3, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (12, 2, N'分離乳清蛋白 - 英式奶茶', N'/images/products/protein_04.jpg', CAST(1800 AS Decimal(18, 0)), CAST(1450 AS Decimal(18, 0)), N'超人氣奶茶口味，享受喝手搖飲的快感', 4, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (13, 2, N'緩釋型酪蛋白 - 原味', N'/images/products/protein_05.jpg', CAST(1600 AS Decimal(18, 0)), CAST(1300 AS Decimal(18, 0)), N'緩慢釋放胺基酸，睡前補充最佳選擇', 5, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (14, 2, N'純素大豆分離蛋白 - 抹茶', N'/images/products/protein_06.jpg', CAST(1400 AS Decimal(18, 0)), CAST(1100 AS Decimal(18, 0)), N'素食者健身必備，日式靜岡抹茶風味', 6, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (15, 2, N'綜合植物蛋白粉 - 芝麻', N'/images/products/protein_07.jpg', CAST(1450 AS Decimal(18, 0)), CAST(1150 AS Decimal(18, 0)), N'富含多種植物性胺基酸，濃郁芝麻香', 7, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (16, 2, N'高蛋白能量代餐飲 - 香蕉', N'/images/products/protein_08.jpg', CAST(1200 AS Decimal(18, 0)), CAST(990 AS Decimal(18, 0)), N'富含飽足感，減脂期代餐好幫手', 8, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (17, 3, N'高單位活力B群', N'/images/products/vitamin_01.jpg', CAST(600 AS Decimal(18, 0)), CAST(450 AS Decimal(18, 0)), N'增強體力，精神旺盛，運動後恢復必備', 1, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (18, 3, N'維生素C1000發泡錠', N'/images/products/vitamin_02.jpg', CAST(350 AS Decimal(18, 0)), CAST(280 AS Decimal(18, 0)), N'酸甜好喝，日常保養與促進膠原蛋白形成', 2, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (19, 3, N'陽光維生素D3軟膠囊', N'/images/products/vitamin_03.jpg', CAST(500 AS Decimal(18, 0)), CAST(390 AS Decimal(18, 0)), N'室內族必備，促進鈣質吸收', 3, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (20, 3, N'綜合礦物質複方錠', N'/images/products/vitamin_04.jpg', CAST(800 AS Decimal(18, 0)), CAST(650 AS Decimal(18, 0)), N'一次補充多種流汗流失的必需礦物質', 4, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (21, 3, N'高濃度深海魚油 Omega-3', N'/images/products/vitamin_05.jpg', CAST(1200 AS Decimal(18, 0)), CAST(890 AS Decimal(18, 0)), N'晶亮護明，循環順暢，維持健康', 5, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (22, 3, N'胺基酸螯合鋅錠', N'/images/products/vitamin_06.jpg', CAST(550 AS Decimal(18, 0)), CAST(420 AS Decimal(18, 0)), N'高吸收率，維持生長發育與生殖機能', 6, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (23, 3, N'海藻鈣+鎂+D3', N'/images/products/vitamin_07.jpg', CAST(900 AS Decimal(18, 0)), CAST(720 AS Decimal(18, 0)), N'完美吸收比例，維持骨骼與牙齒健康', 7, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (24, 4, N'304不鏽鋼分隔便當盒', N'/images/products/box_01.jpg', CAST(450 AS Decimal(18, 0)), CAST(350 AS Decimal(18, 0)), N'耐用好洗，不殘留異味，環保首選', 1, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (25, 4, N'白金矽膠摺疊便當盒', N'/images/products/box_02.jpg', CAST(550 AS Decimal(18, 0)), CAST(420 AS Decimal(18, 0)), N'可摺疊收納節省空間，外出攜帶超方便', 2, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (26, 4, N'耐熱玻璃保鮮盒 - 單格600ml', N'/images/products/box_03.jpg', CAST(300 AS Decimal(18, 0)), CAST(199 AS Decimal(18, 0)), N'微波、烤箱、電鍋皆適用，安全無毒', 3, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (27, 4, N'耐熱玻璃保鮮盒 - 雙格800ml', N'/images/products/box_04.jpg', CAST(380 AS Decimal(18, 0)), CAST(250 AS Decimal(18, 0)), N'飯菜分離不串味，備餐最佳容器', 4, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (28, 4, N'日式質感木製便當盒', N'/images/products/box_05.jpg', CAST(650 AS Decimal(18, 0)), CAST(499 AS Decimal(18, 0)), N'文青風格，適合冷食與輕食沙拉專用', 5, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (29, 4, N'微波專用加熱分隔餐盒', N'/images/products/box_06.jpg', CAST(250 AS Decimal(18, 0)), CAST(150 AS Decimal(18, 0)), N'食品級PP材質，附透氣孔方便微波', 6, 1)
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (30, 4, N'大容量運動雙層沙拉盒', N'/images/products/box_07.jpg', CAST(400 AS Decimal(18, 0)), CAST(299 AS Decimal(18, 0)), N'附獨立沙拉醬料盒與環保叉匙', 7, 1)
SET IDENTITY_INSERT [dbo].[Products] OFF
GO
SET IDENTITY_INSERT [dbo].[ReserveOrders] ON 

INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (4, 2, 10, CAST(N'2026-03-08T13:50:13.0000000' AS DateTime2), N'已完成', N'信用卡', N'體重管理與外食挑選建議', NULL, CAST(1200.00 AS Decimal(10, 2)), N'建議減少精緻澱粉，多攝取蔬菜')
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (5, 1, 11, CAST(N'2026-03-08T13:50:13.0000000' AS DateTime2), N'已完成', N'點數', N'日常飲食檢視與蛋白質攝取評估', 800, NULL, N'蛋白質攝取稍微不足，已建議增加白肉比例')
SET IDENTITY_INSERT [dbo].[ReserveOrders] OFF
GO
SET IDENTITY_INSERT [dbo].[Reviews] ON 

INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt]) VALUES (3, 4, 2, 2, 5, N'李營養師非常專業，給了很具體的外食建議，非常感謝！', CAST(N'2026-03-08T13:50:13.0000000' AS DateTime2))
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt]) VALUES (4, 5, 1, 1, 4, N'講解得很清楚，但希望能多提供一些超商能買到的具體品項建議。', CAST(N'2026-03-08T13:50:13.0000000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Reviews] OFF
GO
SET IDENTITY_INSERT [dbo].[RoleFunctions] ON 

INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (43, 2, 18)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (44, 2, 19)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (45, 2, 20)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (46, 2, 31)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (47, 2, 32)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (48, 2, 34)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (53, 3, 18)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (54, 3, 25)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (55, 3, 26)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (56, 3, 27)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (49, 4, 18)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (50, 4, 28)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (51, 4, 29)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (52, 4, 30)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (29, 5, 18)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (30, 5, 21)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (31, 5, 22)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (32, 5, 23)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (33, 5, 24)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (34, 5, 25)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (35, 5, 26)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (36, 5, 27)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (37, 5, 28)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (38, 5, 29)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (39, 5, 30)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (40, 5, 31)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (41, 5, 32)
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (42, 5, 33)
SET IDENTITY_INSERT [dbo].[RoleFunctions] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (1, N'member', 1, N'登入會員，可使用飲食、生理數據紀錄、方案購買權限、購買運動用品')
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (2, N'instructor', 1, N'專業教練')
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (3, N'purchasor', 1, N'採購人員，負責上下架商品及庫存管理')
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (4, N'marketor', 1, N'行銷人員，負責制定促銷方案或活動折扣')
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (5, N'admin', 1, N'系統管理員')
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (6, N'visitor', 1, N'訪客(未登入前)，只能瀏覽網頁')
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (10, N'manager', 1, N'部門主管，負責審核請假申請')
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO
SET IDENTITY_INSERT [dbo].[SensitiveWords] ON 

INSERT [dbo].[SensitiveWords] ([Id], [Word]) VALUES (6, N'白癡')
INSERT [dbo].[SensitiveWords] ([Id], [Word]) VALUES (5, N'專業')
INSERT [dbo].[SensitiveWords] ([Id], [Word]) VALUES (2, N'靠北')
INSERT [dbo].[SensitiveWords] ([Id], [Word]) VALUES (3, N'醜八怪')
SET IDENTITY_INSERT [dbo].[SensitiveWords] OFF
GO
SET IDENTITY_INSERT [dbo].[Shifts] ON 

INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (10, 2, CAST(N'2026-02-20' AS Date), N'14-15 (午)', 1)
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (11, 1, CAST(N'2026-03-01' AS Date), N'18-19 (晚)', 1)
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (58, 2, CAST(N'2026-03-30' AS Date), N'09-10 (早)', 0)
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (59, 2, CAST(N'2026-03-30' AS Date), N'14-15 (午)', 0)
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (60, 2, CAST(N'2026-03-30' AS Date), N'18-19 (晚)', 0)
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (74, 1, CAST(N'2026-03-29' AS Date), N'09-10 (早)', 0)
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (75, 1, CAST(N'2026-03-29' AS Date), N'18-19 (晚)', 0)
SET IDENTITY_INSERT [dbo].[Shifts] OFF
GO
SET IDENTITY_INSERT [dbo].[TopUpPlans] ON 

INSERT [dbo].[TopUpPlans] ([Id], [PlanName], [ImageUrl], [Price], [Points], [Description], [IsActive], [SortOrder]) VALUES (1, N'單堂體驗方案', N'/images/plans/plan_01.jpg', CAST(1000 AS Decimal(18, 0)), 1, N'購買 1 點，適合初次體驗諮詢課程的學員。', 1, 1)
INSERT [dbo].[TopUpPlans] ([Id], [PlanName], [ImageUrl], [Price], [Points], [Description], [IsActive], [SortOrder]) VALUES (2, N'雙效入門方案', N'/images/plans/plan_02.jpg', CAST(1800 AS Decimal(18, 0)), 2, N'購買 2 點，享 9 折優惠，適合有短期諮詢需求的你。', 1, 2)
INSERT [dbo].[TopUpPlans] ([Id], [PlanName], [ImageUrl], [Price], [Points], [Description], [IsActive], [SortOrder]) VALUES (3, N'五星進階方案', N'/images/plans/plan_03.jpg', CAST(4000 AS Decimal(18, 0)), 5, N'購買 5 點，享 8 折優惠，單次諮詢低至 800 元！', 1, 3)
INSERT [dbo].[TopUpPlans] ([Id], [PlanName], [ImageUrl], [Price], [Points], [Description], [IsActive], [SortOrder]) VALUES (4, N'十分超值方案', N'/images/plans/plan_04.jpg', CAST(7000 AS Decimal(18, 0)), 10, N'購買 10 點，享 7 折優惠，穩定長期諮詢的最佳選擇。', 1, 4)
INSERT [dbo].[TopUpPlans] ([Id], [PlanName], [ImageUrl], [Price], [Points], [Description], [IsActive], [SortOrder]) VALUES (5, N'尊榮鐵粉方案', N'/images/plans/plan_05.jpg', CAST(12000 AS Decimal(18, 0)), 20, N'購買 20 點，享 6 折最高優惠，單次只要 600 元，買到賺到！', 1, 5)
SET IDENTITY_INSERT [dbo].[TopUpPlans] OFF
GO
SET IDENTITY_INSERT [dbo].[UserRoles] ON 

INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (2006, 1, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (2007, 1, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (2, 2, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3, 3, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (6, 6, 3)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (7, 7, 3)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (8, 8, 4)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (9, 9, 4)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (11, 11, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (12, 12, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (1002, 13, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (2003, 1014, 5)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3008, 2013, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3009, 2013, 5)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3004, 2014, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3010, 2015, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3011, 2016, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3012, 2017, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3013, 2018, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3014, 2019, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3015, 2020, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3016, 2021, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3017, 2022, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3018, 2023, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3019, 2024, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3020, 2025, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3021, 2026, 2)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3022, 2027, 3)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3023, 2028, 3)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3024, 2029, 3)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3025, 2030, 3)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3026, 2031, 3)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3027, 2032, 3)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3028, 2033, 3)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3029, 2034, 3)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3030, 2035, 3)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3031, 2036, 3)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3032, 2037, 4)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3033, 2038, 4)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3034, 2039, 4)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3035, 2040, 4)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3036, 2041, 4)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3037, 2042, 4)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3038, 2043, 4)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3039, 2044, 4)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3040, 2045, 4)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3041, 2046, 4)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3042, 2047, 5)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3043, 2048, 5)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3044, 2049, 5)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3045, 2050, 5)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3046, 2051, 5)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3047, 2052, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3048, 2053, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3049, 2054, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3050, 2055, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3051, 2056, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3052, 2057, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3053, 2058, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3054, 2059, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3055, 2060, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3056, 2061, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3057, 2062, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3058, 2063, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3059, 2064, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3060, 2065, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3061, 2066, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3062, 2067, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3063, 2068, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3064, 2069, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3065, 2070, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3066, 2071, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3067, 2072, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3068, 2073, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3069, 2074, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3070, 2075, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3071, 2076, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3072, 2077, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3073, 2078, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3074, 2079, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3075, 2080, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3076, 2081, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3077, 2082, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3078, 2083, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3079, 2084, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3080, 2085, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3081, 2086, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3082, 2087, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3083, 2088, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3084, 2089, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3085, 2090, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3086, 2091, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3087, 2092, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3088, 2093, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3089, 2094, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3090, 2095, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3091, 2096, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3092, 2097, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3093, 2098, 1)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3094, 2099, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3095, 2100, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3096, 2101, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3097, 2102, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3098, 2103, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3099, 2104, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3100, 2105, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3101, 2106, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3102, 2107, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3103, 2108, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3104, 2109, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3105, 2110, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3106, 2111, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3107, 2112, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3108, 2113, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3109, 2114, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3110, 2115, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3111, 2116, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3112, 2117, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3113, 2118, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3114, 2119, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3115, 2120, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3116, 2121, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3117, 2122, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3118, 2123, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3119, 2124, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3120, 2125, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3121, 2126, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3122, 2127, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3123, 2128, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3124, 2129, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3125, 2130, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3126, 2131, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3127, 2132, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3128, 2133, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3129, 2134, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3130, 2135, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3131, 2136, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3132, 2137, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3133, 2138, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3134, 2139, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3135, 2140, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3136, 2141, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3137, 2142, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3138, 2143, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3139, 2144, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3140, 2145, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3141, 2146, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3142, 2147, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3143, 2148, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3144, 2149, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3145, 2150, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3146, 2151, 1)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3147, 2152, 10)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3148, 2153, 10)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3149, 2154, 10)
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3150, 2155, 10)
SET IDENTITY_INSERT [dbo].[UserRoles] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (1, N'liulinjin01', N'AQAAAAIAAYagAAAAEP0mUPSkyrn6ftw1a8vThzMKvFPhVLAbw9ZYw0orGTG21UdoTbEN9jiMWPLT/y+swQ==', N'劉林瑾', N'alice@example.com', N'0912345601', 1, 0, NULL, NULL, N'3e8b83608fe64a63b82f13fc9b61c02a', CAST(N'2026-03-09T17:38:06.0000000' AS DateTime2))
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2, N'chenhanmu02', N'AQAAAAIAAYagAAAAEP0mUPSkyrn6ftw1a8vThzMKvFPhVLAbw9ZYw0orGTG21UdoTbEN9jiMWPLT/y+swQ==', N'陳涵沐', N'bob@example.com', N'0912345602', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (3, N'linlannan03', N'AQAAAAIAAYagAAAAEP0mUPSkyrn6ftw1a8vThzMKvFPhVLAbw9ZYw0orGTG21UdoTbEN9jiMWPLT/y+swQ==', N'林蘭楠', N'carol@example.com', N'0912345603', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (6, N'chenshuan04', N'AQAAAAIAAYagAAAAEP0mUPSkyrn6ftw1a8vThzMKvFPhVLAbw9ZYw0orGTG21UdoTbEN9jiMWPLT/y+swQ==', N'陳書安', N'frank@example.com', N'0912345606', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (7, N'huqingqing05', N'AQAAAAIAAYagAAAAEP0mUPSkyrn6ftw1a8vThzMKvFPhVLAbw9ZYw0orGTG21UdoTbEN9jiMWPLT/y+swQ==', N'胡清清', N'grace@example.com', N'0912345607', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (8, N'lishilin06', N'AQAAAAIAAYagAAAAEP0mUPSkyrn6ftw1a8vThzMKvFPhVLAbw9ZYw0orGTG21UdoTbEN9jiMWPLT/y+swQ==', N'李詩林', N'henry@example.com', N'0912345608', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (9, N'wulangyan07', N'AQAAAAIAAYagAAAAEP0mUPSkyrn6ftw1a8vThzMKvFPhVLAbw9ZYw0orGTG21UdoTbEN9jiMWPLT/y+swQ==', N'吳朗妍', N'iris@example.com', N'0912345609', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (11, N'gaozhuohang08', NULL, N'高卓航', N'kevin.google@gmail.com', N'0912345611', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (12, N'luomuchen09', NULL, N'羅沐晨', N'linda.google@gmail.com', N'0912345612', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (13, N'xuyaoze10', N'AQAAAAIAAYagAAAAEP0mUPSkyrn6ftw1a8vThzMKvFPhVLAbw9ZYw0orGTG21UdoTbEN9jiMWPLT/y+swQ==', N'徐瑤澤', N'aaaa@bbbbb.com', N'0912345678', 0, 0, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (1014, N'zhouchenhan11', N'AQAAAAIAAYagAAAAEMj7/DwGlJfLr+SnWkq+6QFfV5sAiy+6tGqHH26BQChTjJV0YoX1XMq/spoGlW7rew==', N'周晨涵', N'admin@myfitnesscoach.com', NULL, 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2013, N'huqingwei12', N'AQAAAAIAAYagAAAAEFYME7wXIETzEGypBggxvBQHV6fwfcfTKMUZjdryefcjD51MX1js0yz6SFR5YwPsVQ==', N'胡青薇', N'yvonne42396@gmail.com', NULL, 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2014, N'liweiyin13', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李薇音', N'eric55339944@gmail.com', NULL, 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2015, N'luoqinglin14', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅青林', N'nutri1@fitness.com', N'0912384756', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2016, N'zhouanrou15', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周安柔', N'nutri2@fitness.com', N'0921475869', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2017, N'zhuchenyuan16', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱辰遠', N'nutri3@fitness.com', N'0933582417', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2018, N'linningran17', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林寧然', N'nutri4@fitness.com', N'0975614238', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2019, N'liyaoqing18', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李瑤清', N'nutri5@fitness.com', N'0988231457', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2020, N'herouran19', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何柔然', N'nutri6@fitness.com', N'0919456782', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2021, N'liuweiyin20', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉薇音', N'nutri7@fitness.com', N'0928374651', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2022, N'lizeqing21', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李澤清', N'nutri8@fitness.com', N'0932145698', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2023, N'linranlan22', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林然蘭', N'nutri9@fitness.com', N'0955874123', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2024, N'maruoyun23', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬若雲', N'nutri10@fitness.com', N'0910234567', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2025, N'lilangyao24', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李朗瑤', N'nutri11@fitness.com', N'0963214587', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2026, N'gaojingwei25', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高景薇', N'nutri12@fitness.com', N'0972581436', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2027, N'gaoqingxing26', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高清星', N'purch1@fitness.com', N'0937123456', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2028, N'wangyinning27', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'王音寧', N'purch2@fitness.com', N'0911223344', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2029, N'zhaochenting28', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙晨庭', N'purch3@fitness.com', N'0922334455', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2030, N'gaoshining29', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高詩寧', N'purch4@fitness.com', N'0955667788', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2031, N'maruoyao30', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬若瑤', N'purch5@fitness.com', N'0966778899', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2032, N'zhanglinjin31', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張霖瑾', N'purch6@fitness.com', N'0977889900', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2033, N'wuqingyang32', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳青揚', N'purch7@fitness.com', N'0988990011', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2034, N'heyaze33', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何雅澤', N'purch8@fitness.com', N'0900112233', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2035, N'liuchenrou34', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉晨柔', N'purch9@fitness.com', N'0911558899', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2036, N'huangyanghang35', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'黃揚航', N'purch10@fitness.com', N'0922446688', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2037, N'zhaoyuqing36', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙宇清', N'market1@fitness.com', N'0910001111', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2038, N'chenrouchen37', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'陳柔辰', N'market2@fitness.com', N'0920002222', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2039, N'yangyangyuan38', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'楊揚遠', N'market3@fitness.com', N'0930003333', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2040, N'huanghanya39', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'黃涵雅', N'market4@fitness.com', N'0940004444', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2041, N'sunnanqing40', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫楠清', N'market5@fitness.com', N'0950005555', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2042, N'zhanglangwei41', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張朗薇', N'market6@fitness.com', N'0960006666', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2043, N'zhaoweimu42', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙薇沐', N'market7@fitness.com', N'0970007777', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2044, N'sunanwei43', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫安薇', N'market8@fitness.com', N'0980008888', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2045, N'liushumu44', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉書沐', N'market9@fitness.com', N'0990009999', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2046, N'linchenshu45', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林辰書', N'market10@fitness.com', N'0900000000', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2047, N'admin1', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'admin1', N'admin1@fitness.com', N'0912121212', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2048, N'admin2', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'admin2', N'admin2@fitness.com', N'0923232323', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2049, N'admin3', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'admin3', N'admin3@fitness.com', N'0934343434', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2050, N'admin4', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'admin4', N'admin4@fitness.com', N'0945454545', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2051, N'admin5', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'admin5', N'admin5@fitness.com', N'0956565656', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2052, N'linxuanyu51', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林軒宇', N'member001@fitness.com', N'0960000001', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2053, N'liuyuanlang52', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉遠朗', N'member002@fitness.com', N'0960000002', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2054, N'huangyunyang53', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'黃雲揚', N'member003@fitness.com', N'0960000003', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2055, N'guohanqing54', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'郭涵清', N'member004@fitness.com', N'0960000004', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2056, N'sunyanshi55', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫妍詩', N'member005@fitness.com', N'0960000005', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2057, N'chenlinwei56', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'陳林薇', N'member006@fitness.com', N'0960000006', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2058, N'luoxinghao57', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅星皓', N'member007@fitness.com', N'0960000007', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2059, N'xuyangan58', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'徐揚安', N'member008@fitness.com', N'0960000008', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2060, N'xuweizhuo59', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'徐薇卓', N'member009@fitness.com', N'0960000009', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2061, N'huangqingjin60', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'黃青瑾', N'member010@fitness.com', N'0960000010', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2062, N'liuhaoya61', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉皓雅', N'member011@fitness.com', N'0960000011', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2063, N'guoxinglang62', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'郭星朗', N'member012@fitness.com', N'0960000012', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2064, N'sunlanran63', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫蘭然', N'member013@fitness.com', N'0960000013', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2065, N'mayarou64', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬雅柔', N'member014@fitness.com', N'0960000014', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2066, N'chenshuxuan65', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'陳書軒', N'member015@fitness.com', N'0960000015', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2067, N'huqinghan66', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'胡清涵', N'member016@fitness.com', N'0960000016', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2068, N'wuxuanwei67', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳軒薇', N'member017@fitness.com', N'0960000017', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2069, N'guomuan68', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'郭沐安', N'member018@fitness.com', N'0960000018', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2070, N'zhangchenyao69', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張晨瑤', N'member019@fitness.com', N'0960000019', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2071, N'heyunshu70', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何雲書', N'member020@fitness.com', N'0960000020', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2072, N'luoweiwei71', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅薇薇', N'member021@fitness.com', N'0960000021', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2073, N'zhuyinyuan72', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱音遠', N'member022@fitness.com', N'0960000022', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2074, N'zhaohaoshi73', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙皓詩', N'member023@fitness.com', N'0960000023', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2075, N'maqingrou74', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬清柔', N'member024@fitness.com', N'0960000024', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2076, N'liuyaoze75', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉瑤澤', N'member025@fitness.com', N'0960000025', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2077, N'liuanhang76', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉安航', N'member026@fitness.com', N'0960000026', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2078, N'zhangzhuoqing77', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張卓晴', N'member027@fitness.com', N'0960000027', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2079, N'guolinwei78', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'郭霖薇', N'member028@fitness.com', N'0960000028', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2080, N'zhangmulan79', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張沐蘭', N'member029@fitness.com', N'0960000029', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2081, N'zhujinting80', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱瑾庭', N'member030@fitness.com', N'0960000030', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2082, N'maboze81', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬柏澤', N'member031@fitness.com', N'0960000031', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2083, N'zhoumuqing82', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周沐青', N'member032@fitness.com', N'0960000032', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2084, N'zhaojingze83', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙景澤', N'member033@fitness.com', N'0960000033', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2085, N'zhangmuning84', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張沐寧', N'member034@fitness.com', N'0960000034', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2086, N'zhaotingjing85', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙庭景', N'member035@fitness.com', N'0960000035', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2087, N'mananzhuo86', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬楠卓', N'member036@fitness.com', N'0960000036', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2088, N'guozhuolang87', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'郭卓朗', N'member037@fitness.com', N'0960000037', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2089, N'yangzechen88', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'楊澤辰', N'member038@fitness.com', N'0960000038', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2090, N'wuxinghao89', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳星皓', N'member039@fitness.com', N'0960000039', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2091, N'luozehan90', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅澤涵', N'member040@fitness.com', N'0960000040', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2092, N'sunhanyin91', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫涵音', N'member041@fitness.com', N'0960000041', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2093, N'luoqingning92', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅清寧', N'member042@fitness.com', N'0960000042', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2094, N'wulangchuan93', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳朗川', N'member043@fitness.com', N'0960000043', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2095, N'liyalin94', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李雅霖', N'member044@fitness.com', N'0960000044', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2096, N'huyanting95', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'胡言庭', N'member045@fitness.com', N'0960000045', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2097, N'zhangchenya96', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張辰雅', N'member046@fitness.com', N'0960000046', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2098, N'chenyuchen97', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'陳宇晨', N'member047@fitness.com', N'0960000047', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2099, N'zhanganyang98', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張安揚', N'member048@fitness.com', N'0960000048', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2100, N'xuchenyun99', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'徐辰雲', N'member049@fitness.com', N'0960000049', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2101, N'zhurouqing100', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱柔青', N'member050@fitness.com', N'0960000050', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2102, N'gaomuyan101', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高沐言', N'member051@fitness.com', N'0960000051', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2103, N'zhangxuanting102', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張軒庭', N'member052@fitness.com', N'0960000052', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2104, N'yangnanhang103', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'楊楠航', N'member053@fitness.com', N'0960000053', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2105, N'luoyaoyan104', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅瑤妍', N'member054@fitness.com', N'0960000054', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2106, N'majingyin105', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬景音', N'member055@fitness.com', N'0960000055', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2107, N'xubaihao106', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'徐柏皓', N'member056@fitness.com', N'0960000056', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2108, N'zhuoruolang107', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱若朗', N'member057@fitness.com', N'0960000057', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2109, N'yangyuyang108', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'楊宇揚', N'member058@fitness.com', N'0960000058', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2110, N'zhaoyaoqing109', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙瑤清', N'member059@fitness.com', N'0960000059', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2111, N'heweihao110', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何薇皓', N'member060@fitness.com', N'0960000060', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2112, N'zhouhangyu111', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周航宇', N'member061@fitness.com', N'0960000061', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2113, N'wuweiyang112', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳薇揚', N'member062@fitness.com', N'0960000062', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2114, N'wulinyao113', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳霖瑤', N'member063@fitness.com', N'0960000063', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2115, N'zhouyunya114', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周雲雅', N'member064@fitness.com', N'0960000064', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2116, N'zhouyanyang115', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周言揚', N'member065@fitness.com', N'0960000065', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2117, N'sunbaihao116', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫柏皓', N'member066@fitness.com', N'0960000066', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2118, N'sunruozhuo117', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫若卓', N'member067@fitness.com', N'0960000067', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2119, N'sunmumu118', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫沐沐', N'member068@fitness.com', N'0960000068', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2120, N'zhoulinyan119', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周林妍', N'member069@fitness.com', N'0960000069', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2121, N'linzeting120', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林澤庭', N'member070@fitness.com', N'0960000070', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2122, N'hejinze121', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何瑾澤', N'member071@fitness.com', N'0960000071', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2123, N'wunanlin122', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳楠霖', N'member072@fitness.com', N'0960000072', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2124, N'wuyanhan123', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳言涵', N'member073@fitness.com', N'0960000073', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2125, N'luoweiyan124', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅薇言', N'member074@fitness.com', N'0960000074', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2126, N'heweihao125', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何薇皓', N'member075@fitness.com', N'0960000075', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2127, N'zhoutingzhuo126', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周庭卓', N'member076@fitness.com', N'0960000076', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2128, N'wuranze127', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳然澤', N'member077@fitness.com', N'0960000077', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2129, N'lizemu128', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李澤沐', N'member078@fitness.com', N'0960000078', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2130, N'linyinting129', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林音庭', N'member079@fitness.com', N'0960000079', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2131, N'heyuruo130', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何宇若', N'member080@fitness.com', N'0960000080', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2132, N'gaoanqing131', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高安清', N'member081@fitness.com', N'0960000081', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2133, N'zhaolangyao132', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙朗瑤', N'member082@fitness.com', N'0960000082', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2134, N'wangjinjin133', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'王瑾瑾', N'member083@fitness.com', N'0960000083', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2135, N'gaoyunan134', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高雲安', N'member084@fitness.com', N'0960000084', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2136, N'malangyan135', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬朗妍', N'member085@fitness.com', N'0960000085', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2137, N'gaoqingan136', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高晴安', N'member086@fitness.com', N'0960000086', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2138, N'liulinran137', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉霖然', N'member087@fitness.com', N'0960000087', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2139, N'huningya138', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'胡寧雅', N'member088@fitness.com', N'0960000088', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2140, N'zhouhangjing139', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周航景', N'member089@fitness.com', N'0960000089', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2141, N'huqingyang140', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'胡晴揚', N'member090@fitness.com', N'0960000090', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2142, N'huyanshi141', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'胡言詩', N'member091@fitness.com', N'0960000091', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2143, N'zhuhaolin142', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱皓林', N'member092@fitness.com', N'0960000092', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2144, N'xumuyang143', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'徐沐揚', N'member093@fitness.com', N'0960000093', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2145, N'wuhanghang144', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳航航', N'member094@fitness.com', N'0960000094', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2146, N'wuyuxing145', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳宇星', N'member095@fitness.com', N'0960000095', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2147, N'huangshijing146', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'黃詩景', N'member096@fitness.com', N'0960000096', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2148, N'heyanyun147', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何言雲', N'member097@fitness.com', N'0960000097', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2149, N'gaoyangbai148', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高揚柏', N'member098@fitness.com', N'0960000098', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2150, N'zhuqinghan149', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱青涵', N'member099@fitness.com', N'0960000099', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2151, N'zhangxingnan150', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張星楠', N'member100@fitness.com', N'0960000100', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2152, N'chenzhiming1', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'陳志明', N'manager01@fitness.com', N'0960000001', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2153, N'linmeiling2', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林美玲', N'manager02@fitness.com', N'0960000002', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2154, N'zhangjianguo3', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張建國', N'manager03@fitness.com', N'0960000003', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2155, N'wangshufen4', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'王淑芬', N'manager04@fitness.com', N'0960000004', 1, 1, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
SET IDENTITY_INSERT [dbo].[UserWallets] ON 

INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (1, 1, CAST(3.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (2, 2, CAST(1.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (3, 7, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (4, 8, CAST(1.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (5, 9, CAST(60.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (6, 10, CAST(40.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (7, 11, CAST(5.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (8, 12, CAST(2.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (9, 13, CAST(2.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (10, 14, CAST(2.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (11, 15, CAST(6.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (12, 16, CAST(2.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (13, 17, CAST(5.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (14, 18, CAST(45.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (15, 19, CAST(5.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (16, 20, CAST(11.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (17, 21, CAST(12.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (18, 22, CAST(8.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (19, 23, CAST(5.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (20, 24, CAST(5.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (21, 25, CAST(22.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (22, 26, CAST(22.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (23, 27, CAST(10.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (24, 28, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (25, 29, CAST(17.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (26, 30, CAST(10.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (27, 31, CAST(1.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (28, 32, CAST(7.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (29, 33, CAST(5.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (30, 34, CAST(6.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (31, 35, CAST(32.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (32, 36, CAST(26.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (33, 37, CAST(1.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (34, 38, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (35, 39, CAST(10.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (36, 40, CAST(12.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (37, 41, CAST(10.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (38, 42, CAST(3.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (39, 43, CAST(30.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (40, 44, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (41, 45, CAST(10.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (42, 46, CAST(21.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (43, 47, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (44, 48, CAST(5.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (45, 49, CAST(12.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (46, 50, CAST(13.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (47, 51, CAST(5.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (48, 52, CAST(49.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (49, 53, CAST(6.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (50, 54, CAST(3.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (51, 55, CAST(12.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (52, 56, CAST(33.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (53, 57, CAST(14.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (54, 58, CAST(21.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (55, 59, CAST(10.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (56, 60, CAST(50.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (57, 61, CAST(11.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (58, 62, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (59, 63, CAST(6.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (60, 64, CAST(2.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (61, 65, CAST(5.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (62, 66, CAST(1.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (63, 67, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (64, 68, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (65, 69, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (66, 70, CAST(1.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (67, 71, CAST(46.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (68, 72, CAST(2.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (69, 73, CAST(6.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (70, 74, CAST(5.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (71, 75, CAST(56.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (72, 76, CAST(10.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (73, 77, CAST(3.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (74, 78, CAST(16.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (75, 79, CAST(5.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (76, 80, CAST(40.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (77, 81, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (78, 82, CAST(2.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (79, 83, CAST(7.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (80, 84, CAST(1.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (81, 85, CAST(8.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (82, 86, CAST(6.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (83, 87, CAST(10.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (84, 88, CAST(6.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (85, 89, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (86, 90, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (87, 91, CAST(22.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (88, 92, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (89, 93, CAST(2.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (90, 94, CAST(1.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (91, 95, CAST(20.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (92, 96, CAST(5.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (93, 97, CAST(40.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (94, 98, CAST(1.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (95, 99, CAST(10.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (96, 100, CAST(25.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (97, 101, CAST(11.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (98, 102, CAST(2.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (99, 103, CAST(42.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
GO
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (100, 104, CAST(1.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (101, 105, CAST(26.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (102, 106, CAST(7.00 AS Decimal(10, 2)), CAST(N'2026-03-16T15:47:53.0000000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[UserWallets] OFF
GO
/****** Object:  Index [UQ_Employees_UserId]    Script Date: 2026/3/16 下午 05:05:16 ******/
ALTER TABLE [dbo].[Employees] ADD  CONSTRAINT [UQ_Employees_UserId] UNIQUE NONCLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_LeaveBalances_Key]    Script Date: 2026/3/16 下午 05:05:16 ******/
ALTER TABLE [dbo].[LeaveBalances] ADD  CONSTRAINT [UQ_LeaveBalances_Key] UNIQUE NONCLUSTERED 
(
	[EmployeeId] ASC,
	[LeaveTypeId] ASC,
	[Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_LeaveRequests_EmployeeId]    Script Date: 2026/3/16 下午 05:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_LeaveRequests_EmployeeId] ON [dbo].[LeaveRequests]
(
	[EmployeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_LeaveRequests_Status]    Script Date: 2026/3/16 下午 05:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_LeaveRequests_Status] ON [dbo].[LeaveRequests]
(
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_MemberViolations_MemberId]    Script Date: 2026/3/16 下午 05:05:16 ******/
ALTER TABLE [dbo].[MemberViolations] ADD  CONSTRAINT [UQ_MemberViolations_MemberId] UNIQUE NONCLUSTERED 
(
	[MemberId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_RoleFunctions]    Script Date: 2026/3/16 下午 05:05:16 ******/
ALTER TABLE [dbo].[RoleFunctions] ADD  CONSTRAINT [UQ_RoleFunctions] UNIQUE NONCLUSTERED 
(
	[RoleId] ASC,
	[FunctionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Roles_RoleName]    Script Date: 2026/3/16 下午 05:05:16 ******/
ALTER TABLE [dbo].[Roles] ADD  CONSTRAINT [UQ_Roles_RoleName] UNIQUE NONCLUSTERED 
(
	[RoleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_SensitiveWords_Word]    Script Date: 2026/3/16 下午 05:05:16 ******/
ALTER TABLE [dbo].[SensitiveWords] ADD  CONSTRAINT [UQ_SensitiveWords_Word] UNIQUE NONCLUSTERED 
(
	[Word] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_UserRoles]    Script Date: 2026/3/16 下午 05:05:16 ******/
ALTER TABLE [dbo].[UserRoles] ADD  CONSTRAINT [UQ_UserRoles] UNIQUE NONCLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Users_Email]    Script Date: 2026/3/16 下午 05:05:16 ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [UQ_Users_Email] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_Users_Account]    Script Date: 2026/3/16 下午 05:05:16 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_Users_Account] ON [dbo].[Users]
(
	[Account] ASC
)
WHERE ([Account] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_UserWallets_Member]    Script Date: 2026/3/16 下午 05:05:16 ******/
ALTER TABLE [dbo].[UserWallets] ADD  CONSTRAINT [UQ_UserWallets_Member] UNIQUE NONCLUSTERED 
(
	[MemberId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Employees] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[FoodCategories] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[FoodRecords] ADD  DEFAULT (getdate()) FOR [EatDT]
GO
ALTER TABLE [dbo].[Foods] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Functions] ADD  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Instructors] ADD  DEFAULT ((1)) FOR [CancelCount]
GO
ALTER TABLE [dbo].[Instructors] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[LeaveAttachments] ADD  DEFAULT (getdate()) FOR [UploadedAt]
GO
ALTER TABLE [dbo].[LeaveBalances] ADD  DEFAULT ((0)) FOR [UsedDays]
GO
ALTER TABLE [dbo].[LeaveRequests] ADD  DEFAULT ('Pending') FOR [Status]
GO
ALTER TABLE [dbo].[LeaveRequests] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[LeaveTypes] ADD  DEFAULT ((0)) FOR [CarryOver]
GO
ALTER TABLE [dbo].[LeaveTypes] ADD  DEFAULT ((0)) FOR [RequiresDoc]
GO
ALTER TABLE [dbo].[LeaveTypes] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Members] ADD  DEFAULT ((1)) FOR [CancelCount]
GO
ALTER TABLE [dbo].[MemberViolations] ADD  DEFAULT ((0)) FOR [WarningCount]
GO
ALTER TABLE [dbo].[MemberViolations] ADD  DEFAULT ((0)) FOR [IsSuspended]
GO
ALTER TABLE [dbo].[Notifications] ADD  DEFAULT ((0)) FOR [IsRead]
GO
ALTER TABLE [dbo].[Notifications] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[PointOrders] ADD  CONSTRAINT [DF__PointOrde__Creat__70DDC3D8]  DEFAULT (getdate()) FOR [CreateAt]
GO
ALTER TABLE [dbo].[PointsRecordDetails] ADD  DEFAULT (getdate()) FOR [CreateAt]
GO
ALTER TABLE [dbo].[ProductCategories] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ProductOrders] ADD  DEFAULT (getdate()) FOR [CreateAt]
GO
ALTER TABLE [dbo].[Products] ADD  CONSTRAINT [DF__Products__IsActi__7E37BEF6]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ReserveOrders] ADD  DEFAULT (getdate()) FOR [CreateAt]
GO
ALTER TABLE [dbo].[Reviews] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Shifts] ADD  DEFAULT ((0)) FOR [IsBooked]
GO
ALTER TABLE [dbo].[TopUpPlans] ADD  CONSTRAINT [DF__TopUpPlan__IsAct__0B91BA14]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[TopUpPlans] ADD  CONSTRAINT [DF__TopUpPlan__SortO__0C85DE4D]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((0)) FOR [IsConfirmed]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[UserWallets] ADD  DEFAULT ((0)) FOR [CurrentBalance]
GO
ALTER TABLE [dbo].[UserWallets] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[Departments]  WITH CHECK ADD  CONSTRAINT [FK_Dept_Manager] FOREIGN KEY([ManagerId])
REFERENCES [dbo].[Employees] ([Id])
GO
ALTER TABLE [dbo].[Departments] CHECK CONSTRAINT [FK_Dept_Manager]
GO
ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Dept] FOREIGN KEY([DepartmentId])
REFERENCES [dbo].[Departments] ([Id])
GO
ALTER TABLE [dbo].[Employees] CHECK CONSTRAINT [FK_Employees_Dept]
GO
ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Manager] FOREIGN KEY([ManagerId])
REFERENCES [dbo].[Employees] ([Id])
GO
ALTER TABLE [dbo].[Employees] CHECK CONSTRAINT [FK_Employees_Manager]
GO
ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Employees] CHECK CONSTRAINT [FK_Employees_Users]
GO
ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_WorkDel] FOREIGN KEY([WorkDelegateId])
REFERENCES [dbo].[Employees] ([Id])
GO
ALTER TABLE [dbo].[Employees] CHECK CONSTRAINT [FK_Employees_WorkDel]
GO
ALTER TABLE [dbo].[FoodRecords]  WITH CHECK ADD  CONSTRAINT [FK_FoodRecords_Foods] FOREIGN KEY([FoodId])
REFERENCES [dbo].[Foods] ([Id])
GO
ALTER TABLE [dbo].[FoodRecords] CHECK CONSTRAINT [FK_FoodRecords_Foods]
GO
ALTER TABLE [dbo].[FoodRecords]  WITH CHECK ADD  CONSTRAINT [FK_FoodRecords_Members] FOREIGN KEY([MemberId])
REFERENCES [dbo].[Members] ([Id])
GO
ALTER TABLE [dbo].[FoodRecords] CHECK CONSTRAINT [FK_FoodRecords_Members]
GO
ALTER TABLE [dbo].[Foods]  WITH CHECK ADD  CONSTRAINT [FK_Foods_FoodCategories] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[FoodCategories] ([Id])
GO
ALTER TABLE [dbo].[Foods] CHECK CONSTRAINT [FK_Foods_FoodCategories]
GO
ALTER TABLE [dbo].[Instructors]  WITH CHECK ADD  CONSTRAINT [FK_Instructors_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Instructors] CHECK CONSTRAINT [FK_Instructors_Users]
GO
ALTER TABLE [dbo].[LeaveAttachments]  WITH CHECK ADD  CONSTRAINT [FK_Attach_Request] FOREIGN KEY([RequestId])
REFERENCES [dbo].[LeaveRequests] ([Id])
GO
ALTER TABLE [dbo].[LeaveAttachments] CHECK CONSTRAINT [FK_Attach_Request]
GO
ALTER TABLE [dbo].[LeaveBalances]  WITH CHECK ADD  CONSTRAINT [FK_Balance_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employees] ([Id])
GO
ALTER TABLE [dbo].[LeaveBalances] CHECK CONSTRAINT [FK_Balance_Employee]
GO
ALTER TABLE [dbo].[LeaveBalances]  WITH CHECK ADD  CONSTRAINT [FK_Balance_LeaveType] FOREIGN KEY([LeaveTypeId])
REFERENCES [dbo].[LeaveTypes] ([Id])
GO
ALTER TABLE [dbo].[LeaveBalances] CHECK CONSTRAINT [FK_Balance_LeaveType]
GO
ALTER TABLE [dbo].[LeaveRequests]  WITH CHECK ADD  CONSTRAINT [FK_Leave_ApprovedBy] FOREIGN KEY([ApprovedBy])
REFERENCES [dbo].[Employees] ([Id])
GO
ALTER TABLE [dbo].[LeaveRequests] CHECK CONSTRAINT [FK_Leave_ApprovedBy]
GO
ALTER TABLE [dbo].[LeaveRequests]  WITH CHECK ADD  CONSTRAINT [FK_Leave_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employees] ([Id])
GO
ALTER TABLE [dbo].[LeaveRequests] CHECK CONSTRAINT [FK_Leave_Employee]
GO
ALTER TABLE [dbo].[LeaveRequests]  WITH CHECK ADD  CONSTRAINT [FK_Leave_LeaveDelegate] FOREIGN KEY([LeaveDelegateId])
REFERENCES [dbo].[Employees] ([Id])
GO
ALTER TABLE [dbo].[LeaveRequests] CHECK CONSTRAINT [FK_Leave_LeaveDelegate]
GO
ALTER TABLE [dbo].[LeaveRequests]  WITH CHECK ADD  CONSTRAINT [FK_Leave_LeaveType] FOREIGN KEY([LeaveTypeId])
REFERENCES [dbo].[LeaveTypes] ([Id])
GO
ALTER TABLE [dbo].[LeaveRequests] CHECK CONSTRAINT [FK_Leave_LeaveType]
GO
ALTER TABLE [dbo].[Members]  WITH CHECK ADD  CONSTRAINT [FK_Members_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Members] CHECK CONSTRAINT [FK_Members_Users]
GO
ALTER TABLE [dbo].[MemberViolations]  WITH CHECK ADD  CONSTRAINT [FK_MemberViolations_Members] FOREIGN KEY([MemberId])
REFERENCES [dbo].[Members] ([Id])
GO
ALTER TABLE [dbo].[MemberViolations] CHECK CONSTRAINT [FK_MemberViolations_Members]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [FK_Notifications_Users_Receiver] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [FK_Notifications_Users_Receiver]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [FK_Notifications_Users_Sender] FOREIGN KEY([SenderId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [FK_Notifications_Users_Sender]
GO
ALTER TABLE [dbo].[Nutrients]  WITH CHECK ADD  CONSTRAINT [FK_Nutrients_Foods] FOREIGN KEY([FoodId])
REFERENCES [dbo].[Foods] ([Id])
GO
ALTER TABLE [dbo].[Nutrients] CHECK CONSTRAINT [FK_Nutrients_Foods]
GO
ALTER TABLE [dbo].[PointOrders]  WITH CHECK ADD  CONSTRAINT [FK_PointOrders_Members] FOREIGN KEY([MemberId])
REFERENCES [dbo].[Members] ([Id])
GO
ALTER TABLE [dbo].[PointOrders] CHECK CONSTRAINT [FK_PointOrders_Members]
GO
ALTER TABLE [dbo].[PointOrders]  WITH CHECK ADD  CONSTRAINT [FK_PointOrders_TopUpPlans] FOREIGN KEY([TopUpPlanId])
REFERENCES [dbo].[TopUpPlans] ([Id])
GO
ALTER TABLE [dbo].[PointOrders] CHECK CONSTRAINT [FK_PointOrders_TopUpPlans]
GO
ALTER TABLE [dbo].[PointsRecordDetails]  WITH CHECK ADD  CONSTRAINT [FK_PointsRecordDetails_PointOrders] FOREIGN KEY([PointOrderId])
REFERENCES [dbo].[PointOrders] ([Id])
GO
ALTER TABLE [dbo].[PointsRecordDetails] CHECK CONSTRAINT [FK_PointsRecordDetails_PointOrders]
GO
ALTER TABLE [dbo].[PointsRecordDetails]  WITH CHECK ADD  CONSTRAINT [FK_PointsRecordDetails_ReserveOrders] FOREIGN KEY([ReserveOrderId])
REFERENCES [dbo].[ReserveOrders] ([Id])
GO
ALTER TABLE [dbo].[PointsRecordDetails] CHECK CONSTRAINT [FK_PointsRecordDetails_ReserveOrders]
GO
ALTER TABLE [dbo].[PointsRecordDetails]  WITH CHECK ADD  CONSTRAINT [FK_PointsRecordDetails_UserWallets] FOREIGN KEY([UserWalletId])
REFERENCES [dbo].[UserWallets] ([Id])
GO
ALTER TABLE [dbo].[PointsRecordDetails] CHECK CONSTRAINT [FK_PointsRecordDetails_UserWallets]
GO
ALTER TABLE [dbo].[ProductOrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_ProductOrderDetails_ProductOrders] FOREIGN KEY([ProductOrderId])
REFERENCES [dbo].[ProductOrders] ([Id])
GO
ALTER TABLE [dbo].[ProductOrderDetails] CHECK CONSTRAINT [FK_ProductOrderDetails_ProductOrders]
GO
ALTER TABLE [dbo].[ProductOrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_ProductOrderDetails_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[ProductOrderDetails] CHECK CONSTRAINT [FK_ProductOrderDetails_Products]
GO
ALTER TABLE [dbo].[ProductOrders]  WITH CHECK ADD  CONSTRAINT [FK_ProductOrders_Members] FOREIGN KEY([MemberId])
REFERENCES [dbo].[Members] ([Id])
GO
ALTER TABLE [dbo].[ProductOrders] CHECK CONSTRAINT [FK_ProductOrders_Members]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_ProductCategories] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[ProductCategories] ([Id])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_ProductCategories]
GO
ALTER TABLE [dbo].[ReserveOrders]  WITH CHECK ADD  CONSTRAINT [FK_ReserveOrders_Members] FOREIGN KEY([MemberId])
REFERENCES [dbo].[Members] ([Id])
GO
ALTER TABLE [dbo].[ReserveOrders] CHECK CONSTRAINT [FK_ReserveOrders_Members]
GO
ALTER TABLE [dbo].[ReserveOrders]  WITH CHECK ADD  CONSTRAINT [FK_ReserveOrders_Shifts] FOREIGN KEY([ShiftId])
REFERENCES [dbo].[Shifts] ([Id])
GO
ALTER TABLE [dbo].[ReserveOrders] CHECK CONSTRAINT [FK_ReserveOrders_Shifts]
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD  CONSTRAINT [FK_Reviews_Instructors] FOREIGN KEY([InstructorId])
REFERENCES [dbo].[Instructors] ([Id])
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [FK_Reviews_Instructors]
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD  CONSTRAINT [FK_Reviews_Members] FOREIGN KEY([MemberId])
REFERENCES [dbo].[Members] ([Id])
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [FK_Reviews_Members]
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD  CONSTRAINT [FK_Reviews_ReserveOrders] FOREIGN KEY([ReserveOrderId])
REFERENCES [dbo].[ReserveOrders] ([Id])
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [FK_Reviews_ReserveOrders]
GO
ALTER TABLE [dbo].[RoleFunctions]  WITH CHECK ADD  CONSTRAINT [FK_RoleFunctions_Function] FOREIGN KEY([FunctionId])
REFERENCES [dbo].[Functions] ([Id])
GO
ALTER TABLE [dbo].[RoleFunctions] CHECK CONSTRAINT [FK_RoleFunctions_Function]
GO
ALTER TABLE [dbo].[RoleFunctions]  WITH CHECK ADD  CONSTRAINT [FK_RoleFunctions_Role] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([Id])
GO
ALTER TABLE [dbo].[RoleFunctions] CHECK CONSTRAINT [FK_RoleFunctions_Role]
GO
ALTER TABLE [dbo].[Shifts]  WITH CHECK ADD  CONSTRAINT [FK_Shifts_Instructors] FOREIGN KEY([InstructorId])
REFERENCES [dbo].[Instructors] ([Id])
GO
ALTER TABLE [dbo].[Shifts] CHECK CONSTRAINT [FK_Shifts_Instructors]
GO
ALTER TABLE [dbo].[UserExternalLogins]  WITH CHECK ADD  CONSTRAINT [FK_ExternalLogins_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[UserExternalLogins] CHECK CONSTRAINT [FK_ExternalLogins_Users]
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_UserRoles_Role] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([Id])
GO
ALTER TABLE [dbo].[UserRoles] CHECK CONSTRAINT [FK_UserRoles_Role]
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_UserRoles_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[UserRoles] CHECK CONSTRAINT [FK_UserRoles_User]
GO
ALTER TABLE [dbo].[UserWallets]  WITH CHECK ADD  CONSTRAINT [FK_UserWallets_Members] FOREIGN KEY([MemberId])
REFERENCES [dbo].[Members] ([Id])
GO
ALTER TABLE [dbo].[UserWallets] CHECK CONSTRAINT [FK_UserWallets_Members]
GO
ALTER TABLE [dbo].[LeaveRequests]  WITH CHECK ADD  CONSTRAINT [CK_LeaveRequests_Status] CHECK  (([Status]='Cancelled' OR [Status]='Rejected' OR [Status]='Approved' OR [Status]='Pending'))
GO
ALTER TABLE [dbo].[LeaveRequests] CHECK CONSTRAINT [CK_LeaveRequests_Status]
GO