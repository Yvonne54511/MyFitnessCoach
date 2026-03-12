USE [master]
GO
/****** Object:  Database [MyFitnessCoachDb]    Script Date: 2026/3/12 下午 06:19:19 ******/
CREATE DATABASE [MyFitnessCoachDb]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'MyFitnessCoachDb', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.SQL2025\MSSQL\DATA\MyFitnessCoachDb.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'MyFitnessCoachDb_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.SQL2025\MSSQL\DATA\MyFitnessCoachDb_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [MyFitnessCoachDb] SET COMPATIBILITY_LEVEL = 170
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [MyFitnessCoachDb].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [MyFitnessCoachDb] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET ARITHABORT OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [MyFitnessCoachDb] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [MyFitnessCoachDb] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET  DISABLE_BROKER 
GO
ALTER DATABASE [MyFitnessCoachDb] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [MyFitnessCoachDb] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET RECOVERY FULL 
GO
ALTER DATABASE [MyFitnessCoachDb] SET  MULTI_USER 
GO
ALTER DATABASE [MyFitnessCoachDb] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [MyFitnessCoachDb] SET DB_CHAINING OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [MyFitnessCoachDb] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [MyFitnessCoachDb] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [MyFitnessCoachDb] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [MyFitnessCoachDb] SET OPTIMIZED_LOCKING = OFF 
GO
ALTER DATABASE [MyFitnessCoachDb] SET QUERY_STORE = ON
GO
ALTER DATABASE [MyFitnessCoachDb] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [MyFitnessCoachDb]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[Roles]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[UserRoles]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[Functions]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[RoleFunctions]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  View [dbo].[vw_UserRoleFunctions]    Script Date: 2026/3/12 下午 06:19:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[vw_UserRoleFunctions] AS
SELECT 
    u.UserName,
    u.Account,
    r.RoleName,
    f.FunctionName
FROM 
    [dbo].[Users] u
JOIN 
    [dbo].[UserRoles] ur ON u.Id = ur.UserId
JOIN 
    [dbo].[Roles] r ON ur.RoleId = r.Id
JOIN 
    [dbo].[RoleFunctions] rf ON r.Id = rf.RoleId
JOIN 
    [dbo].[Functions] f ON rf.FunctionId = f.Id;
