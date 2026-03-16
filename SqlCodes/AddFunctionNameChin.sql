
-- 1. 新增 FunctionName_Chin 欄位
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Functions') AND name = 'FunctionName_Chin')
BEGIN
    ALTER TABLE [dbo].[Functions] ADD [FunctionName_Chin] NVARCHAR(50) NULL;
END
GO

-- 2. 依照 ID 順序填入中文名稱
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'修改帳密' WHERE [Id] = 18;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'個人資料維護' WHERE [Id] = 19;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'營養師班表排程' WHERE [Id] = 20;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'班表預約管理' WHERE [Id] = 21;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'使用者帳號管理' WHERE [Id] = 22;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'權限管理' WHERE [Id] = 23;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'角色權限管理' WHERE [Id] = 24;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'商品類別管理' WHERE [Id] = 25;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'類別管理' WHERE [Id] = 26;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'商品訂單管理' WHERE [Id] = 27;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'儲值方案管理' WHERE [Id] = 28;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'儲值方案訂單' WHERE [Id] = 29;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'點數記錄查詢' WHERE [Id] = 30;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'客戶飲食紀錄查詢' WHERE [Id] = 31;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'客戶體態數據查詢' WHERE [Id] = 32;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'評論區管理' WHERE [Id] = 33;
UPDATE [dbo].[Functions] SET [FunctionName_Chin] = N'評論區察看與舉報' WHERE [Id] = 34;
GO

-- 3. 查看結果
SELECT Id, FunctionName, FunctionName_Chin, Description FROM [dbo].[Functions];
GO
