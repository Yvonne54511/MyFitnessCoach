USE [MyFitnessCoachDb]
GO
/****** Object:  Table [dbo].[Departments]    Script Date: 2026/3/18 下午 04:59:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Departments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[ManagerId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[Roles]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[UserRoles]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  View [dbo].[vw_EmployeeDeptInfo]    Script Date: 2026/3/18 下午 04:59:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- 2. 建立視圖 (Views)
-- ============================================================
CREATE VIEW [dbo].[vw_EmployeeDeptInfo] AS
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
/****** Object:  Table [dbo].[Functions]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[RoleFunctions]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  View [dbo].[vw_UserRoleFunctions]    Script Date: 2026/3/18 下午 04:59:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_UserRoleFunctions] AS
SELECT u.UserName, u.Account, r.RoleName, f.FunctionName
FROM [dbo].[Users] u
JOIN [dbo].[UserRoles] ur ON u.Id = ur.UserId
JOIN [dbo].[Roles] r ON ur.RoleId = r.Id
JOIN [dbo].[RoleFunctions] rf ON r.Id = rf.RoleId
JOIN [dbo].[Functions] f ON rf.FunctionId = f.Id;
GO
/****** Object:  View [dbo].[vw_RoleFunctions]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  View [dbo].[vw_UserRoleFunction]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[Members]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[FoodCategories]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[Foods]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[Nutrients]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[FoodRecords]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  View [dbo].[vw_UserMemberFoodRecord]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[BodyRecords]    Script Date: 2026/3/18 下午 04:59:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BodyRecords](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MemberId] [int] NOT NULL,
	[Weight] [float] NOT NULL,
	[BodyFat] [decimal](4, 1) NULL,
	[SkeletalMuscle] [decimal](4, 1) NULL,
	[WaistCircumference] [decimal](5, 1) NULL,
	[CreateAt] [datetime2](0) NOT NULL,
	[Note] [nvarchar](200) NULL,
	[ImageUrl] [nvarchar](300) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Instructors]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[InstructorWalletDetails]    Script Date: 2026/3/18 下午 04:59:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InstructorWalletDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[InstructorWalletId] [int] NOT NULL,
	[SalaryDate] [nvarchar](10) NOT NULL,
	[TotalAmount] [decimal](10, 2) NOT NULL,
	[CreatedAt] [datetime2](0) NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InstructorWallets]    Script Date: 2026/3/18 下午 04:59:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InstructorWallets](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[InstructorId] [int] NOT NULL,
	[CurrentBalance] [decimal](10, 2) NOT NULL,
	[LastUpdated] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KeyWords]    Script Date: 2026/3/18 下午 04:59:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KeyWords](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Word] [nvarchar](50) NOT NULL,
	[Category] [int] NOT NULL,
	[Weight] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LeaveAttachments]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LeaveBalances]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LeaveRequests]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
	[HoursUsed] [decimal](18, 1) NULL,
	[OriginalStatus] [nvarchar](20) NULL,
	[CancelRequestedAt] [datetime2](7) NULL,
	[CancelReason] [nvarchar](300) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LeaveTypes]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MemberViolations]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[Notifications]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[PointOrders]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PointsRecordDetails]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[ProductCategories]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[ProductOrderDetails]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[ProductOrders]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[Products]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReserveOrders]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[Reviews]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
	[IsBanned] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SensitiveWords]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[Shifts]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[TopUpPlans]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserExternalLogins]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
/****** Object:  Table [dbo].[UserWallets]    Script Date: 2026/3/18 下午 04:59:26 ******/
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
SET IDENTITY_INSERT [dbo].[Functions] ON 
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (18, N'edit_Password', 1, N'修改個人自己的登入密碼', N'/Account/ResetPassword')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (19, N'edit_IntructorDetails', 1, N'修改教練自己的個人簡介', N'/Account/InstructorDetails')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (20, N'edit_InstructorShifts', 1, N'安排或修改教練自己的排班', N'/Shift/Index')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (21, N'view_InstructorShifts', 1, N'查看所有教練的排班情況', N'/Shift/AllShifts')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (22, N'edit_UserAccounts', 1, N'管理、設定、修改、停用、恢復所有使用者的帳號', N'/Staff/Index')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (23, N'edit_RoleFunctions', 1, N'設定每個角色可以使用哪些系統功能(設定每個角色的權限設定)', N'/Staff/RoleFunctions')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (24, N'edit_UserRoles', 1, N'新增或修改使用者的所屬角色', N'/Staff/UserRoles')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (25, N'edit_ProductCategories', 1, N'管理商品的商品分類', N'/ProductCategories/Index')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (26, N'edit_ProductItems', 1, N'管理商品的商品', N'/Products/Index')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (27, N'edit_ProductOrders', 1, N'處理商品的訂單', N'/ProductOrders/index')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (28, N'edit_Plans', 1, N'制定或修改促銷方案', N'/TopUpPlans/Index')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (29, N'edit_PlanOrders', 1, N'處理促銷方案或課程購買生成的訂單', N'/PointOrders/Index')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (30, N'view_PointRecords', 1, N'查看會員的點數取得及使用紀錄', N'/Member/PointsRecord')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (31, N'view_ClientFoodRecords', 1, N'查看會員每日的飲食紀錄', N'/Member/ViewFoodRecords')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (32, N'view_ClientBodyData', 1, N'查看會員生理數據變化', N'/Member/ViewFoodRecords')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (33, N'edit_Comments_admin', 1, N'系統管理員回覆評論或刪除', N'/Review/AdminIndex')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (34, N'edit_Comments_instructor', 1, N'專業教練回覆評論', N'/Review/InstructorIndex')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (35, N'view_KeyWords', 1, N'查看關鍵字', N'/KeyWords/Index')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (36, N'edit_KeyWords', 1, N'編輯關鍵字', N'/KeyWords/Create')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (37, N'view_Salary', 1, N'查看營養師薪資表', N'/Salary/Index')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (38, N'view_Salary2', 1, N'查看薪資明細', N'/Salary/_SalaryDetailPartial')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (39, N'view_MemberViolations', 1, N'查看會員違規紀錄', N'/MemberViolation/Index')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (40, N'edit_MemberViolations', 1, N'修改會員違規紀錄', N'/MemberViolation/Edit')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (41, N'create_MemberViolations', 1, N'新增會員違規紀錄', N'/MemberViolation/Create')
GO
INSERT [dbo].[Functions] ([Id], [FunctionName], [IsActive], [Description], [Api_path]) VALUES (42, N'view_MyWallet', 1, N'查看營養師自己的錢包', N'/Salary/MyWallet')
GO
SET IDENTITY_INSERT [dbo].[Functions] OFF
GO
SET IDENTITY_INSERT [dbo].[Instructors] ON 
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (1, 2014, N'/images/instructors/ins1.jpg', N'專精減脂', 1000, 0, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (2, 2013, N'/images/instructors/yvonne.jpg', N'糖尿病飲食', 1200, 1, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (3, 2015, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料1', 1200, 0, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (4, 2016, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料2', 1200, 0, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (5, 2017, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料3', 1200, 0, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (6, 2018, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料4', 1200, 0, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (7, 2019, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料5', 1200, 0, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (8, 2020, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料6', 1200, 0, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (9, 2021, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料7', 1200, 0, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (10, 2022, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料8', 1200, 0, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (11, 2023, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料9', 1200, 0, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (12, 2024, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料10', 1200, 0, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (13, 2025, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料11', 1200, 0, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (14, 2026, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料12', 1200, 0, 1)
GO
SET IDENTITY_INSERT [dbo].[Instructors] OFF
GO
SET IDENTITY_INSERT [dbo].[InstructorWallets] ON 
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (1, 1, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-04-01T18:11:19.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (2, 2, CAST(0.00 AS Decimal(10, 2)), CAST(N'2027-01-01T09:59:19.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (3, 3, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-03-17T10:18:52.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (4, 4, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-03-17T10:18:52.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (5, 5, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-03-17T10:18:52.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (6, 6, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-03-17T10:18:52.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (7, 7, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-03-17T10:18:52.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (8, 8, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-03-17T10:18:52.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (9, 9, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-03-17T10:18:52.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (10, 10, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-03-17T10:18:52.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (11, 11, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-03-17T10:18:52.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (12, 12, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-03-17T10:18:52.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (13, 13, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-03-17T10:18:52.0000000' AS DateTime2))
GO
INSERT [dbo].[InstructorWallets] ([Id], [InstructorId], [CurrentBalance], [LastUpdated]) VALUES (14, 14, CAST(0.00 AS Decimal(10, 2)), CAST(N'2026-03-17T10:18:52.0000000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[InstructorWallets] OFF
GO
SET IDENTITY_INSERT [dbo].[KeyWords] ON 
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (2, N'靠北', -1, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (3, N'醜八怪', -1, 4)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (5, N'專業', 1, 1)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (6, N'白癡', -1, 5)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (8, N'感謝教練', 1, 2)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (9, N'非常', 0, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (11, N'教練', 0, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (12, N'推薦', 1, 2)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (13, N'我的', 0, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (14, N'大推薦', 1, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (15, N'超推', 1, 2)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (16, N'收穫', 0, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (17, N'菜單', 0, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (18, N'推薦給大家', 1, 1)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (19, N'後一定會再', 0, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (20, N'根本', 0, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (21, N'執行', 0, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (22, N'更有', 0, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (23, N'超乎', 0, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (24, N'了我的', 0, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (25, N'期待', 0, 3)
GO
INSERT [dbo].[KeyWords] ([Id], [Word], [Category], [Weight]) VALUES (26, N'花得很值得', 0, 3)
GO
SET IDENTITY_INSERT [dbo].[KeyWords] OFF
GO
SET IDENTITY_INSERT [dbo].[Members] ON 
GO
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (1, 1, 2, CAST(N'1995-03-15T00:00:00.0000000' AS DateTime2), 58, 163, N'輕度活動', N'維持體重', NULL, NULL, NULL, 1)
GO
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (2, 2, 1, CAST(N'1990-07-22T00:00:00.0000000' AS DateTime2), 75, 178, N'中度活動', N'增肌', NULL, NULL, NULL, 1)
GO
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (3, 3, 2, CAST(N'1998-11-05T00:00:00.0000000' AS DateTime2), 52, 158, N'久坐', N'減重', NULL, NULL, NULL, 1)
GO
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (4, 11, 1, CAST(N'1993-04-10T00:00:00.0000000' AS DateTime2), 70, 175, N'中度活動', N'增肌', NULL, NULL, NULL, 1)
GO
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (5, 12, 2, CAST(N'1997-09-25T00:00:00.0000000' AS DateTime2), 54, 161, N'輕度活動', N'維持體重', NULL, NULL, NULL, 1)
GO
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (6, 13, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0)
GO
INSERT [dbo].[Members] ([Id], [UserId], [Gender], [DateOfBirth], [Weight], [Height], [ActivityLevel], [Target], [BMR], [TDEE], [ImageUrl], [CancelCount]) VALUES (7, 2052, 2, CAST(N'1999-06-27T21:04:12.0000000' AS DateTime2), 68, 180, N'中度活動', N'維持體重', 1500, 2200, N'/images/members/default.jpg', 0)
GO
SET IDENTITY_INSERT [dbo].[Members] OFF
GO
SET IDENTITY_INSERT [dbo].[MemberViolations] ON 
GO
INSERT [dbo].[MemberViolations] ([Id], [MemberId], [WarningCount], [IsSuspended], [LastWarningAt], [SuspendedAt], [Reason]) VALUES (1, 1, 1, 0, CAST(N'2026-03-16T15:09:09.0000000' AS DateTime2), CAST(N'2026-03-16T15:10:00.0000000' AS DateTime2), N'惡意評論被管理員封鎖')
GO
INSERT [dbo].[MemberViolations] ([Id], [MemberId], [WarningCount], [IsSuspended], [LastWarningAt], [SuspendedAt], [Reason]) VALUES (2, 2, 3, 0, CAST(N'2026-03-16T11:54:14.0000000' AS DateTime2), NULL, N'惡意評論被管理員封鎖')
GO
INSERT [dbo].[MemberViolations] ([Id], [MemberId], [WarningCount], [IsSuspended], [LastWarningAt], [SuspendedAt], [Reason]) VALUES (3, 3, 5, 1, CAST(N'2026-03-16T15:18:29.0000000' AS DateTime2), CAST(N'2026-03-16T15:27:08.0000000' AS DateTime2), N'沒禮貌')
GO
INSERT [dbo].[MemberViolations] ([Id], [MemberId], [WarningCount], [IsSuspended], [LastWarningAt], [SuspendedAt], [Reason]) VALUES (4, 12, 1, 0, CAST(N'2026-04-01T09:39:18.0000000' AS DateTime2), NULL, N'惡意評論被管理員封鎖')
GO
SET IDENTITY_INSERT [dbo].[MemberViolations] OFF
GO
SET IDENTITY_INSERT [dbo].[Notifications] ON 
GO
INSERT [dbo].[Notifications] ([Id], [UserId], [SenderId], [NotifyType], [Title], [Content], [IsRead], [ReferenceId], [CreatedAt]) VALUES (1, 1014, 2014, N'Report', N'【系統警示】評價檢舉通知', N'營養師 ins1 檢舉了一則不當評價，請盡速前往後台評價管理區審核。', 1, 3, CAST(N'2026-03-11T16:32:30.0000000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[Notifications] OFF
GO
SET IDENTITY_INSERT [dbo].[PointOrders] ON 
GO
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (1, 1, 3, CAST(N'2026-03-11T14:51:48.5266667' AS DateTime2), 5, CAST(5000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)), 2)
GO
INSERT [dbo].[PointOrders] ([Id], [MemberId], [TopUpPlanId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice], [Status]) VALUES (2, 2, 2, CAST(N'2026-03-11T14:51:48.5266667' AS DateTime2), 2, CAST(2000 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), 3)
GO
SET IDENTITY_INSERT [dbo].[PointOrders] OFF
GO
SET IDENTITY_INSERT [dbo].[ProductCategories] ON 
GO
INSERT [dbo].[ProductCategories] ([Id], [CategoryName], [SortOrder], [IsActive]) VALUES (1, N'雞胸肉', 1, 1)
GO
INSERT [dbo].[ProductCategories] ([Id], [CategoryName], [SortOrder], [IsActive]) VALUES (2, N'蛋白粉', 2, 1)
GO
INSERT [dbo].[ProductCategories] ([Id], [CategoryName], [SortOrder], [IsActive]) VALUES (3, N'各種維生素', 3, 1)
GO
INSERT [dbo].[ProductCategories] ([Id], [CategoryName], [SortOrder], [IsActive]) VALUES (4, N'便當盒', 4, 1)
GO
SET IDENTITY_INSERT [dbo].[ProductCategories] OFF
GO
SET IDENTITY_INSERT [dbo].[Products] ON 
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (1, 1, N'經典原味舒肥雞胸肉', N'/images/products/chicken_01.jpg', CAST(120 AS Decimal(18, 0)), CAST(99 AS Decimal(18, 0)), N'鮮嫩多汁，低脂高蛋白，無過多調味', 1, 0)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (2, 1, N'黑胡椒海鹽雞胸肉', N'/images/products/chicken_02.jpg', CAST(120 AS Decimal(18, 0)), CAST(99 AS Decimal(18, 0)), N'使用天然海鹽與粗粒黑胡椒，經典百搭', 2, 1)
GO
SET IDENTITY_INSERT [dbo].[Products] OFF
GO
SET IDENTITY_INSERT [dbo].[ReserveOrders] ON 
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (4, 2, 10, CAST(N'2026-03-08T13:50:13.0000000' AS DateTime2), N'已完成', N'信用卡', N'體重管理與外食挑選建議', NULL, CAST(1200.00 AS Decimal(10, 2)), N'建議減少精緻澱粉，多攝取蔬菜')
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (5, 91, 1, CAST(N'2026-03-01T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (6, 83, 76, CAST(N'2025-10-15T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (7, 67, 77, CAST(N'2025-12-13T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (8, 82, 78, CAST(N'2025-10-21T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (9, 85, 79, CAST(N'2025-09-26T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (10, 65, 80, CAST(N'2026-03-09T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (11, 35, 81, CAST(N'2026-02-08T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (12, 76, 82, CAST(N'2025-12-23T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (13, 68, 83, CAST(N'2026-02-23T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (14, 17, 84, CAST(N'2026-01-07T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (15, 57, 85, CAST(N'2025-12-03T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (16, 2, 86, CAST(N'2025-12-13T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (17, 99, 87, CAST(N'2026-01-19T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (18, 15, 88, CAST(N'2025-09-13T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (19, 99, 89, CAST(N'2026-02-12T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (20, 74, 90, CAST(N'2025-12-05T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (21, 19, 91, CAST(N'2025-11-04T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (22, 28, 92, CAST(N'2025-12-25T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (23, 62, 93, CAST(N'2025-11-25T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (24, 27, 94, CAST(N'2025-12-01T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (25, 90, 95, CAST(N'2026-02-17T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (26, 62, 96, CAST(N'2026-02-23T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (27, 23, 97, CAST(N'2026-02-13T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (28, 30, 98, CAST(N'2026-01-21T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (29, 14, 99, CAST(N'2026-03-07T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (30, 59, 100, CAST(N'2025-09-25T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (31, 95, 101, CAST(N'2026-01-19T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (32, 104, 102, CAST(N'2026-02-23T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (33, 27, 103, CAST(N'2025-11-26T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (34, 67, 104, CAST(N'2025-10-23T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (35, 71, 105, CAST(N'2026-01-29T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (36, 71, 106, CAST(N'2026-02-17T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (37, 81, 107, CAST(N'2025-12-19T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (38, 38, 108, CAST(N'2026-02-23T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (39, 53, 109, CAST(N'2025-10-14T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (40, 102, 110, CAST(N'2026-01-29T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (41, 52, 111, CAST(N'2025-12-06T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (42, 91, 112, CAST(N'2026-02-20T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (43, 47, 113, CAST(N'2025-11-29T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (44, 4, 114, CAST(N'2025-10-16T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (45, 54, 115, CAST(N'2025-11-26T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (46, 13, 116, CAST(N'2026-01-03T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (47, 5, 117, CAST(N'2025-12-27T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (48, 9, 118, CAST(N'2026-01-15T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (49, 42, 119, CAST(N'2026-02-06T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (50, 86, 120, CAST(N'2025-09-21T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (51, 57, 121, CAST(N'2026-02-11T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (52, 58, 122, CAST(N'2026-02-24T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (53, 46, 123, CAST(N'2025-12-10T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (54, 10, 124, CAST(N'2025-10-16T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (55, 23, 125, CAST(N'2025-11-05T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (56, 22, 126, CAST(N'2026-01-26T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (57, 86, 127, CAST(N'2026-01-04T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (58, 42, 128, CAST(N'2025-10-11T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (59, 82, 129, CAST(N'2025-10-22T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (60, 76, 130, CAST(N'2025-09-13T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (61, 82, 131, CAST(N'2025-10-22T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (62, 47, 132, CAST(N'2025-10-01T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (63, 57, 133, CAST(N'2025-10-01T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (64, 75, 134, CAST(N'2026-01-30T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (65, 65, 135, CAST(N'2026-01-18T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (66, 11, 136, CAST(N'2025-10-26T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (67, 54, 137, CAST(N'2025-10-06T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (68, 87, 138, CAST(N'2025-09-30T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (69, 50, 139, CAST(N'2025-10-05T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (70, 16, 140, CAST(N'2025-12-18T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (71, 88, 141, CAST(N'2025-12-23T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (72, 92, 142, CAST(N'2026-03-06T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (73, 104, 143, CAST(N'2026-01-12T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (74, 53, 144, CAST(N'2025-09-18T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (75, 103, 145, CAST(N'2025-10-26T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (76, 6, 146, CAST(N'2025-09-25T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (77, 40, 147, CAST(N'2025-10-29T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (78, 3, 148, CAST(N'2025-10-03T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (79, 102, 149, CAST(N'2025-12-02T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (80, 15, 150, CAST(N'2025-10-01T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (81, 78, 151, CAST(N'2025-10-03T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (82, 26, 152, CAST(N'2025-11-02T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (83, 36, 153, CAST(N'2025-10-16T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (84, 39, 154, CAST(N'2026-03-06T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (85, 95, 155, CAST(N'2025-09-16T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (86, 3, 156, CAST(N'2026-01-19T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (87, 9, 157, CAST(N'2026-03-08T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (88, 49, 158, CAST(N'2025-10-19T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (89, 8, 159, CAST(N'2025-12-23T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (90, 65, 160, CAST(N'2025-11-29T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (91, 83, 161, CAST(N'2025-12-25T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (92, 93, 162, CAST(N'2026-01-20T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (93, 40, 163, CAST(N'2026-01-25T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (94, 64, 164, CAST(N'2026-03-02T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (95, 15, 165, CAST(N'2025-11-03T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (96, 89, 166, CAST(N'2025-11-10T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (97, 68, 167, CAST(N'2026-02-27T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (98, 40, 168, CAST(N'2026-01-17T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (99, 65, 169, CAST(N'2026-02-23T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (100, 52, 170, CAST(N'2025-12-10T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (101, 54, 171, CAST(N'2025-10-04T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (102, 91, 172, CAST(N'2025-10-05T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (103, 86, 173, CAST(N'2025-09-23T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (104, 87, 174, CAST(N'2025-10-25T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (105, 43, 175, CAST(N'2025-12-23T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (106, 97, 176, CAST(N'2025-11-12T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (107, 49, 177, CAST(N'2025-11-18T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (108, 9, 178, CAST(N'2025-10-10T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (109, 101, 179, CAST(N'2025-11-29T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (110, 8, 180, CAST(N'2026-03-03T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (111, 19, 181, CAST(N'2025-09-15T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (112, 2, 182, CAST(N'2025-12-07T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (113, 21, 183, CAST(N'2026-02-25T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (114, 82, 184, CAST(N'2026-01-03T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (115, 58, 185, CAST(N'2025-12-09T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (116, 66, 186, CAST(N'2025-12-04T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (117, 92, 187, CAST(N'2026-01-23T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (118, 89, 188, CAST(N'2026-03-08T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (119, 88, 189, CAST(N'2025-10-18T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (120, 103, 190, CAST(N'2025-11-28T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (121, 60, 191, CAST(N'2025-12-09T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (122, 32, 192, CAST(N'2026-01-12T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (123, 105, 193, CAST(N'2025-12-16T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (124, 97, 194, CAST(N'2026-01-24T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (125, 92, 195, CAST(N'2026-01-12T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (126, 82, 196, CAST(N'2025-10-29T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (127, 30, 197, CAST(N'2025-10-14T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (128, 25, 198, CAST(N'2025-10-20T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (129, 65, 199, CAST(N'2026-01-25T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (130, 46, 200, CAST(N'2025-11-04T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (131, 44, 201, CAST(N'2025-10-17T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (132, 33, 202, CAST(N'2025-10-03T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (133, 22, 203, CAST(N'2025-11-24T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (134, 105, 204, CAST(N'2026-01-20T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (135, 83, 205, CAST(N'2025-12-07T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (136, 70, 206, CAST(N'2026-01-04T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (137, 65, 207, CAST(N'2025-10-04T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (138, 97, 208, CAST(N'2026-02-15T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (139, 25, 209, CAST(N'2025-10-06T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (140, 51, 210, CAST(N'2025-09-25T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (141, 96, 211, CAST(N'2025-11-29T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (142, 69, 212, CAST(N'2025-12-10T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (143, 9, 213, CAST(N'2026-01-13T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (144, 65, 214, CAST(N'2025-09-24T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (145, 56, 215, CAST(N'2025-12-17T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (146, 3, 216, CAST(N'2025-09-30T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (147, 60, 217, CAST(N'2025-11-12T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (148, 70, 218, CAST(N'2026-01-28T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (149, 45, 219, CAST(N'2025-11-11T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (150, 95, 220, CAST(N'2025-11-04T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (151, 51, 221, CAST(N'2025-11-03T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (152, 89, 222, CAST(N'2025-11-10T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (153, 56, 223, CAST(N'2025-09-28T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (154, 102, 224, CAST(N'2026-02-17T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (155, 14, 225, CAST(N'2026-02-14T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (156, 68, 226, CAST(N'2026-02-04T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (157, 90, 227, CAST(N'2026-01-19T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (158, 7, 228, CAST(N'2025-09-16T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (159, 90, 229, CAST(N'2025-09-30T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (160, 69, 230, CAST(N'2025-11-27T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (161, 73, 231, CAST(N'2026-02-12T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (162, 56, 232, CAST(N'2025-09-26T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (163, 73, 233, CAST(N'2025-11-26T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (164, 45, 234, CAST(N'2025-10-23T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (165, 3, 235, CAST(N'2025-10-27T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (166, 61, 236, CAST(N'2025-09-30T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (167, 55, 237, CAST(N'2026-02-09T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (168, 81, 238, CAST(N'2025-12-12T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (169, 48, 239, CAST(N'2025-12-17T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (170, 105, 240, CAST(N'2025-12-15T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (171, 55, 241, CAST(N'2025-11-02T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (172, 49, 242, CAST(N'2025-11-20T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (173, 82, 243, CAST(N'2025-12-06T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (174, 51, 244, CAST(N'2026-01-23T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (175, 19, 245, CAST(N'2026-01-12T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (176, 19, 246, CAST(N'2025-10-28T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (177, 72, 247, CAST(N'2025-10-17T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (178, 17, 248, CAST(N'2026-01-28T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (179, 63, 249, CAST(N'2025-09-22T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (180, 67, 250, CAST(N'2026-01-27T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (181, 97, 251, CAST(N'2025-11-18T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (182, 106, 252, CAST(N'2025-10-20T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (183, 23, 253, CAST(N'2025-10-20T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (184, 80, 254, CAST(N'2026-02-07T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (185, 65, 255, CAST(N'2025-09-13T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (186, 88, 256, CAST(N'2026-02-19T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (187, 84, 257, CAST(N'2025-10-25T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (188, 54, 258, CAST(N'2025-12-07T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (189, 6, 259, CAST(N'2025-10-12T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (190, 73, 260, CAST(N'2025-10-16T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (191, 31, 261, CAST(N'2026-02-03T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (192, 48, 262, CAST(N'2026-03-08T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (193, 71, 263, CAST(N'2026-01-04T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (194, 11, 264, CAST(N'2026-02-19T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (195, 19, 265, CAST(N'2025-12-24T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (196, 22, 266, CAST(N'2026-02-07T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (197, 19, 267, CAST(N'2025-12-16T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (198, 63, 268, CAST(N'2026-01-06T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (199, 84, 269, CAST(N'2025-10-21T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (200, 99, 270, CAST(N'2026-01-24T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (201, 73, 271, CAST(N'2026-01-31T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (202, 41, 272, CAST(N'2026-01-01T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (203, 80, 273, CAST(N'2025-11-06T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (204, 97, 274, CAST(N'2026-02-12T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (205, 28, 275, CAST(N'2026-03-09T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (206, 65, 276, CAST(N'2026-03-02T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (207, 67, 277, CAST(N'2026-02-27T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (208, 98, 278, CAST(N'2026-02-28T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (209, 22, 279, CAST(N'2026-03-10T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (210, 53, 280, CAST(N'2026-03-10T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (211, 90, 281, CAST(N'2026-03-06T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (212, 92, 282, CAST(N'2026-03-05T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (213, 74, 283, CAST(N'2026-03-05T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (214, 60, 284, CAST(N'2026-03-12T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (215, 91, 285, CAST(N'2026-03-17T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (216, 12, 286, CAST(N'2026-03-12T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (217, 69, 287, CAST(N'2026-03-05T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (218, 31, 288, CAST(N'2026-03-16T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, NULL, CAST(1200.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (219, 67, 289, CAST(N'2026-03-14T00:00:00.0000000' AS DateTime2), N'已完成', N'信用卡', NULL, 800, NULL, NULL)
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (220, 103, 290, CAST(N'2026-03-13T00:00:00.0000000' AS DateTime2), N'已完成', N'點數', NULL, 800, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[ReserveOrders] OFF
GO
SET IDENTITY_INSERT [dbo].[Reviews] ON 
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (3, 4, 2, 2, 5, N'李營養師非常專業，給了很具體的外食建議，非常感謝！', CAST(N'2026-03-08T13:50:13.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (4, 5, 1, 1, 4, N'講解得很清楚，但希望能多提供一些超商能買到的具體品項建議。', CAST(N'2026-03-08T13:50:13.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (5, 6, 5, 83, 3, N'跟預期不一樣，回答比較保守。可能需要多點客製化。', CAST(N'2025-10-25T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (6, 7, 7, 67, 1, N'浪費我的時間，菜單根本不能吃。爛到笑出來。', CAST(N'2025-12-22T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (7, 8, 4, 82, 5, N'非常感謝指導，不只給方法還給滿滿鼓勵。收穫非常多。 神仙教練！', CAST(N'2025-10-30T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (8, 9, 11, 85, 4, N'超級用心！給了很好的調整方向。絕對五星好評！ 錢花得很值得！', CAST(N'2025-10-04T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (9, 10, 4, 65, 5, N'收穫超乎預期，菜單很符合作息。準備好開始執行了！ 超推！', CAST(N'2026-03-17T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (10, 11, 5, 35, 5, N'收穫超乎預期，讓我清楚營養素分配。更有動力了！', CAST(N'2026-02-16T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (11, 12, 5, 76, 4, N'教練非常專業，給的建議超實用。期待下次的諮詢。 超推！', CAST(N'2026-01-01T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (12, 13, 6, 68, 1, N'長那什麼醜八怪樣子，完全不聽我的需求。一星都不想給。 態度極差！', CAST(N'2026-03-05T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (13, 14, 9, 17, 5, N'講解非常詳細，給的建議超實用。準備好開始執行了！ 錢花得很值得！', CAST(N'2026-01-15T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (14, 15, 11, 57, 3, N'稍微可惜，外食部分講得比較少。這點滿可惜的。 普普。', CAST(N'2025-12-11T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (15, 16, 13, 2, 4, N'完全命中問題，細心客製化了我的計畫。絕對五星好評！ 大推薦！', CAST(N'2025-12-21T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (16, 17, 5, 99, 2, N'超級不專業，上課還在看手機。氣到發抖。 智商稅！', CAST(N'2026-01-28T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (17, 18, 11, 15, 3, N'不太符合期待，建議不太好執行。或許不太適合我。 沒感覺。', CAST(N'2025-09-22T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (18, 19, 8, 99, 4, N'完全命中問題，提供很多超商就能買的選擇。更有動力了！', CAST(N'2026-02-20T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (19, 20, 2, 74, 5, N'態度很親切，解答了我的盲點。更有動力了！ 錢花得很值得！', CAST(N'2025-12-15T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (20, 21, 2, 19, 3, N'跟預期不一樣，外食部分講得比較少。算是買個經驗。 普普。', CAST(N'2025-11-12T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (21, 22, 3, 28, 5, N'教練非常專業，菜單很符合作息。之後一定會再預約。 神仙教練！', CAST(N'2026-01-02T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (22, 23, 9, 62, 5, N'非常感謝指導，菜單很符合作息。準備好開始執行了！ 感謝教練！', CAST(N'2025-12-03T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (23, 24, 2, 27, 3, N'跟預期不一樣，沒有完全針對我的狀況。或許不太適合我。', CAST(N'2025-12-09T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (24, 25, 9, 90, 4, N'態度很親切，不只給方法還給滿滿鼓勵。超乎想像的好！ 錢花得很值得！', CAST(N'2026-02-25T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (25, 26, 1, 62, 3, N'不太符合期待，沒有完全針對我的狀況。算是買個經驗。 沒感覺。', CAST(N'2026-03-05T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (26, 27, 7, 23, 1, N'遇到這教練真倒楣，只會一直推銷課程。一星都不想給。 根本在騙錢！', CAST(N'2026-02-21T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (27, 28, 9, 30, 5, N'非常感謝指導，給的建議超實用。準備好開始執行了！', CAST(N'2026-01-29T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (28, 29, 14, 14, 1, N'有夠敷衍，講廢話就下課了。這種素質也能當教練？ 根本在騙錢！', CAST(N'2026-03-15T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (29, 30, 11, 59, 3, N'整體普普通通，講的東西大概都知道了。就這樣吧。 沒感覺。', CAST(N'2025-10-03T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (30, 31, 3, 95, 4, N'教練非常專業，破解了減脂迷思。馬上推薦給朋友。 超推！', CAST(N'2026-01-27T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (31, 32, 14, 104, 5, N'態度很親切，給的建議超實用。馬上推薦給朋友。 神仙教練！', CAST(N'2026-03-03T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (32, 33, 4, 27, 4, N'很喜歡這位營養師，提供很多超商就能買的選擇。超乎想像的好！', CAST(N'2025-12-04T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (33, 34, 10, 67, 3, N'稍微可惜，時間掌控上可再好一點。或許不太適合我。 勉強給過。', CAST(N'2025-10-31T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (34, 35, 3, 71, 4, N'態度很親切，解答了我的盲點。之後一定會再預約。 大推薦！', CAST(N'2026-02-06T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (35, 36, 9, 71, 2, N'長那什麼醜八怪樣子，上課還在看手機。快點逃啊各位。 態度極差！', CAST(N'2026-02-25T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (36, 37, 12, 81, 4, N'真的很棒，提供很多超商就能買的選擇。絕對五星好評！', CAST(N'2025-12-28T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (37, 38, 5, 38, 3, N'不太符合期待，回答比較保守。希望下次能更好。', CAST(N'2026-03-04T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (38, 39, 3, 53, 5, N'收穫超乎預期，給了很好的調整方向。更有動力了！ 感謝教練！', CAST(N'2025-10-24T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (39, 40, 13, 102, 2, N'長那什麼醜八怪樣子，這點程度也敢出來教。退錢啦！ 態度極差！', CAST(N'2026-02-08T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (40, 41, 8, 52, 5, N'教練非常專業，破解了減脂迷思。之後一定會再預約。 大推薦！', CAST(N'2025-12-14T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (41, 42, 8, 91, 4, N'真的很棒，破解了減脂迷思。準備好開始執行了！ 感謝教練！', CAST(N'2026-03-01T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (42, 43, 4, 47, 5, N'這堂課太有價值，菜單很符合作息。馬上推薦給朋友。', CAST(N'2025-12-07T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (43, 44, 2, 4, 4, N'超級用心！解答了我的盲點。真心推薦給大家。 感謝教練！', CAST(N'2025-10-26T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (44, 45, 7, 54, 5, N'很喜歡這位營養師，解答了我的盲點。更有動力了！ 大推薦！', CAST(N'2025-12-04T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (45, 46, 13, 13, 4, N'完全命中問題，解答了我的盲點。收穫非常多。 感謝教練！', CAST(N'2026-01-13T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (46, 47, 6, 5, 2, N'超級不專業，連營養素都算錯。這種素質也能當教練？ 態度極差！', CAST(N'2026-01-06T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (47, 48, 5, 9, 3, N'有進步空間，外食部分講得比較少。當作參考囉。 勉強給過。', CAST(N'2026-01-23T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (48, 49, 10, 42, 4, N'收穫超乎預期，破解了減脂迷思。太喜歡這模式了！ 超推！', CAST(N'2026-02-14T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (49, 50, 7, 86, 5, N'超級用心！讓我清楚營養素分配。絕對五星好評！ 感謝教練！', CAST(N'2025-10-01T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (50, 51, 6, 57, 4, N'超級用心！提供很多超商就能買的選擇。絕對五星好評！ 超推！', CAST(N'2026-02-19T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (51, 52, 3, 58, 4, N'教練非常專業，對接下來備餐更有頭緒。收穫非常多。 大推薦！', CAST(N'2026-03-05T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (52, 53, 1, 46, 2, N'氣死我了，這點程度也敢出來教。瞎了眼才買這堂課。', CAST(N'2025-12-18T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (53, 54, 8, 10, 5, N'這堂課太有價值，解答了我的盲點。期待下次的諮詢。', CAST(N'2025-10-24T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (54, 55, 12, 23, 3, N'跟預期不一樣，回答比較保守。不知道怎麼給評。 表現中規中矩。', CAST(N'2025-11-14T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (55, 56, 13, 22, 5, N'很喜歡這位營養師，讓我清楚營養素分配。真心推薦給大家。', CAST(N'2026-02-03T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (56, 57, 7, 86, 5, N'態度很親切，讓我清楚營養素分配。期待下次的諮詢。 錢花得很值得！', CAST(N'2026-01-14T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (57, 58, 3, 42, 5, N'很喜歡這位營養師，提供很多超商就能買的選擇。期待下次的諮詢。 神仙教練！', CAST(N'2025-10-21T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (58, 59, 4, 82, 1, N'這什麼白癡建議，這點程度也敢出來教。一星都不想給。 智商稅！', CAST(N'2025-11-01T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (59, 60, 1, 76, 2, N'長那什麼醜八怪樣子，連營養素都算錯。大家千萬別踩坑。 根本在騙錢！', CAST(N'2025-09-21T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (60, 61, 7, 82, 5, N'態度很親切，不只給方法還給滿滿鼓勵。期待下次的諮詢。 錢花得很值得！', CAST(N'2025-11-01T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (61, 62, 1, 47, 3, N'跟預期不一樣，外食部分講得比較少。希望之後能改善。 普普。', CAST(N'2025-10-10T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (62, 63, 11, 57, 4, N'非常感謝指導，不只給方法還給滿滿鼓勵。真心推薦給大家。', CAST(N'2025-10-10T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (63, 64, 6, 75, 5, N'非常感謝指導，對接下來備餐更有頭緒。太喜歡這模式了！ 感謝教練！', CAST(N'2026-02-08T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (64, 65, 3, 65, 1, N'有夠敷衍，只會一直推銷課程。氣到發抖。 避雷！', CAST(N'2026-01-26T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (65, 66, 11, 11, 4, N'教練非常專業，解答了我的盲點。絕對五星好評！ 大推薦！', CAST(N'2025-11-04T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (66, 67, 4, 54, 4, N'非常感謝指導，不只給方法還給滿滿鼓勵。準備好開始執行了！ 大推薦！', CAST(N'2025-10-16T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (67, 68, 9, 87, 2, N'體驗極差，這點程度也敢出來教。瞎了眼才買這堂課。 態度極差！', CAST(N'2025-10-09T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (68, 69, 7, 50, 4, N'講解非常詳細，不只給方法還給滿滿鼓勵。絕對五星好評！ 感謝教練！', CAST(N'2025-10-14T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (69, 70, 2, 16, 3, N'有進步空間，時間掌控上可再好一點。或許不太適合我。 表現中規中矩。', CAST(N'2025-12-27T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (70, 71, 9, 88, 1, N'體驗極差，連營養素都算錯。退錢啦！', CAST(N'2026-01-02T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (71, 72, 12, 92, 4, N'很喜歡這位營養師，對接下來備餐更有頭緒。收穫非常多。', CAST(N'2026-03-15T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (72, 73, 7, 104, 3, N'不太符合期待，互動感覺偏制式化。算是買個經驗。 普普。', CAST(N'2026-01-20T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (73, 74, 6, 53, 5, N'態度很親切，給的建議超實用。準備好開始執行了！ 感謝教練！', CAST(N'2025-09-27T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (74, 75, 13, 103, 5, N'超級用心！細心客製化了我的計畫。更有動力了！', CAST(N'2025-11-04T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (75, 76, 9, 6, 2, N'浪費我的時間，態度跩個二五八萬。準備被投訴吧。 態度極差！', CAST(N'2025-10-04T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (76, 77, 11, 40, 2, N'長那什麼醜八怪樣子，只會一直推銷課程。瞎了眼才買這堂課。 智商稅！', CAST(N'2025-11-06T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (77, 78, 5, 3, 4, N'非常感謝指導，讓我清楚營養素分配。期待下次的諮詢。 錢花得很值得！', CAST(N'2025-10-12T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (78, 79, 10, 102, 4, N'態度很親切，對接下來備餐更有頭緒。太喜歡這模式了！', CAST(N'2025-12-12T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (79, 80, 13, 15, 4, N'很喜歡這位營養師，讓我清楚營養素分配。準備好開始執行了！ 錢花得很值得！', CAST(N'2025-10-11T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (80, 81, 14, 78, 1, N'浪費我的時間，講廢話就下課了。退錢啦！ 態度極差！', CAST(N'2025-10-11T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (81, 82, 3, 26, 3, N'跟預期不一樣，希望多給實際的例子。這點滿可惜的。 普普。', CAST(N'2025-11-11T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (82, 83, 6, 36, 5, N'態度很親切，給了很好的調整方向。準備好開始執行了！ 大推薦！', CAST(N'2025-10-25T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (83, 84, 5, 39, 4, N'教練非常專業，提供很多超商就能買的選擇。準備好開始執行了！ 大推薦！', CAST(N'2026-03-14T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (84, 85, 5, 95, 2, N'遇到這教練真倒楣，這點程度也敢出來教。準備被投訴吧。 避雷！', CAST(N'2025-09-26T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (85, 86, 2, 3, 4, N'超級用心！破解了減脂迷思。絕對五星好評！ 錢花得很值得！', CAST(N'2026-01-27T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (86, 87, 13, 9, 2, N'體驗極差，問問題都不想回。退錢啦！ 避雷！', CAST(N'2026-03-16T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (87, 88, 7, 49, 3, N'表現平平，菜單變化比較少。算是買個經驗。', CAST(N'2025-10-27T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (88, 89, 14, 8, 1, N'靠北，連營養素都算錯。爛到笑出來。 智商稅！', CAST(N'2026-01-01T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (89, 90, 6, 65, 3, N'跟預期不一樣，時間掌控上可再好一點。這點滿可惜的。 普普。', CAST(N'2025-12-08T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (90, 91, 8, 83, 5, N'很喜歡這位營養師，菜單很符合作息。更有動力了！ 感謝教練！', CAST(N'2026-01-03T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (91, 92, 6, 93, 4, N'真的很棒，給的建議超實用。超乎想像的好！', CAST(N'2026-01-29T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (92, 93, 1, 40, 5, N'很喜歡這位營養師，提供很多超商就能買的選擇。期待下次的諮詢。 大推薦！', CAST(N'2026-02-04T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (93, 94, 14, 64, 1, N'遇到這教練真倒楣，問問題都不想回。這種素質也能當教練？ 避雷！', CAST(N'2026-03-12T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (94, 95, 4, 15, 2, N'爛透了，上課還在看手機。大家千萬別踩坑。 態度極差！', CAST(N'2025-11-12T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (95, 96, 5, 89, 5, N'講解非常詳細，解答了我的盲點。之後一定會再預約。', CAST(N'2025-11-18T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (96, 97, 8, 68, 4, N'教練非常專業，菜單很符合作息。太喜歡這模式了！', CAST(N'2026-03-09T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (97, 98, 11, 40, 4, N'教練非常專業，不只給方法還給滿滿鼓勵。絕對五星好評！ 感謝教練！', CAST(N'2026-01-26T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (98, 99, 7, 65, 1, N'氣死我了，講廢話就下課了。退錢啦！ 避雷！', CAST(N'2026-03-04T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (99, 100, 5, 52, 3, N'跟預期不一樣，菜單變化比較少。希望下次能更好。 普普。', CAST(N'2025-12-19T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (100, 101, 9, 54, 4, N'完全命中問題，給的建議超實用。期待下次的諮詢。 大推薦！', CAST(N'2025-10-13T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (101, 102, 11, 91, 5, N'講解非常詳細，細心客製化了我的計畫。真心推薦給大家。 神仙教練！', CAST(N'2025-10-15T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (102, 103, 9, 86, 4, N'很喜歡這位營養師，給了很好的調整方向。太喜歡這模式了！', CAST(N'2025-10-02T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (103, 104, 14, 87, 4, N'完全命中問題，對接下來備餐更有頭緒。真心推薦給大家。 感謝教練！', CAST(N'2025-11-04T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (104, 105, 8, 43, 2, N'浪費我的時間，問問題都不想回。大家千萬別踩坑。 避雷！', CAST(N'2026-01-01T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (105, 106, 9, 97, 1, N'長那什麼醜八怪樣子，講廢話就下課了。這種素質也能當教練？ 避雷！', CAST(N'2025-11-20T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (106, 107, 8, 49, 4, N'很喜歡這位營養師，給的建議超實用。馬上推薦給朋友。 神仙教練！', CAST(N'2025-11-28T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (107, 108, 10, 9, 4, N'講解非常詳細，給的建議超實用。更有動力了！ 大推薦！', CAST(N'2025-10-20T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (108, 109, 5, 101, 5, N'超級用心！解答了我的盲點。之後一定會再預約。 錢花得很值得！', CAST(N'2025-12-09T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (109, 110, 1, 8, 5, N'收穫超乎預期，提供很多超商就能買的選擇。更有動力了！ 感謝教練！', CAST(N'2026-03-13T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (110, 111, 9, 19, 1, N'長那什麼醜八怪樣子，講廢話就下課了。退錢啦！', CAST(N'2025-09-25T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (111, 112, 12, 2, 5, N'態度很親切，破解了減脂迷思。更有動力了！ 錢花得很值得！', CAST(N'2025-12-16T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (112, 113, 11, 21, 2, N'氣死我了，完全不聽我的需求。氣到發抖。 避雷！', CAST(N'2026-03-07T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (113, 114, 1, 82, 3, N'感覺還好，外食部分講得比較少。算是買個經驗。 沒感覺。', CAST(N'2026-01-13T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (114, 115, 14, 58, 4, N'教練非常專業，對接下來備餐更有頭緒。準備好開始執行了！ 大推薦！', CAST(N'2025-12-19T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (115, 116, 10, 66, 5, N'教練非常專業，提供很多超商就能買的選擇。之後一定會再預約。 神仙教練！', CAST(N'2025-12-13T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (116, 117, 6, 92, 5, N'教練非常專業，解答了我的盲點。太喜歡這模式了！', CAST(N'2026-02-01T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (117, 118, 6, 89, 4, N'這堂課太有價值，不只給方法還給滿滿鼓勵。超乎想像的好！ 大推薦！', CAST(N'2026-03-17T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (118, 119, 9, 88, 1, N'有夠敷衍，講廢話就下課了。一星都不想給。 智商稅！', CAST(N'2025-10-28T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (119, 120, 4, 103, 2, N'這什麼白癡建議，連營養素都算錯。爛到笑出來。 根本在騙錢！', CAST(N'2025-12-08T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (120, 121, 12, 60, 1, N'超級不專業，只會一直推銷課程。準備被投訴吧。 根本在騙錢！', CAST(N'2025-12-17T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (121, 122, 4, 32, 1, N'超級不專業，菜單根本不能吃。瞎了眼才買這堂課。 根本在騙錢！', CAST(N'2026-01-22T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (122, 123, 14, 105, 4, N'完全命中問題，給的建議超實用。收穫非常多。', CAST(N'2025-12-24T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (123, 124, 4, 97, 5, N'非常感謝指導，提供很多超商就能買的選擇。絕對五星好評！ 神仙教練！', CAST(N'2026-02-03T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (124, 125, 14, 92, 4, N'非常感謝指導，解答了我的盲點。絕對五星好評！ 神仙教練！', CAST(N'2026-01-20T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (125, 126, 1, 82, 1, N'長那什麼醜八怪樣子，菜單根本不能吃。瞎了眼才買這堂課。 根本在騙錢！', CAST(N'2025-11-07T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (126, 127, 2, 30, 5, N'非常感謝指導，提供很多超商就能買的選擇。馬上推薦給朋友。 錢花得很值得！', CAST(N'2025-10-23T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (127, 128, 4, 25, 5, N'收穫超乎預期，細心客製化了我的計畫。絕對五星好評！', CAST(N'2025-10-28T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (128, 129, 10, 65, 1, N'爛透了，只會一直推銷課程。絕對不會再來！ 態度極差！', CAST(N'2026-02-04T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (129, 130, 10, 46, 4, N'講解非常詳細，給了很好的調整方向。更有動力了！', CAST(N'2025-11-14T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (130, 131, 5, 44, 3, N'有點小失望，外食部分講得比較少。可能需要多點客製化。 普普。', CAST(N'2025-10-25T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (131, 132, 13, 33, 4, N'完全命中問題，給的建議超實用。期待下次的諮詢。 感謝教練！', CAST(N'2025-10-13T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (132, 133, 14, 22, 5, N'講解非常詳細，提供很多超商就能買的選擇。太喜歡這模式了！ 神仙教練！', CAST(N'2025-12-02T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (133, 134, 3, 105, 5, N'很喜歡這位營養師，菜單很符合作息。超乎想像的好！ 錢花得很值得！', CAST(N'2026-01-29T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (134, 135, 4, 83, 4, N'完全命中問題，提供很多超商就能買的選擇。準備好開始執行了！ 超推！', CAST(N'2025-12-16T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (135, 136, 4, 70, 1, N'體驗極差，只會一直推銷課程。退錢啦！ 根本在騙錢！', CAST(N'2026-01-14T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (136, 137, 6, 65, 5, N'收穫超乎預期，對接下來備餐更有頭緒。期待下次的諮詢。 超推！', CAST(N'2025-10-12T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (137, 138, 3, 97, 4, N'這堂課太有價值，解答了我的盲點。之後一定會再預約。', CAST(N'2026-02-24T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (138, 139, 8, 25, 4, N'這堂課太有價值，提供很多超商就能買的選擇。之後一定會再預約。 錢花得很值得！', CAST(N'2025-10-14T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (139, 140, 4, 51, 4, N'很喜歡這位營養師，給的建議超實用。絕對五星好評！ 大推薦！', CAST(N'2025-10-03T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (140, 141, 4, 96, 4, N'完全命中問題，破解了減脂迷思。之後一定會再預約。', CAST(N'2025-12-08T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (141, 142, 11, 69, 3, N'算不錯但菜單變化比較少。希望下次能更好。 普普。', CAST(N'2025-12-19T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (142, 143, 6, 9, 4, N'完全命中問題，破解了減脂迷思。馬上推薦給朋友。 錢花得很值得！', CAST(N'2026-01-23T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (143, 144, 5, 65, 5, N'收穫超乎預期，解答了我的盲點。準備好開始執行了！ 感謝教練！', CAST(N'2025-10-03T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (144, 145, 11, 56, 5, N'態度很親切，不只給方法還給滿滿鼓勵。真心推薦給大家。', CAST(N'2025-12-26T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (145, 146, 5, 3, 4, N'真的很棒，給了很好的調整方向。超乎想像的好！ 感謝教練！', CAST(N'2025-10-10T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (146, 147, 2, 60, 1, N'氣死我了，上課還在看手機。準備被投訴吧。 智商稅！', CAST(N'2025-11-21T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (147, 148, 5, 70, 2, N'靠北，菜單根本不能吃。這種素質也能當教練？ 根本在騙錢！', CAST(N'2026-02-05T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (148, 149, 11, 45, 5, N'講解非常詳細，菜單很符合作息。真心推薦給大家。', CAST(N'2025-11-21T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (149, 150, 6, 95, 3, N'體驗一般般，沒有完全針對我的狀況。算是買個經驗。 勉強給過。', CAST(N'2025-11-12T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (150, 151, 1, 51, 4, N'很喜歡這位營養師，解答了我的盲點。收穫非常多。 錢花得很值得！', CAST(N'2025-11-12T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (151, 152, 7, 89, 2, N'超級不專業，態度跩個二五八萬。爛到笑出來。', CAST(N'2025-11-19T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (152, 153, 6, 56, 1, N'遇到這教練真倒楣，完全不聽我的需求。準備被投訴吧。 根本在騙錢！', CAST(N'2025-10-07T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (153, 154, 2, 102, 3, N'跟預期不一樣，回答比較保守。或許不太適合我。 表現中規中矩。', CAST(N'2026-02-26T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (154, 155, 7, 14, 5, N'教練非常專業，提供很多超商就能買的選擇。之後一定會再預約。 錢花得很值得！', CAST(N'2026-02-22T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (155, 156, 9, 68, 5, N'講解非常詳細，不只給方法還給滿滿鼓勵。收穫非常多。 超推！', CAST(N'2026-02-13T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (156, 157, 2, 90, 4, N'態度很親切，讓我清楚營養素分配。絕對五星好評！', CAST(N'2026-01-27T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (157, 158, 4, 7, 5, N'完全命中問題，對接下來備餐更有頭緒。收穫非常多。 超推！', CAST(N'2025-09-25T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (158, 159, 4, 90, 4, N'真的很棒，讓我清楚營養素分配。收穫非常多。 大推薦！', CAST(N'2025-10-09T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (159, 160, 4, 69, 5, N'講解非常詳細，破解了減脂迷思。真心推薦給大家。', CAST(N'2025-12-06T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (160, 161, 3, 73, 5, N'教練非常專業，讓我清楚營養素分配。超乎想像的好！ 感謝教練！', CAST(N'2026-02-21T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (161, 162, 9, 56, 1, N'遇到這教練真倒楣，這點程度也敢出來教。快點逃啊各位。 智商稅！', CAST(N'2025-10-04T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (162, 163, 12, 73, 1, N'長那什麼醜八怪樣子，只會一直推銷課程。氣到發抖。 智商稅！', CAST(N'2025-12-06T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (163, 164, 12, 45, 2, N'遇到這教練真倒楣，這點程度也敢出來教。爛到笑出來。 避雷！', CAST(N'2025-11-01T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (164, 165, 14, 3, 1, N'超級不專業，只會一直推銷課程。快點逃啊各位。 態度極差！', CAST(N'2025-11-04T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (165, 166, 3, 61, 4, N'這堂課太有價值，不只給方法還給滿滿鼓勵。準備好開始執行了！ 超推！', CAST(N'2025-10-10T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (166, 167, 7, 55, 4, N'超級用心！解答了我的盲點。絕對五星好評！ 神仙教練！', CAST(N'2026-02-17T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (167, 168, 1, 81, 4, N'完全命中問題，給了很好的調整方向。準備好開始執行了！ 感謝教練！', CAST(N'2025-12-21T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (168, 169, 3, 48, 3, N'體驗一般般，時間掌控上可再好一點。當作參考囉。', CAST(N'2025-12-26T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (169, 170, 5, 105, 3, N'算不錯但互動感覺偏制式化。再觀望看看好了。 表現中規中矩。', CAST(N'2025-12-23T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (170, 171, 2, 55, 2, N'靠北，這點程度也敢出來教。一星都不想給。 態度極差！', CAST(N'2025-11-11T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (171, 172, 9, 49, 4, N'這堂課太有價值，讓我清楚營養素分配。太喜歡這模式了！', CAST(N'2025-11-30T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (172, 173, 3, 82, 5, N'態度很親切，不只給方法還給滿滿鼓勵。準備好開始執行了！ 感謝教練！', CAST(N'2025-12-14T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (173, 174, 2, 51, 1, N'靠北，只會一直推銷課程。爛到笑出來。', CAST(N'2026-02-01T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (174, 175, 1, 19, 5, N'完全命中問題，給了很好的調整方向。馬上推薦給朋友。 大推薦！', CAST(N'2026-01-21T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (175, 176, 12, 19, 4, N'真的很棒，讓我清楚營養素分配。太喜歡這模式了！ 大推薦！', CAST(N'2025-11-05T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (176, 177, 4, 72, 2, N'體驗極差，問問題都不想回。這種素質也能當教練？ 智商稅！', CAST(N'2025-10-25T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (177, 178, 5, 17, 3, N'跟預期不一樣，沒有完全針對我的狀況。希望下次能更好。 沒感覺。', CAST(N'2026-02-07T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (178, 179, 1, 63, 3, N'不太符合期待，沒有完全針對我的狀況。就這樣吧。 普普。', CAST(N'2025-10-01T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (179, 180, 3, 67, 4, N'真的很棒，給的建議超實用。超乎想像的好！ 感謝教練！', CAST(N'2026-02-06T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (180, 181, 2, 97, 5, N'非常感謝指導，給的建議超實用。真心推薦給大家。 錢花得很值得！', CAST(N'2025-11-26T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (181, 182, 7, 106, 3, N'表現平平，時間掌控上可再好一點。這點滿可惜的。 沒感覺。', CAST(N'2025-10-29T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (182, 183, 7, 23, 4, N'超級用心！給的建議超實用。超乎想像的好！ 大推薦！', CAST(N'2025-10-28T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (183, 184, 7, 80, 4, N'非常感謝指導，不只給方法還給滿滿鼓勵。絕對五星好評！ 大推薦！', CAST(N'2026-02-16T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (184, 185, 14, 65, 1, N'遇到這教練真倒楣，這點程度也敢出來教。絕對不會再來！ 智商稅！', CAST(N'2025-09-23T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (185, 186, 11, 88, 5, N'非常感謝指導，菜單很符合作息。絕對五星好評！ 超推！', CAST(N'2026-03-01T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (186, 187, 11, 84, 5, N'收穫超乎預期，對接下來備餐更有頭緒。真心推薦給大家。 感謝教練！', CAST(N'2025-11-03T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (187, 188, 1, 54, 1, N'體驗極差，講廢話就下課了。爛到笑出來。 避雷！', CAST(N'2025-12-16T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (188, 189, 10, 6, 5, N'收穫超乎預期，給了很好的調整方向。太喜歡這模式了！ 大推薦！', CAST(N'2025-10-21T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (189, 190, 5, 73, 4, N'完全命中問題，對接下來備餐更有頭緒。準備好開始執行了！ 感謝教練！', CAST(N'2025-10-25T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (190, 191, 1, 31, 1, N'這什麼白癡建議，只會一直推銷課程。絕對不會再來！', CAST(N'2026-02-11T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (191, 192, 1, 48, 5, N'非常感謝指導，解答了我的盲點。馬上推薦給朋友。 超推！', CAST(N'2026-03-17T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (192, 193, 7, 71, 3, N'有點小失望，建議不太好執行。就這樣吧。', CAST(N'2026-01-13T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (193, 194, 7, 11, 1, N'超級不專業，菜單根本不能吃。快點逃啊各位。 避雷！', CAST(N'2026-02-27T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (194, 195, 13, 19, 3, N'稍微可惜，希望多給實際的例子。可能需要多點客製化。 表現中規中矩。', CAST(N'2026-01-01T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (195, 196, 2, 22, 5, N'超級用心！菜單很符合作息。超乎想像的好！ 超推！', CAST(N'2026-02-16T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (196, 197, 3, 19, 4, N'真的很棒，給的建議超實用。期待下次的諮詢。 錢花得很值得！', CAST(N'2025-12-26T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (197, 198, 10, 63, 4, N'態度很親切，提供很多超商就能買的選擇。太喜歡這模式了！ 感謝教練！', CAST(N'2026-01-14T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (198, 199, 9, 84, 2, N'長那什麼醜八怪樣子，講廢話就下課了。氣到發抖。', CAST(N'2025-10-29T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (199, 200, 8, 99, 3, N'表現平平，時間掌控上可再好一點。或許不太適合我。 表現中規中矩。', CAST(N'2026-02-03T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (200, 201, 1, 73, 4, N'收穫超乎預期，提供很多超商就能買的選擇。超乎想像的好！ 錢花得很值得！', CAST(N'2026-02-10T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (201, 202, 2, 41, 5, N'真的很棒，菜單很符合作息。真心推薦給大家。 超推！', CAST(N'2026-01-09T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (202, 203, 1, 80, 1, N'體驗極差，連營養素都算錯。準備被投訴吧。 智商稅！', CAST(N'2025-11-15T00:00:00.0000000' AS DateTime2), 1)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (203, 204, 12, 97, 4, N'超級用心！讓我清楚營養素分配。超乎想像的好！ 神仙教練！', CAST(N'2026-02-22T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (204, 205, 3, 28, 4, N'真的很棒，給的建議超實用。之後一定會再預約。 神仙教練！', CAST(N'2026-03-18T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (205, 206, 1, 65, 4, N'完全命中問題，細心客製化了我的計畫。收穫非常多。 大推薦！', CAST(N'2026-03-10T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (206, 207, 1, 67, 1, N'靠北，講廢話就下課了。準備被投訴吧。 避雷！', CAST(N'2026-03-09T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (207, 208, 1, 98, 4, N'真的很棒，給了很好的調整方向。收穫非常多。', CAST(N'2026-03-09T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (208, 209, 1, 22, 2, N'浪費我的時間，上課還在看手機。絕對不會再來！', CAST(N'2026-03-19T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (209, 210, 1, 53, 3, N'感覺還好，沒有完全針對我的狀況。就這樣吧。', CAST(N'2026-03-19T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (210, 211, 1, 90, 4, N'教練非常專業，解答了我的盲點。絕對五星好評！ 超推！', CAST(N'2026-03-16T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (211, 212, 1, 92, 3, N'感覺還好，建議不太好執行。算是買個經驗。', CAST(N'2026-03-15T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (212, 213, 1, 74, 4, N'超級用心！解答了我的盲點。更有動力了！ 超推！', CAST(N'2026-03-13T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (213, 214, 1, 60, 5, N'很喜歡這位營養師，不只給方法還給滿滿鼓勵。絕對五星好評！ 錢花得很值得！', CAST(N'2026-03-22T00:00:00.0000000' AS DateTime2), 0)
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt], [IsBanned]) VALUES (214, 215, 1, 91, 5, N'非常感謝指導，提供很多超商就能買的選擇。馬上推薦給朋友。 超推！', CAST(N'2026-03-25T00:00:00.0000000' AS DateTime2), 0)
GO
SET IDENTITY_INSERT [dbo].[Reviews] OFF
GO
SET IDENTITY_INSERT [dbo].[RoleFunctions] ON 
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (118, 2, 18)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (119, 2, 19)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (120, 2, 20)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (121, 2, 31)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (122, 2, 32)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (123, 2, 34)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (124, 2, 42)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (53, 3, 18)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (54, 3, 25)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (55, 3, 26)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (56, 3, 27)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (49, 4, 18)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (50, 4, 28)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (51, 4, 29)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (52, 4, 30)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (125, 5, 18)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (126, 5, 21)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (127, 5, 22)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (128, 5, 23)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (129, 5, 24)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (130, 5, 25)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (131, 5, 26)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (132, 5, 27)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (133, 5, 28)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (134, 5, 29)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (135, 5, 30)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (136, 5, 31)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (137, 5, 32)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (138, 5, 33)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (139, 5, 35)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (140, 5, 36)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (141, 5, 37)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (142, 5, 38)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (143, 5, 39)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (144, 5, 40)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (145, 5, 41)
GO
SET IDENTITY_INSERT [dbo].[RoleFunctions] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON 
GO
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (1, N'member', 1, N'登入會員，可使用飲食、生理數據紀錄、方案購買權限、購買運動用品')
GO
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (2, N'instructor', 1, N'專業教練')
GO
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (3, N'purchasor', 1, N'採購人員，負責上下架商品及庫存管理')
GO
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (4, N'marketor', 1, N'行銷人員，負責制定促銷方案或活動折扣')
GO
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (5, N'admin', 1, N'系統管理員')
GO
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (6, N'visitor', 1, N'訪客(未登入前)，只能瀏覽網頁')
GO
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO
SET IDENTITY_INSERT [dbo].[Shifts] ON 
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (1, 2, CAST(N'2026-03-08' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (2, 2, CAST(N'2026-03-10' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (3, 2, CAST(N'2026-03-07' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (4, 2, CAST(N'2026-03-14' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (5, 2, CAST(N'2026-03-06' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (6, 2, CAST(N'2026-03-08' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (7, 2, CAST(N'2026-03-11' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (8, 2, CAST(N'2026-03-09' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (9, 2, CAST(N'2026-03-16' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (10, 2, CAST(N'2026-03-10' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (11, 2, CAST(N'2026-03-19' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (12, 2, CAST(N'2026-03-22' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (13, 2, CAST(N'2026-03-24' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (14, 2, CAST(N'2026-03-24' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (15, 2, CAST(N'2026-03-15' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (76, 5, CAST(N'2025-10-22' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (77, 7, CAST(N'2025-12-20' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (78, 4, CAST(N'2025-10-28' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (79, 11, CAST(N'2025-10-03' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (80, 4, CAST(N'2026-03-16' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (81, 5, CAST(N'2026-02-15' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (82, 5, CAST(N'2025-12-30' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (83, 6, CAST(N'2026-03-02' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (84, 9, CAST(N'2026-01-14' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (85, 11, CAST(N'2025-12-10' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (86, 13, CAST(N'2025-12-20' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (87, 5, CAST(N'2026-01-26' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (88, 11, CAST(N'2025-09-20' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (89, 8, CAST(N'2026-02-19' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (90, 2, CAST(N'2025-12-12' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (91, 2, CAST(N'2025-11-11' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (92, 3, CAST(N'2026-01-01' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (93, 9, CAST(N'2025-12-02' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (94, 2, CAST(N'2025-12-08' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (95, 9, CAST(N'2026-02-24' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (96, 1, CAST(N'2026-03-02' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (97, 7, CAST(N'2026-02-20' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (98, 9, CAST(N'2026-01-28' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (99, 14, CAST(N'2026-03-14' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (100, 11, CAST(N'2025-10-02' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (101, 3, CAST(N'2026-01-26' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (102, 14, CAST(N'2026-03-02' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (103, 4, CAST(N'2025-12-03' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (104, 10, CAST(N'2025-10-30' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (105, 3, CAST(N'2026-02-05' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (106, 9, CAST(N'2026-02-24' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (107, 12, CAST(N'2025-12-26' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (108, 5, CAST(N'2026-03-02' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (109, 3, CAST(N'2025-10-21' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (110, 13, CAST(N'2026-02-05' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (111, 8, CAST(N'2025-12-13' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (112, 8, CAST(N'2026-02-27' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (113, 4, CAST(N'2025-12-06' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (114, 2, CAST(N'2025-10-23' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (115, 7, CAST(N'2025-12-03' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (116, 13, CAST(N'2026-01-10' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (117, 6, CAST(N'2026-01-03' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (118, 5, CAST(N'2026-01-22' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (119, 10, CAST(N'2026-02-13' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (120, 7, CAST(N'2025-09-28' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (121, 6, CAST(N'2026-02-18' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (122, 3, CAST(N'2026-03-03' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (123, 1, CAST(N'2025-12-17' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (124, 8, CAST(N'2025-10-23' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (125, 12, CAST(N'2025-11-12' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (126, 13, CAST(N'2026-02-02' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (127, 7, CAST(N'2026-01-11' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (128, 3, CAST(N'2025-10-18' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (129, 4, CAST(N'2025-10-29' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (130, 1, CAST(N'2025-09-20' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (131, 7, CAST(N'2025-10-29' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (132, 1, CAST(N'2025-10-08' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (133, 11, CAST(N'2025-10-08' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (134, 6, CAST(N'2026-02-06' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (135, 3, CAST(N'2026-01-25' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (136, 11, CAST(N'2025-11-02' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (137, 4, CAST(N'2025-10-13' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (138, 9, CAST(N'2025-10-07' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (139, 7, CAST(N'2025-10-12' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (140, 2, CAST(N'2025-12-25' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (141, 9, CAST(N'2025-12-30' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (142, 12, CAST(N'2026-03-13' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (143, 7, CAST(N'2026-01-19' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (144, 6, CAST(N'2025-09-25' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (145, 13, CAST(N'2025-11-02' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (146, 9, CAST(N'2025-10-02' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (147, 11, CAST(N'2025-11-05' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (148, 5, CAST(N'2025-10-10' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (149, 10, CAST(N'2025-12-09' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (150, 13, CAST(N'2025-10-08' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (151, 14, CAST(N'2025-10-10' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (152, 3, CAST(N'2025-11-09' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (153, 6, CAST(N'2025-10-23' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (154, 5, CAST(N'2026-03-13' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (155, 5, CAST(N'2025-09-23' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (156, 2, CAST(N'2026-01-26' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (157, 13, CAST(N'2026-03-15' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (158, 7, CAST(N'2025-10-26' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (159, 14, CAST(N'2025-12-30' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (160, 6, CAST(N'2025-12-06' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (161, 8, CAST(N'2026-01-01' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (162, 6, CAST(N'2026-01-27' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (163, 1, CAST(N'2026-02-01' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (164, 14, CAST(N'2026-03-09' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (165, 4, CAST(N'2025-11-10' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (166, 5, CAST(N'2025-11-17' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (167, 8, CAST(N'2026-03-06' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (168, 11, CAST(N'2026-01-24' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (169, 7, CAST(N'2026-03-02' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (170, 5, CAST(N'2025-12-17' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (171, 9, CAST(N'2025-10-11' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (172, 11, CAST(N'2025-10-12' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (173, 9, CAST(N'2025-09-30' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (174, 14, CAST(N'2025-11-01' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (175, 8, CAST(N'2025-12-30' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (176, 9, CAST(N'2025-11-19' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (177, 8, CAST(N'2025-11-25' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (178, 10, CAST(N'2025-10-17' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (179, 5, CAST(N'2025-12-06' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (180, 1, CAST(N'2026-03-10' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (181, 9, CAST(N'2025-09-22' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (182, 12, CAST(N'2025-12-14' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (183, 11, CAST(N'2026-03-04' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (184, 1, CAST(N'2026-01-10' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (185, 14, CAST(N'2025-12-16' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (186, 10, CAST(N'2025-12-11' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (187, 6, CAST(N'2026-01-30' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (188, 6, CAST(N'2026-03-15' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (189, 9, CAST(N'2025-10-25' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (190, 4, CAST(N'2025-12-05' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (191, 12, CAST(N'2025-12-16' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (192, 4, CAST(N'2026-01-19' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (193, 14, CAST(N'2025-12-23' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (194, 4, CAST(N'2026-01-31' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (195, 14, CAST(N'2026-01-19' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (196, 1, CAST(N'2025-11-05' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (197, 2, CAST(N'2025-10-21' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (198, 4, CAST(N'2025-10-27' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (199, 10, CAST(N'2026-02-01' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (200, 10, CAST(N'2025-11-11' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (201, 5, CAST(N'2025-10-24' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (202, 13, CAST(N'2025-10-10' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (203, 14, CAST(N'2025-12-01' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (204, 3, CAST(N'2026-01-27' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (205, 4, CAST(N'2025-12-14' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (206, 4, CAST(N'2026-01-11' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (207, 6, CAST(N'2025-10-11' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (208, 3, CAST(N'2026-02-22' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (209, 8, CAST(N'2025-10-13' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (210, 4, CAST(N'2025-10-02' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (211, 4, CAST(N'2025-12-06' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (212, 11, CAST(N'2025-12-17' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (213, 6, CAST(N'2026-01-20' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (214, 5, CAST(N'2025-10-01' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (215, 11, CAST(N'2025-12-24' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (216, 5, CAST(N'2025-10-07' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (217, 2, CAST(N'2025-11-19' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (218, 5, CAST(N'2026-02-04' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (219, 11, CAST(N'2025-11-18' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (220, 6, CAST(N'2025-11-11' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (221, 1, CAST(N'2025-11-10' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (222, 7, CAST(N'2025-11-17' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (223, 6, CAST(N'2025-10-05' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (224, 2, CAST(N'2026-02-24' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (225, 7, CAST(N'2026-02-21' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (226, 9, CAST(N'2026-02-11' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (227, 2, CAST(N'2026-01-26' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (228, 4, CAST(N'2025-09-23' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (229, 4, CAST(N'2025-10-07' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (230, 4, CAST(N'2025-12-04' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (231, 3, CAST(N'2026-02-19' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (232, 9, CAST(N'2025-10-03' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (233, 12, CAST(N'2025-12-03' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (234, 12, CAST(N'2025-10-30' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (235, 14, CAST(N'2025-11-03' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (236, 3, CAST(N'2025-10-07' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (237, 7, CAST(N'2026-02-16' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (238, 1, CAST(N'2025-12-19' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (239, 3, CAST(N'2025-12-24' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (240, 5, CAST(N'2025-12-22' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (241, 2, CAST(N'2025-11-09' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (242, 9, CAST(N'2025-11-27' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (243, 3, CAST(N'2025-12-13' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (244, 2, CAST(N'2026-01-30' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (245, 1, CAST(N'2026-01-19' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (246, 12, CAST(N'2025-11-04' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (247, 4, CAST(N'2025-10-24' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (248, 5, CAST(N'2026-02-04' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (249, 1, CAST(N'2025-09-29' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (250, 3, CAST(N'2026-02-03' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (251, 2, CAST(N'2025-11-25' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (252, 7, CAST(N'2025-10-27' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (253, 7, CAST(N'2025-10-27' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (254, 7, CAST(N'2026-02-14' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (255, 14, CAST(N'2025-09-20' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (256, 11, CAST(N'2026-02-26' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (257, 11, CAST(N'2025-11-01' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (258, 1, CAST(N'2025-12-14' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (259, 10, CAST(N'2025-10-19' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (260, 5, CAST(N'2025-10-23' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (261, 1, CAST(N'2026-02-10' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (262, 1, CAST(N'2026-03-15' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (263, 7, CAST(N'2026-01-11' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (264, 7, CAST(N'2026-02-26' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (265, 13, CAST(N'2025-12-31' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (266, 2, CAST(N'2026-02-14' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (267, 3, CAST(N'2025-12-23' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (268, 10, CAST(N'2026-01-13' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (269, 9, CAST(N'2025-10-28' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (270, 8, CAST(N'2026-01-31' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (271, 1, CAST(N'2026-02-07' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (272, 2, CAST(N'2026-01-08' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (273, 1, CAST(N'2025-11-13' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (274, 12, CAST(N'2026-02-19' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (275, 3, CAST(N'2026-03-16' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (276, 1, CAST(N'2026-03-09' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (277, 1, CAST(N'2026-03-06' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (278, 1, CAST(N'2026-03-07' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (279, 1, CAST(N'2026-03-17' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (280, 1, CAST(N'2026-03-17' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (281, 1, CAST(N'2026-03-13' AS Date), N'09-10 (早)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (282, 1, CAST(N'2026-03-12' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (283, 1, CAST(N'2026-03-12' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (284, 1, CAST(N'2026-03-19' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (285, 1, CAST(N'2026-03-24' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (286, 1, CAST(N'2026-03-19' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (287, 1, CAST(N'2026-03-12' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (288, 1, CAST(N'2026-03-23' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (289, 1, CAST(N'2026-03-21' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (290, 1, CAST(N'2026-03-20' AS Date), N'18-19 (晚)', 1)
GO
SET IDENTITY_INSERT [dbo].[Shifts] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (1, N'liulinjin01', N'$2b$12$AAAbbbCCCdddEEEfffGGGhhhIIIjjjKKKlllMMMnnnOOO', N'劉林瑾', N'alice@example.com', N'0912345601', 1, 0, NULL, NULL, N'3e8b83608fe64a63b82f13fc9b61c02a', CAST(N'2026-03-09T17:38:06.0000000' AS DateTime2))
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2, N'chenhanmu02', N'$2b$12$BBBcccDDDeeeFFFgggHHHiiiJJJkkkLLLmmmNNNooo111', N'陳涵沐', N'bob@example.com', N'0912345602', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (3, N'linlannan03', N'$2b$12$CCCdddEEEffFFFgggHHHiiiJJJkkkLLLmmmNNNooo222', N'林蘭楠', N'carol@example.com', N'0912345603', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (6, N'chenshuan04', N'$2b$12$FFFghhHHHiiiJJJkkkLLLmmmNNNooo555666777888999', N'陳書安', N'frank@example.com', N'0912345606', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (7, N'huqingqing05', N'$2b$12$GGGhiiIIIjjjKKKlllMMMnnnOOOppp666777888999aaa', N'胡清清', N'grace@example.com', N'0912345607', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (8, N'lishilin06', N'$2b$12$HHHijjJJJkkkLLLmmmNNNooo777888999aaabbbccc111', N'李詩林', N'henry@example.com', N'0912345608', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (9, N'wulangyan07', N'$2b$12$IIIjkkKKKlllMMMnnnOOOppp888999aaabbbccc222333', N'吳朗妍', N'iris@example.com', N'0912345609', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (11, N'gaozhuohang08', NULL, N'高卓航', N'kevin.google@gmail.com', N'0912345611', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (12, N'luomuchen09', NULL, N'羅沐晨', N'linda.google@gmail.com', N'0912345612', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (13, N'xuyaoze10', N'AQAAAAIAAYagAAAAEP0mUPSkyrn6ftw1a8vThzMKvFPhVLAbw9ZYw0orGTG21UdoTbEN9jiMWPLT/y+swQ==', N'徐瑤澤', N'aaaa@bbbbb.com', N'0912345678', 0, 0, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (1014, N'zhouchenhan11', N'AQAAAAIAAYagAAAAEMj7/DwGlJfLr+SnWkq+6QFfV5sAiy+6tGqHH26BQChTjJV0YoX1XMq/spoGlW7rew==', N'周晨涵', N'admin@myfitnesscoach.com', NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2013, N'huqingwei12', N'AQAAAAIAAYagAAAAEFYME7wXIETzEGypBggxvBQHV6fwfcfTKMUZjdryefcjD51MX1js0yz6SFR5YwPsVQ==', N'胡青薇', N'yvonne42396@gmail.com', NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2014, N'liweiyin13', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李薇音', N'eric55339944@gmail.com', NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2015, N'luoqinglin14', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅青林', N'nutri1@fitness.com', N'0912384756', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2016, N'zhouanrou15', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周安柔', N'nutri2@fitness.com', N'0921475869', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2017, N'zhuchenyuan16', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱辰遠', N'nutri3@fitness.com', N'0933582417', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2018, N'linningran17', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林寧然', N'nutri4@fitness.com', N'0975614238', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2019, N'liyaoqing18', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李瑤清', N'nutri5@fitness.com', N'0988231457', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2020, N'herouran19', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何柔然', N'nutri6@fitness.com', N'0919456782', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2021, N'liuweiyin20', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉薇音', N'nutri7@fitness.com', N'0928374651', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2022, N'lizeqing21', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李澤清', N'nutri8@fitness.com', N'0932145698', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2023, N'linranlan22', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林然蘭', N'nutri9@fitness.com', N'0955874123', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2024, N'maruoyun23', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬若雲', N'nutri10@fitness.com', N'0910234567', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2025, N'lilangyao24', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李朗瑤', N'nutri11@fitness.com', N'0963214587', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2026, N'gaojingwei25', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高景薇', N'nutri12@fitness.com', N'0972581436', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2027, N'gaoqingxing26', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高清星', N'purch1@fitness.com', N'0937123456', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2028, N'wangyinning27', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'王音寧', N'purch2@fitness.com', N'0911223344', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2029, N'zhaochenting28', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙晨庭', N'purch3@fitness.com', N'0922334455', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2030, N'gaoshining29', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高詩寧', N'purch4@fitness.com', N'0955667788', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2031, N'maruoyao30', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬若瑤', N'purch5@fitness.com', N'0966778899', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2032, N'zhanglinjin31', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張霖瑾', N'purch6@fitness.com', N'0977889900', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2033, N'wuqingyang32', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳青揚', N'purch7@fitness.com', N'0988990011', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2034, N'heyaze33', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何雅澤', N'purch8@fitness.com', N'0900112233', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2035, N'liuchenrou34', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉晨柔', N'purch9@fitness.com', N'0911558899', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2036, N'huangyanghang35', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'黃揚航', N'purch10@fitness.com', N'0922446688', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2037, N'zhaoyuqing36', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙宇清', N'market1@fitness.com', N'0910001111', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2038, N'chenrouchen37', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'陳柔辰', N'market2@fitness.com', N'0920002222', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2039, N'yangyangyuan38', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'楊揚遠', N'market3@fitness.com', N'0930003333', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2040, N'huanghanya39', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'黃涵雅', N'market4@fitness.com', N'0940004444', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2041, N'sunnanqing40', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫楠清', N'market5@fitness.com', N'0950005555', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2042, N'zhanglangwei41', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張朗薇', N'market6@fitness.com', N'0960006666', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2043, N'zhaoweimu42', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙薇沐', N'market7@fitness.com', N'0970007777', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2044, N'sunanwei43', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫安薇', N'market8@fitness.com', N'0980008888', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2045, N'liushumu44', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉書沐', N'market9@fitness.com', N'0990009999', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2046, N'linchenshu45', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林辰書', N'market10@fitness.com', N'0900000000', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2047, N'lilinnan46', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李霖楠', N'admin1@fitness.com', N'0912121212', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2048, N'huangyanning47', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'黃妍寧', N'admin2@fitness.com', N'0923232323', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2049, N'zhouranhang48', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周然航', N'admin3@fitness.com', N'0934343434', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2050, N'liuyangrou49', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉揚柔', N'admin4@fitness.com', N'0945454545', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2051, N'gaochenze50', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高晨澤', N'admin5@fitness.com', N'0956565656', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2052, N'linxuanyu51', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林軒宇', N'member001@fitness.com', N'0960000001', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2053, N'liuyuanlang52', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉遠朗', N'member002@fitness.com', N'0960000002', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2054, N'huangyunyang53', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'黃雲揚', N'member003@fitness.com', N'0960000003', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2055, N'guohanqing54', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'郭涵清', N'member004@fitness.com', N'0960000004', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2056, N'sunyanshi55', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫妍詩', N'member005@fitness.com', N'0960000055', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2057, N'chenlinwei56', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'陳林薇', N'member006@fitness.com', N'0960000006', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2058, N'luoxinghao57', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅星皓', N'member007@fitness.com', N'0960000007', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2059, N'xuyangan58', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'徐揚安', N'member008@fitness.com', N'0960000008', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2060, N'xuweizhuo59', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'徐薇卓', N'member009@fitness.com', N'0960000009', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2061, N'huangqingjin60', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'黃青瑾', N'member010@fitness.com', N'0960000010', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2062, N'liuhaoya61', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉皓雅', N'member011@fitness.com', N'0960000011', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2063, N'guoxinglang62', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'郭星朗', N'member012@fitness.com', N'0960000012', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2064, N'sunlanran63', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫蘭然', N'member013@fitness.com', N'0960000013', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2065, N'mayarou64', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬雅柔', N'member014@fitness.com', N'0960000014', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2066, N'chenshuxuan65', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'陳書軒', N'member015@fitness.com', N'0960000015', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2067, N'huqinghan66', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'胡清涵', N'member016@fitness.com', N'0960000016', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2068, N'wuxuanwei67', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳軒薇', N'member017@fitness.com', N'0960000017', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2069, N'guomuan68', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'郭沐安', N'member018@fitness.com', N'0960000018', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2070, N'zhangchenyao69', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張晨瑤', N'member019@fitness.com', N'0960000019', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2071, N'heyunshu70', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何雲書', N'member020@fitness.com', N'0960000020', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2072, N'luoweiwei71', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅薇薇', N'member021@fitness.com', N'0960000021', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2073, N'zhuyinyuan72', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱音遠', N'member022@fitness.com', N'0960000022', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2074, N'zhaohaoshi73', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙皓詩', N'member023@fitness.com', N'0960000023', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2075, N'maqingrou74', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬清柔', N'member024@fitness.com', N'0960000024', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2076, N'liuyaoze75', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉瑤澤', N'member025@fitness.com', N'0960000025', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2077, N'liuanhang76', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉安航', N'member026@fitness.com', N'0960000026', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2078, N'zhangzhuoqing77', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張卓晴', N'member027@fitness.com', N'0960000027', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2079, N'guolinwei78', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'郭霖薇', N'member028@fitness.com', N'0960000028', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2080, N'zhangmulan79', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張沐蘭', N'member029@fitness.com', N'0960000029', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2081, N'zhujinting80', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱瑾庭', N'member030@fitness.com', N'0960000030', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2082, N'maboze81', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬柏澤', N'member031@fitness.com', N'0960000031', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2083, N'zhoumuqing82', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周沐青', N'member032@fitness.com', N'0960000032', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2084, N'zhaojingze83', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙景澤', N'member033@fitness.com', N'0960000033', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2085, N'zhangmuning84', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張沐寧', N'member034@fitness.com', N'0960000034', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2086, N'zhaotingjing85', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙庭景', N'member035@fitness.com', N'0960000035', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2087, N'mananzhuo86', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬楠卓', N'member036@fitness.com', N'0960000036', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2088, N'guozhuolang87', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'郭卓朗', N'member037@fitness.com', N'0960000037', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2089, N'yangzechen88', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'楊澤辰', N'member038@fitness.com', N'0960000038', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2090, N'wuxinghao89', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳星皓', N'member039@fitness.com', N'0960000039', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2091, N'luozehan90', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅澤涵', N'member040@fitness.com', N'0960000040', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2092, N'sunhanyin91', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫涵音', N'member041@fitness.com', N'0960000041', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2093, N'luoqingning92', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅清寧', N'member042@fitness.com', N'0960000042', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2094, N'wulangchuan93', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳朗川', N'member043@fitness.com', N'0960000043', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2095, N'liyalin94', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李雅霖', N'member044@fitness.com', N'0960000044', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2096, N'huyanting95', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'胡言庭', N'member045@fitness.com', N'0960000045', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2097, N'zhangchenya96', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張辰雅', N'member046@fitness.com', N'0960000046', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2098, N'chenyuchen97', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'陳宇晨', N'member047@fitness.com', N'0960000047', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2099, N'zhanganyang98', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張安揚', N'member048@fitness.com', N'0960000048', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2100, N'xuchenyun99', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'徐辰雲', N'member049@fitness.com', N'0960000049', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2101, N'zhurouqing100', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱柔青', N'member050@fitness.com', N'0960000050', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2102, N'gaomuyan101', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高沐言', N'member051@fitness.com', N'0960000051', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2103, N'zhangxuanting102', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張軒庭', N'member052@fitness.com', N'0960000052', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2104, N'yangnanhang103', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'楊楠航', N'member053@fitness.com', N'0960000053', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2105, N'luoyaoyan104', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅瑤妍', N'member054@fitness.com', N'0960000054', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2106, N'majingyin105', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬景音', N'member055@fitness.com', N'0960000055', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2107, N'xubaihao106', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'徐柏皓', N'member056@fitness.com', N'0960000056', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2108, N'zhuoruolang107', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱若朗', N'member057@fitness.com', N'0960000057', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2109, N'yangyuyang108', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'楊宇揚', N'member058@fitness.com', N'0960000058', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2110, N'zhaoyaoqing109', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙瑤清', N'member059@fitness.com', N'0960000059', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2111, N'heweihao110', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何薇皓', N'member060@fitness.com', N'0960000060', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2112, N'zhouhangyu111', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周航宇', N'member061@fitness.com', N'0960000061', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2113, N'wuweiyang112', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳薇揚', N'member062@fitness.com', N'0960000062', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2114, N'wulinyao113', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳霖瑤', N'member063@fitness.com', N'0960000063', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2115, N'zhouyunya114', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周雲雅', N'member064@fitness.com', N'0960000064', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2116, N'zhouyanyang115', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周言揚', N'member065@fitness.com', N'0960000065', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2117, N'sunbaihao116', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫柏皓', N'member066@fitness.com', N'0960000066', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2118, N'sunruozhuo117', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫若卓', N'member067@fitness.com', N'0960000067', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2119, N'sunmumu118', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'孫沐沐', N'member068@fitness.com', N'0960000068', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2120, N'zhoulinyan119', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周林妍', N'member069@fitness.com', N'0960000069', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2121, N'linzeting120', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林澤庭', N'member070@fitness.com', N'0960000070', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2122, N'hejinze121', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何瑾澤', N'member071@fitness.com', N'0960000071', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2123, N'wunanlin122', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳楠霖', N'member072@fitness.com', N'0960000072', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2124, N'wuyanhan123', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳言涵', N'member073@fitness.com', N'0960000073', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2125, N'luoweiyan124', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'羅薇言', N'member074@fitness.com', N'0960000074', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2126, N'heweihao125', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何薇皓', N'member075@fitness.com', N'0960000075', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2127, N'zhoutingzhuo126', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周庭卓', N'member076@fitness.com', N'0960000076', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2128, N'wuranze127', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳然澤', N'member077@fitness.com', N'0960000077', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2129, N'lizemu128', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'李澤沐', N'member078@fitness.com', N'0960000078', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2130, N'linyinting129', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'林音庭', N'member079@fitness.com', N'0960000079', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2131, N'heyuruo130', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何宇若', N'member080@fitness.com', N'0960000080', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2132, N'gaoanqing131', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高安清', N'member081@fitness.com', N'0960000081', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2133, N'zhaolangyao132', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'趙朗瑤', N'member082@fitness.com', N'0960000082', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2134, N'wangjinjin133', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'王瑾瑾', N'member083@fitness.com', N'0960000083', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2135, N'gaoyunan134', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高雲安', N'member084@fitness.com', N'0960000084', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2136, N'malangyan135', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'馬朗妍', N'member085@fitness.com', N'0960000085', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2137, N'gaoqingan136', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高晴安', N'member086@fitness.com', N'0960000086', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2138, N'liulinran137', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'劉霖然', N'member087@fitness.com', N'0960000087', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2139, N'huningya138', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'胡寧雅', N'member088@fitness.com', N'0960000088', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2140, N'zhouhangjing139', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'周航景', N'member089@fitness.com', N'0960000089', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2141, N'huqingyang140', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'胡晴揚', N'member090@fitness.com', N'0960000090', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2142, N'huyanshi141', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'胡言詩', N'member091@fitness.com', N'0960000091', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2143, N'zhuhaolin142', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱皓林', N'member092@fitness.com', N'0960000092', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2144, N'xumuyang143', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'徐沐揚', N'member093@fitness.com', N'0960000093', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2145, N'wuhanghang144', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳航航', N'member094@fitness.com', N'0960000094', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2146, N'wuyuxing145', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'吳宇星', N'member095@fitness.com', N'0960000095', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2147, N'huangshijing146', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'黃詩景', N'member096@fitness.com', N'0960000096', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2148, N'heyanyun147', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'何言雲', N'member097@fitness.com', N'0960000097', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2149, N'gaoyangbai148', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'高揚柏', N'member098@fitness.com', N'0960000098', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2150, N'zhuqinghan149', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'朱青涵', N'member099@fitness.com', N'0960000099', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2151, N'zhangxingnan150', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'張星楠', N'member100@fitness.com', N'0960000100', 1, 1, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
/****** Object:  Index [UQ__Employee__1788CC4D88FE5B9C]    Script Date: 2026/3/18 下午 04:59:26 ******/
ALTER TABLE [dbo].[Employees] ADD UNIQUE NONCLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__Instruct__9D010A9A5102E434]    Script Date: 2026/3/18 下午 04:59:26 ******/
ALTER TABLE [dbo].[InstructorWallets] ADD UNIQUE NONCLUSTERED 
(
	[InstructorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__KeyWords__95B501084BCC2128]    Script Date: 2026/3/18 下午 04:59:26 ******/
ALTER TABLE [dbo].[KeyWords] ADD UNIQUE NONCLUSTERED 
(
	[Word] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_LeaveBalances_Key]    Script Date: 2026/3/18 下午 04:59:26 ******/
ALTER TABLE [dbo].[LeaveBalances] ADD  CONSTRAINT [UQ_LeaveBalances_Key] UNIQUE NONCLUSTERED 
(
	[EmployeeId] ASC,
	[LeaveTypeId] ASC,
	[Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__MemberVi__0CF04B19A82096A5]    Script Date: 2026/3/18 下午 04:59:26 ******/
ALTER TABLE [dbo].[MemberViolations] ADD UNIQUE NONCLUSTERED 
(
	[MemberId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_RoleFunctions]    Script Date: 2026/3/18 下午 04:59:26 ******/
ALTER TABLE [dbo].[RoleFunctions] ADD  CONSTRAINT [UQ_RoleFunctions] UNIQUE NONCLUSTERED 
(
	[RoleId] ASC,
	[FunctionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Roles__8A2B6160C3E03AEF]    Script Date: 2026/3/18 下午 04:59:26 ******/
ALTER TABLE [dbo].[Roles] ADD UNIQUE NONCLUSTERED 
(
	[RoleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Sensitiv__95B50108290DD060]    Script Date: 2026/3/18 下午 04:59:26 ******/
ALTER TABLE [dbo].[SensitiveWords] ADD UNIQUE NONCLUSTERED 
(
	[Word] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_UserRoles]    Script Date: 2026/3/18 下午 04:59:26 ******/
ALTER TABLE [dbo].[UserRoles] ADD  CONSTRAINT [UQ_UserRoles] UNIQUE NONCLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Users__A9D1053475D1FFC0]    Script Date: 2026/3/18 下午 04:59:26 ******/
ALTER TABLE [dbo].[Users] ADD UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Users__B0C3AC46E7482967]    Script Date: 2026/3/18 下午 04:59:26 ******/
ALTER TABLE [dbo].[Users] ADD UNIQUE NONCLUSTERED 
(
	[Account] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__UserWall__0CF04B19594A1F43]    Script Date: 2026/3/18 下午 04:59:26 ******/
ALTER TABLE [dbo].[UserWallets] ADD UNIQUE NONCLUSTERED 
(
	[MemberId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BodyRecords] ADD  DEFAULT (getdate()) FOR [CreateAt]
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
ALTER TABLE [dbo].[InstructorWalletDetails] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[InstructorWalletDetails] ADD  DEFAULT ((0)) FOR [Category]
GO
ALTER TABLE [dbo].[InstructorWallets] ADD  DEFAULT ((0)) FOR [CurrentBalance]
GO
ALTER TABLE [dbo].[InstructorWallets] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[KeyWords] ADD  DEFAULT ((1)) FOR [Weight]
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
ALTER TABLE [dbo].[PointOrders] ADD  DEFAULT (getdate()) FOR [CreateAt]
GO
ALTER TABLE [dbo].[PointsRecordDetails] ADD  DEFAULT (getdate()) FOR [CreateAt]
GO
ALTER TABLE [dbo].[ProductCategories] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ProductOrders] ADD  DEFAULT (getdate()) FOR [CreateAt]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ReserveOrders] ADD  DEFAULT (getdate()) FOR [CreateAt]
GO
ALTER TABLE [dbo].[Reviews] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Reviews] ADD  DEFAULT ((0)) FOR [IsBanned]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Shifts] ADD  DEFAULT ((0)) FOR [IsBooked]
GO
ALTER TABLE [dbo].[TopUpPlans] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[TopUpPlans] ADD  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((0)) FOR [IsConfirmed]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[UserWallets] ADD  DEFAULT ((0)) FOR [CurrentBalance]
GO
ALTER TABLE [dbo].[UserWallets] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[BodyRecords]  WITH CHECK ADD  CONSTRAINT [FK_BodyRecords_Members] FOREIGN KEY([MemberId])
REFERENCES [dbo].[Members] ([Id])
GO
ALTER TABLE [dbo].[BodyRecords] CHECK CONSTRAINT [FK_BodyRecords_Members]
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
ALTER TABLE [dbo].[LeaveRequests]  WITH CHECK ADD CHECK  (([Status]='Cancelled' OR [Status]='Rejected' OR [Status]='Approved' OR [Status]='Pending'))
GO
