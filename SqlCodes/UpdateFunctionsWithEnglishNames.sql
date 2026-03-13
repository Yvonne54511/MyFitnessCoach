
-- 1. 檢查並新增 FunctionName 欄位 (如果還沒新增)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Functions') AND name = 'FunctionName')
BEGIN
    ALTER TABLE [dbo].[Functions] ADD [FunctionName] NVARCHAR(50) NULL;
END
GO

-- 2. 根據 ID 更新資料 (避免編碼問題)
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_Password', [Api_path] = '/Account/ResetPassword' WHERE [Id] = 18;
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_IntructorDetails', [Api_path] = '/Account/InstructorDetails' WHERE [Id] = 19;
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_InstructorShifts', [Api_path] = '/Shift/Index' WHERE [Id] = 20;
UPDATE [dbo].[Functions] SET [FunctionName] = 'view_InstructorShifts', [Api_path] = '/Shift/AllShifts' WHERE [Id] = 21;
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_UserAccounts', [Api_path] = '/Staff/Index' WHERE [Id] = 22;
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_RoleFunctions', [Api_path] = '/Staff/RoleFunctions' WHERE [Id] = 23;
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_UserRoles', [Api_path] = '/Staff/UserRoles' WHERE [Id] = 24;
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_ProductCategories', [Api_path] = '/ProductCategories/Index' WHERE [Id] = 25;
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_ProductItems', [Api_path] = '/Products/Index' WHERE [Id] = 26;
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_ProductOrders', [Api_path] = '/ProductOrders/index' WHERE [Id] = 27;
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_Plans', [Api_path] = '/TopUpPlans/Index' WHERE [Id] = 28;
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_PlanOrders', [Api_path] = '/PointOrders/Index' WHERE [Id] = 29;
UPDATE [dbo].[Functions] SET [FunctionName] = 'view_PointRecords', [Api_path] = '/Member/ViewPointsRecord' WHERE [Id] = 30;
UPDATE [dbo].[Functions] SET [FunctionName] = 'view_ClientFoodRecords', [Api_path] = '/Member/ViewFoodRecords' WHERE [Id] = 31;
UPDATE [dbo].[Functions] SET [FunctionName] = 'view_ClientBodyData', [Api_path] = '/Member/ViewFoodRecords' WHERE [Id] = 32;
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_Comments_admin', [Api_path] = '/Review/AdminIndex' WHERE [Id] = 33;
UPDATE [dbo].[Functions] SET [FunctionName] = 'edit_Comments_instructor', [Api_path] = '/Review/InstructorIndex' WHERE [Id] = 34;
GO

-- 3. 檢查更新結果
SELECT Id, FunctionName, Description, Api_path FROM [dbo].[Functions];
GO