GO
/****** Object:  View [dbo].[vw_RoleFunctions]    Script Date: 2026/3/12 下午 06:19:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[vw_RoleFunctions] AS
SELECT 
    r.RoleName,
    f.FunctionName
FROM 
    [dbo].[Roles] r
JOIN 
    [dbo].[RoleFunctions] rf ON r.Id = rf.RoleId
JOIN 
    [dbo].[Functions] f ON rf.FunctionId = f.Id;
GO
/****** Object:  View [dbo].[vw_UserRoleFunction]    Script Date: 2026/3/12 下午 06:19:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- 👁️ 七、 視圖 (Views)
-- ============================================================
CREATE VIEW [dbo].[vw_UserRoleFunction] AS
SELECT u.Id AS UserId, u.UserName, u.Email, r.Id AS RoleId, r.RoleName, f.Id AS FunctionId, f.FunctionName
FROM Users u
JOIN UserRoles ur ON ur.UserId = u.Id
JOIN Roles r ON r.Id = ur.RoleId
JOIN RoleFunctions rf ON rf.RoleId = r.Id
JOIN [Functions] f ON f.Id = rf.FunctionId;
GO
/****** Object:  Table [dbo].[Members]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[FoodCategories]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[Foods]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[Nutrients]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[FoodRecords]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  View [dbo].[vw_UserMemberFoodRecord]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[Instructors]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[PointOrders]    Script Date: 2026/3/12 下午 06:19:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PointOrders](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MemberId] [int] NOT NULL,
	[CreateAt] [datetime2](7) NOT NULL,
	[PointQty] [int] NOT NULL,
	[OriginalPrice] [decimal](18, 0) NOT NULL,
	[DiscountedPrice] [decimal](18, 0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PointsRecordDetails]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[ProductCategories]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[ProductOrderDetails]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[ProductOrders]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[Products]    Script Date: 2026/3/12 下午 06:19:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CategoryId] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[ImageUrl] [nvarchar](300) NOT NULL,
	[OriginalPrice] [decimal](18, 0) NOT NULL,
	[UnitPrice] [decimal](18, 0) NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[SortOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReserveOrders]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[Reviews]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[SensitiveWords]    Script Date: 2026/3/12 下午 06:19:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SensitiveWords](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReviewId] [int] NOT NULL,
	[Word] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Shifts]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[TopUpPlans]    Script Date: 2026/3/12 下午 06:19:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TopUpPlans](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PlanName] [nvarchar](50) NOT NULL,
	[Price] [decimal](10, 2) NOT NULL,
	[Points] [int] NOT NULL,
	[Description] [nvarchar](500) NULL,
	[IsActive] [bit] NOT NULL,
	[SortOrder] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserExternalLogins]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
/****** Object:  Table [dbo].[UserWallets]    Script Date: 2026/3/12 下午 06:19:19 ******/
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
SET IDENTITY_INSERT [dbo].[Functions] OFF
GO
SET IDENTITY_INSERT [dbo].[Instructors] ON 
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (1, 2014, N'/img/instructors/3231a7bc-f617-4e50-8ef5-bd6caa4c43ef.png', N'專精減脂', 1000, 1, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (2, 2013, N'/img/instructors/e113b488-a510-4dcc-b7e0-b097d21765d2.png', N'糖尿病飲食', 1200, 3, 1)
GO
INSERT [dbo].[Instructors] ([Id], [UserId], [ImageUrl], [Description], [HourWage], [CancelCount], [IsActive]) VALUES (7, 2015, N'/img/instructors/d625f698-3dfb-489b-930d-8ad68d69721c.png', N'減脂專業', 1500, 0, 1)
GO
SET IDENTITY_INSERT [dbo].[Instructors] OFF
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
SET IDENTITY_INSERT [dbo].[Members] OFF
GO
SET IDENTITY_INSERT [dbo].[PointOrders] ON 
GO
INSERT [dbo].[PointOrders] ([Id], [MemberId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice]) VALUES (1, 1, CAST(N'2026-03-11T14:51:48.5266667' AS DateTime2), 5, CAST(5000 AS Decimal(18, 0)), CAST(4000 AS Decimal(18, 0)))
GO
INSERT [dbo].[PointOrders] ([Id], [MemberId], [CreateAt], [PointQty], [OriginalPrice], [DiscountedPrice]) VALUES (2, 2, CAST(N'2026-03-11T14:51:48.5266667' AS DateTime2), 2, CAST(2000 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)))
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
SET IDENTITY_INSERT [dbo].[ProductOrderDetails] ON 
GO
INSERT [dbo].[ProductOrderDetails] ([Id], [ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo]) VALUES (1, 1, 1, CAST(99 AS Decimal(18, 0)), 2, CAST(198 AS Decimal(18, 0)), CAST(198 AS Decimal(18, 0)), N'經典原味舒肥雞胸肉', N'/images/products/chicken_01.jpg', N'請幫我用紙箱包裝')
GO
INSERT [dbo].[ProductOrderDetails] ([Id], [ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo]) VALUES (2, 1, 9, CAST(1200 AS Decimal(18, 0)), 1, CAST(1200 AS Decimal(18, 0)), CAST(1000 AS Decimal(18, 0)), N'濃縮乳清蛋白 - 醇厚巧克力', N'/images/products/protein_01.jpg', NULL)
GO
INSERT [dbo].[ProductOrderDetails] ([Id], [ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo]) VALUES (3, 2, 17, CAST(450 AS Decimal(18, 0)), 1, CAST(450 AS Decimal(18, 0)), CAST(450 AS Decimal(18, 0)), N'高單位活力B群', N'/images/products/vitamin_01.jpg', NULL)
GO
INSERT [dbo].[ProductOrderDetails] ([Id], [ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo]) VALUES (4, 2, 24, CAST(350 AS Decimal(18, 0)), 2, CAST(700 AS Decimal(18, 0)), CAST(650 AS Decimal(18, 0)), N'304不鏽鋼分隔便當盒', N'/images/products/box_01.jpg', N'送禮用，請確認無刮痕')
GO
INSERT [dbo].[ProductOrderDetails] ([Id], [ProductOrderId], [ProductId], [UnitPrice], [Qty], [SubTotal], [DiscountedPrice], [ProductName], [ImageURL], [Memo]) VALUES (5, 1, 6, CAST(109 AS Decimal(18, 0)), 3, CAST(327 AS Decimal(18, 0)), CAST(327 AS Decimal(18, 0)), N'川味麻辣雞胸肉', N'/images/products/chicken_06.jpg', NULL)
GO
SET IDENTITY_INSERT [dbo].[ProductOrderDetails] OFF
GO
SET IDENTITY_INSERT [dbo].[ProductOrders] ON 
GO
INSERT [dbo].[ProductOrders] ([Id], [MemberId], [CreateAt], [OriginalAmount], [DiscountAmount], [Receiver], [Address], [Mobile], [TaxNumber], [Status], [Memo]) VALUES (1, 1, CAST(N'2026-03-11T14:51:48.5233333' AS DateTime2), CAST(2000 AS Decimal(18, 0)), CAST(1800 AS Decimal(18, 0)), N'陳小明', N'台北市信義區', N'0912345678', NULL, 1, NULL)
GO
INSERT [dbo].[ProductOrders] ([Id], [MemberId], [CreateAt], [OriginalAmount], [DiscountAmount], [Receiver], [Address], [Mobile], [TaxNumber], [Status], [Memo]) VALUES (2, 2, CAST(N'2026-03-11T14:51:48.5266667' AS DateTime2), CAST(1500 AS Decimal(18, 0)), CAST(1500 AS Decimal(18, 0)), N'王大同', N'台北市大安區', N'0987654321', NULL, 1, NULL)
GO
SET IDENTITY_INSERT [dbo].[ProductOrders] OFF
GO
SET IDENTITY_INSERT [dbo].[Products] ON 
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (1, 1, N'經典原味舒肥雞胸肉', N'/images/products/chicken_01.jpg', CAST(120 AS Decimal(18, 0)), CAST(99 AS Decimal(18, 0)), N'鮮嫩多汁，低脂高蛋白，無過多調味', 1, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (2, 1, N'黑胡椒海鹽雞胸肉', N'/images/products/chicken_02.jpg', CAST(120 AS Decimal(18, 0)), CAST(99 AS Decimal(18, 0)), N'使用天然海鹽與粗粒黑胡椒，經典百搭', 2, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (3, 1, N'蒜香風味雞胸肉', N'/images/products/chicken_03.jpg', CAST(120 AS Decimal(18, 0)), CAST(99 AS Decimal(18, 0)), N'濃郁蒜香，健身後補充的最佳首選', 3, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (4, 1, N'泰式檸檬雞胸肉', N'/images/products/chicken_04.jpg', CAST(130 AS Decimal(18, 0)), CAST(109 AS Decimal(18, 0)), N'微酸微辣，清爽解膩的泰式風味', 4, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (5, 1, N'印度咖哩雞胸肉', N'/images/products/chicken_05.jpg', CAST(130 AS Decimal(18, 0)), CAST(109 AS Decimal(18, 0)), N'濃郁咖哩香氣，異國風味口感豐富', 5, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (6, 1, N'川味麻辣雞胸肉', N'/images/products/chicken_06.jpg', CAST(130 AS Decimal(18, 0)), CAST(109 AS Decimal(18, 0)), N'嗜辣者必備，刺激味蕾好下飯', 6, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (7, 1, N'義式香草雞胸肉', N'/images/products/chicken_07.jpg', CAST(140 AS Decimal(18, 0)), CAST(119 AS Decimal(18, 0)), N'特選義式綜合香料醃製，香氣四溢', 7, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (8, 1, N'迷迭香烤雞胸肉', N'/images/products/chicken_08.jpg', CAST(140 AS Decimal(18, 0)), CAST(119 AS Decimal(18, 0)), N'高級餐廳等級口感，在家也能輕鬆享受', 8, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (9, 2, N'濃縮乳清蛋白 - 醇厚巧克力', N'/images/products/protein_01.jpg', CAST(1500 AS Decimal(18, 0)), CAST(1200 AS Decimal(18, 0)), N'每份含25g蛋白質，濃郁可可風味', 1, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (10, 2, N'濃縮乳清蛋白 - 經典香草', N'/images/products/protein_02.jpg', CAST(1500 AS Decimal(18, 0)), CAST(1200 AS Decimal(18, 0)), N'百搭香草風味，適合搭配牛奶或燕麥', 2, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (11, 2, N'分離乳清蛋白 - 鮮採草莓', N'/images/products/protein_03.jpg', CAST(1800 AS Decimal(18, 0)), CAST(1450 AS Decimal(18, 0)), N'乳糖不耐症適用，酸甜草莓口感', 3, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (12, 2, N'分離乳清蛋白 - 英式奶茶', N'/images/products/protein_04.jpg', CAST(1800 AS Decimal(18, 0)), CAST(1450 AS Decimal(18, 0)), N'超人氣奶茶口味，享受喝手搖飲的快感', 4, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (13, 2, N'緩釋型酪蛋白 - 原味', N'/images/products/protein_05.jpg', CAST(1600 AS Decimal(18, 0)), CAST(1300 AS Decimal(18, 0)), N'緩慢釋放胺基酸，睡前補充最佳選擇', 5, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (14, 2, N'純素大豆分離蛋白 - 抹茶', N'/images/products/protein_06.jpg', CAST(1400 AS Decimal(18, 0)), CAST(1100 AS Decimal(18, 0)), N'素食者健身必備，日式靜岡抹茶風味', 6, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (15, 2, N'綜合植物蛋白粉 - 芝麻', N'/images/products/protein_07.jpg', CAST(1450 AS Decimal(18, 0)), CAST(1150 AS Decimal(18, 0)), N'富含多種植物性胺基酸，濃郁芝麻香', 7, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (16, 2, N'高蛋白能量代餐飲 - 香蕉', N'/images/products/protein_08.jpg', CAST(1200 AS Decimal(18, 0)), CAST(990 AS Decimal(18, 0)), N'富含飽足感，減脂期代餐好幫手', 8, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (17, 3, N'高單位活力B群', N'/images/products/vitamin_01.jpg', CAST(600 AS Decimal(18, 0)), CAST(450 AS Decimal(18, 0)), N'增強體力，精神旺盛，運動後恢復必備', 1, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (18, 3, N'維生素C1000發泡錠', N'/images/products/vitamin_02.jpg', CAST(350 AS Decimal(18, 0)), CAST(280 AS Decimal(18, 0)), N'酸甜好喝，日常保養與促進膠原蛋白形成', 2, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (19, 3, N'陽光維生素D3軟膠囊', N'/images/products/vitamin_03.jpg', CAST(500 AS Decimal(18, 0)), CAST(390 AS Decimal(18, 0)), N'室內族必備，促進鈣質吸收', 3, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (20, 3, N'綜合礦物質複方錠', N'/images/products/vitamin_04.jpg', CAST(800 AS Decimal(18, 0)), CAST(650 AS Decimal(18, 0)), N'一次補充多種流汗流失的必需礦物質', 4, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (21, 3, N'高濃度深海魚油 Omega-3', N'/images/products/vitamin_05.jpg', CAST(1200 AS Decimal(18, 0)), CAST(890 AS Decimal(18, 0)), N'晶亮護明，循環順暢，維持健康', 5, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (22, 3, N'胺基酸螯合鋅錠', N'/images/products/vitamin_06.jpg', CAST(550 AS Decimal(18, 0)), CAST(420 AS Decimal(18, 0)), N'高吸收率，維持生長發育與生殖機能', 6, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (23, 3, N'海藻鈣+鎂+D3', N'/images/products/vitamin_07.jpg', CAST(900 AS Decimal(18, 0)), CAST(720 AS Decimal(18, 0)), N'完美吸收比例，維持骨骼與牙齒健康', 7, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (24, 4, N'304不鏽鋼分隔便當盒', N'/images/products/box_01.jpg', CAST(450 AS Decimal(18, 0)), CAST(350 AS Decimal(18, 0)), N'耐用好洗，不殘留異味，環保首選', 1, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (25, 4, N'白金矽膠摺疊便當盒', N'/images/products/box_02.jpg', CAST(550 AS Decimal(18, 0)), CAST(420 AS Decimal(18, 0)), N'可摺疊收納節省空間，外出攜帶超方便', 2, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (26, 4, N'耐熱玻璃保鮮盒 - 單格600ml', N'/images/products/box_03.jpg', CAST(300 AS Decimal(18, 0)), CAST(199 AS Decimal(18, 0)), N'微波、烤箱、電鍋皆適用，安全無毒', 3, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (27, 4, N'耐熱玻璃保鮮盒 - 雙格800ml', N'/images/products/box_04.jpg', CAST(380 AS Decimal(18, 0)), CAST(250 AS Decimal(18, 0)), N'飯菜分離不串味，備餐最佳容器', 4, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (28, 4, N'日式質感木製便當盒', N'/images/products/box_05.jpg', CAST(650 AS Decimal(18, 0)), CAST(499 AS Decimal(18, 0)), N'文青風格，適合冷食與輕食沙拉專用', 5, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (29, 4, N'微波專用加熱分隔餐盒', N'/images/products/box_06.jpg', CAST(250 AS Decimal(18, 0)), CAST(150 AS Decimal(18, 0)), N'食品級PP材質，附透氣孔方便微波', 6, 1)
GO
INSERT [dbo].[Products] ([Id], [CategoryId], [Name], [ImageUrl], [OriginalPrice], [UnitPrice], [Description], [SortOrder], [IsActive]) VALUES (30, 4, N'大容量運動雙層沙拉盒', N'/images/products/box_07.jpg', CAST(400 AS Decimal(18, 0)), CAST(299 AS Decimal(18, 0)), N'附獨立沙拉醬料盒與環保叉匙', 7, 1)
GO
SET IDENTITY_INSERT [dbo].[Products] OFF
GO
SET IDENTITY_INSERT [dbo].[ReserveOrders] ON 
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (4, 2, 10, CAST(N'2026-03-08T13:50:13.0000000' AS DateTime2), N'已完成', N'信用卡', N'體重管理與外食挑選建議', NULL, CAST(1200.00 AS Decimal(10, 2)), N'建議減少精緻澱粉，多攝取蔬菜')
GO
INSERT [dbo].[ReserveOrders] ([Id], [MemberId], [ShiftId], [CreateAt], [Status], [PaymentMethod], [Target], [PointCost], [Price], [Memorandum]) VALUES (5, 1, 11, CAST(N'2026-03-08T13:50:13.0000000' AS DateTime2), N'已完成', N'點數', N'日常飲食檢視與蛋白質攝取評估', 800, NULL, N'蛋白質攝取稍微不足，已建議增加白肉比例')
GO
SET IDENTITY_INSERT [dbo].[ReserveOrders] OFF
GO
SET IDENTITY_INSERT [dbo].[Reviews] ON 
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt]) VALUES (3, 4, 2, 2, 5, N'李營養師非常專業，給了很具體的外食建議，非常感謝！', CAST(N'2026-03-08T13:50:13.0000000' AS DateTime2))
GO
INSERT [dbo].[Reviews] ([Id], [ReserveOrderId], [InstructorId], [MemberId], [Rating], [Comment], [CreatedAt]) VALUES (4, 5, 1, 1, 4, N'講解得很清楚，但希望能多提供一些超商能買到的具體品項建議。', CAST(N'2026-03-08T13:50:13.0000000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[Reviews] OFF
GO
SET IDENTITY_INSERT [dbo].[RoleFunctions] ON 
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (1009, 2, 18)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (1010, 2, 19)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (1011, 2, 20)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (1012, 2, 31)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (1013, 2, 32)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (1014, 2, 34)
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
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (29, 5, 18)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (30, 5, 21)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (31, 5, 22)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (32, 5, 23)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (33, 5, 24)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (34, 5, 25)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (35, 5, 26)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (36, 5, 27)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (37, 5, 28)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (38, 5, 29)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (39, 5, 30)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (40, 5, 31)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (41, 5, 32)
GO
INSERT [dbo].[RoleFunctions] ([Id], [RoleId], [FunctionId]) VALUES (42, 5, 33)
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
INSERT [dbo].[Roles] ([Id], [RoleName], [IsActive], [Description]) VALUES (1007, N'manager', 1, N'主管')
GO
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO
SET IDENTITY_INSERT [dbo].[Shifts] ON 
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (10, 2, CAST(N'2026-02-20' AS Date), N'14-15 (午)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (11, 1, CAST(N'2026-03-01' AS Date), N'18-19 (晚)', 1)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (56, 1, CAST(N'2026-03-18' AS Date), N'14-15 (午)', 0)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (58, 2, CAST(N'2026-03-30' AS Date), N'09-10 (早)', 0)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (59, 2, CAST(N'2026-03-30' AS Date), N'14-15 (午)', 0)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (60, 2, CAST(N'2026-03-30' AS Date), N'18-19 (晚)', 0)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (64, 1, CAST(N'2026-03-18' AS Date), N'18-19 (晚)', 0)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (65, 1, CAST(N'2026-03-18' AS Date), N'09-10 (早)', 0)
GO
INSERT [dbo].[Shifts] ([Id], [InstructorId], [ScheduleDate], [TimeSlot], [IsBooked]) VALUES (70, 1, CAST(N'2026-03-25' AS Date), N'09-10 (早)', 0)
GO
SET IDENTITY_INSERT [dbo].[Shifts] OFF
GO
SET IDENTITY_INSERT [dbo].[TopUpPlans] ON 
GO
INSERT [dbo].[TopUpPlans] ([Id], [PlanName], [Price], [Points], [Description], [IsActive], [SortOrder]) VALUES (1, N'單堂體驗方案', CAST(1000.00 AS Decimal(10, 2)), 1, N'購買 1 點，適合初次體驗諮詢課程的學員。', 1, 1)
GO
INSERT [dbo].[TopUpPlans] ([Id], [PlanName], [Price], [Points], [Description], [IsActive], [SortOrder]) VALUES (2, N'雙效入門方案', CAST(1800.00 AS Decimal(10, 2)), 2, N'購買 2 點，享 9 折優惠，適合有短期諮詢需求的你。', 1, 2)
GO
INSERT [dbo].[TopUpPlans] ([Id], [PlanName], [Price], [Points], [Description], [IsActive], [SortOrder]) VALUES (3, N'五星進階方案', CAST(4000.00 AS Decimal(10, 2)), 5, N'購買 5 點，享 8 折優惠，單次諮詢低至 800 元！', 1, 3)
GO
INSERT [dbo].[TopUpPlans] ([Id], [PlanName], [Price], [Points], [Description], [IsActive], [SortOrder]) VALUES (4, N'十分超值方案', CAST(7000.00 AS Decimal(10, 2)), 10, N'購買 10 點，享 7 折優惠，穩定長期諮詢的最佳選擇。', 1, 4)
GO
INSERT [dbo].[TopUpPlans] ([Id], [PlanName], [Price], [Points], [Description], [IsActive], [SortOrder]) VALUES (5, N'尊榮鐵粉方案', CAST(12000.00 AS Decimal(10, 2)), 20, N'購買 20 點，享 6 折最高優惠，單次只要 600 元，買到賺到！', 1, 5)
GO
SET IDENTITY_INSERT [dbo].[TopUpPlans] OFF
GO
SET IDENTITY_INSERT [dbo].[UserRoles] ON 
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (2006, 1, 1)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (2, 2, 1)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3, 3, 1)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (6, 6, 3)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (7, 7, 3)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (8, 8, 4)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (9, 9, 4)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (11, 11, 1)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (12, 12, 1)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (1002, 13, 1)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (2003, 1014, 5)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (4014, 2013, 2)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3009, 2013, 5)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (4015, 2014, 2)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (3011, 2014, 3)
GO
INSERT [dbo].[UserRoles] ([Id], [UserId], [RoleId]) VALUES (4017, 2015, 2)
GO
SET IDENTITY_INSERT [dbo].[UserRoles] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (1, N'alice01', N'$2b$12$AAAbbbCCCdddEEEfffGGGhhhIIIjjjKKKlllMMMnnnOOO', N'Alice Wang', N'alice@example.com', N'0912345601', 1, 0, NULL, NULL, N'3e8b83608fe64a63b82f13fc9b61c02a', CAST(N'2026-03-09T17:38:06.0000000' AS DateTime2))
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2, N'bob02', N'$2b$12$BBBcccDDDeeeFFFgggHHHiiiJJJkkkLLLmmmNNNooo111', N'Bob Chen', N'bob@example.com', N'0912345602', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (3, N'carol03', N'$2b$12$CCCdddEEEffFFFgggHHHiiiJJJkkkLLLmmmNNNooo222', N'Carol Lin', N'carol@example.com', N'0912345603', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (6, N'pur_frank', N'$2b$12$FFFghhHHHiiiJJJkkkLLLmmmNNNooo555666777888999', N'Frank Wu', N'frank@example.com', N'0912345606', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (7, N'pur_grace', N'$2b$12$GGGhiiIIIjjjKKKlllMMMnnnOOOppp666777888999aaa', N'Grace Tsai', N'grace@example.com', N'0912345607', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (8, N'mkt_henry', N'$2b$12$HHHijjJJJkkkLLLmmmNNNooo777888999aaabbbccc111', N'Henry Chang', N'henry@example.com', N'0912345608', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (9, N'mkt_iris', N'$2b$12$IIIjkkKKKlllMMMnnnOOOppp888999aaabbbccc222333', N'Iris Chou', N'iris@example.com', N'0912345609', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (11, NULL, NULL, N'Kevin Google', N'kevin.google@gmail.com', N'0912345611', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (12, NULL, NULL, N'Linda Google', N'linda.google@gmail.com', N'0912345612', 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (13, N'aaaa', N'AQAAAAIAAYagAAAAEP0mUPSkyrn6ftw1a8vThzMKvFPhVLAbw9ZYw0orGTG21UdoTbEN9jiMWPLT/y+swQ==', N'Allen2', N'aaaa@bbbbb.com', N'0912345678', 0, 0, N'd516b394-c7dc-4d99-b17f-277bfa2627db', CAST(N'2026-03-08T09:49:59.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (1014, N'admin', N'AQAAAAIAAYagAAAAEMj7/DwGlJfLr+SnWkq+6QFfV5sAiy+6tGqHH26BQChTjJV0YoX1XMq/spoGlW7rew==', N'系統管理員', N'admin@myfitnesscoach.com', NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2013, N'admin_yvonne', N'AQAAAAIAAYagAAAAEOWvvx9ZLW0yxxUI2dv35ETerPKArn7KbqG4/Afx+XEXZIWxQnn48ku80CszykICTA==', N'吳怡潁', N'yvonne42396@gmail.com', NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2014, N'ins1', N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==', N'inst1', N'eric55339944@gmail.com', NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [Account], [HashedPassword], [UserName], [Email], [Mobile], [IsConfirmed], [IsActive], [NewMemberConfirmCode], [NewMemberConfirmCodeExpiry], [ResetPasswordConfirmCode], [ResetPasswordConfirmCodeExpiry]) VALUES (2015, N'yiyingwu0423', N'AQAAAAIAAYagAAAAEDDhk19b+i0iKzhBmR/3YSMP1BDkFRbaq/QT3EaqJGQoMm3nunu5gxXz3wjobQ6a9Q==', N'Yvonne', N'yiyingwu0423@gmail.com', NULL, 1, 0, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
SET IDENTITY_INSERT [dbo].[UserWallets] ON 
GO
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (1, 1, CAST(2000.00 AS Decimal(10, 2)), CAST(N'2026-03-08T09:40:56.0000000' AS DateTime2))
GO
INSERT [dbo].[UserWallets] ([Id], [MemberId], [CurrentBalance], [LastUpdated]) VALUES (2, 2, CAST(500.00 AS Decimal(10, 2)), CAST(N'2026-03-08T09:40:56.0000000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[UserWallets] OFF
GO
/****** Object:  Index [UQ_RoleFunctions]    Script Date: 2026/3/12 下午 06:19:19 ******/
ALTER TABLE [dbo].[RoleFunctions] ADD  CONSTRAINT [UQ_RoleFunctions] UNIQUE NONCLUSTERED 
(
	[RoleId] ASC,
	[FunctionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Roles__8A2B616061E6CFB4]    Script Date: 2026/3/12 下午 06:19:19 ******/
ALTER TABLE [dbo].[Roles] ADD UNIQUE NONCLUSTERED 
(
	[RoleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Sensitiv__95B50108431C3ADA]    Script Date: 2026/3/12 下午 06:19:19 ******/
ALTER TABLE [dbo].[SensitiveWords] ADD UNIQUE NONCLUSTERED 
(
	[Word] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Instructor_Shift]    Script Date: 2026/3/12 下午 06:19:19 ******/
ALTER TABLE [dbo].[Shifts] ADD  CONSTRAINT [UQ_Instructor_Shift] UNIQUE NONCLUSTERED 
(
	[InstructorId] ASC,
	[ScheduleDate] ASC,
	[TimeSlot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_UserRoles]    Script Date: 2026/3/12 下午 06:19:19 ******/
ALTER TABLE [dbo].[UserRoles] ADD  CONSTRAINT [UQ_UserRoles] UNIQUE NONCLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Users_Email]    Script Date: 2026/3/12 下午 06:19:19 ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [UQ_Users_Email] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_Users_Account]    Script Date: 2026/3/12 下午 06:19:19 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_Users_Account] ON [dbo].[Users]
(
	[Account] ASC
)
WHERE ([Account] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_UserWallets_Member]    Script Date: 2026/3/12 下午 06:19:19 ******/
ALTER TABLE [dbo].[UserWallets] ADD  CONSTRAINT [UQ_UserWallets_Member] UNIQUE NONCLUSTERED 
(
	[MemberId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
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
ALTER TABLE [dbo].[Members] ADD  DEFAULT ((1)) FOR [CancelCount]
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
ALTER TABLE [dbo].[Members]  WITH CHECK ADD  CONSTRAINT [FK_Members_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Members] CHECK CONSTRAINT [FK_Members_Users]
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
ALTER TABLE [dbo].[SensitiveWords]  WITH CHECK ADD  CONSTRAINT [FK_SensitiveWords_Reviews] FOREIGN KEY([ReviewId])
REFERENCES [dbo].[Reviews] ([Id])
GO
ALTER TABLE [dbo].[SensitiveWords] CHECK CONSTRAINT [FK_SensitiveWords_Reviews]
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
USE [master]
GO
ALTER DATABASE [MyFitnessCoachDb] SET  READ_WRITE 
GO
