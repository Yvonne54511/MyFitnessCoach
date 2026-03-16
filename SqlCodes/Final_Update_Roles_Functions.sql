-- 1. 更新資料表結構：新增 Description 與 api_path 欄位
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[dbo].[Roles]') AND name = 'Description')
BEGIN
    ALTER TABLE [dbo].[Roles] ADD [Description] NVARCHAR(MAX);
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[dbo].[Functions]') AND name = 'Description')
BEGIN
    ALTER TABLE [dbo].[Functions] ADD [Description] NVARCHAR(MAX);
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[dbo].[Functions]') AND name = 'api_path')
BEGIN
    ALTER TABLE [dbo].[Functions] ADD [api_path] NVARCHAR(500);
END
GO

-- 2. 更新 Roles 資料
MERGE INTO [dbo].[Roles] AS Target
USING (VALUES 
    ('visitor', N'訪客(未登入前)，只能瀏覽網頁'), 
    ('member', N'登入會員，可使用飲食、生理數據紀錄、方案購買權限、購買運動用品'), 
    ('instructor', N'專業教練'), 
    ('purchasor', N'採購人員，負責上下架商品及庫存管理'), 
    ('marketor', N'行銷人員，負責制定促銷方案 or 活動折扣'), 
    ('admin', N'系統管理員')
) AS Source (RoleName, Description)
ON Target.RoleName = Source.RoleName
WHEN MATCHED THEN
    UPDATE SET Description = Source.Description
WHEN NOT MATCHED THEN
    INSERT (RoleName, Description, IsActive) VALUES (Source.RoleName, Source.Description, 1);
GO

-- 3. 更新 Functions 資料 (含 api_path)
MERGE INTO [dbo].[Functions] AS Target
USING (VALUES 
    ('edit_Password', N'修改個人自己的登入密碼', '/Account/ResetPassword'),
    ('edit_IntructorDetails', N'修改教練自己的個人簡介與相片', '/Account/InstructorDetails'),
    ('edit_InstructorShifts', N'安排或編輯教練自己的排班', '/Shift/Index'),
    ('view_InstructorShifts', N'查看所有教練的排班情況', '/Shift/AllShifts'),
    ('edit_UserAccounts', N'管理設定、新增、修改、停用、恢復所有使用者的帳號', '/Staff/Index'),
    ('edit_RoleFunctions', N'權限設定，管理每個角色的系統功能使用權限', '/Staff/RoleFunctions'),
    ('edit_UserRoles', N'分配或修改使用者所屬的角色', '/Staff/UserRoles'),
    ('edit_ProductCategories', N'管理商品項目的商品分類', '/ProductCategories/Index'),
    ('edit_ProductItems', N'管理商品項目的商品', '/Products/Index'),
    ('edit_ProductOrders', N'處理商品項目的訂單', '/ProductOrders/index'),
    ('edit_Plans', N'制定或修改促銷方案', '/TopUpPlans/Index'),
    ('edit_PlanOrders', N'處理促銷方案或課程購買生成的訂單', '/PointOrders/Index'),
    ('view_PointRecords', N'查看會員的點數取得及使用紀錄', '/Member/ViewPointsRecord'),
    ('view_ClientFoodRecords', N'查看會員每日的飲食紀錄', '/Member/ViewFoodRecords'),
    ('view_ClientBodyData', N'查看會員生理數據變化', '/Member/ViewFoodRecords'),
    ('edit_Comments_admin', N'系統管理員回覆評論或刪除功能', '/Review/AdminIndex'),
    ('edit_Comments_instructor', N'專業教練回覆評論功能', '/Review/InstructorIndex')
) AS Source (FunctionName, Description, api_path)
ON Target.FunctionName = Source.FunctionName
WHEN MATCHED THEN
    UPDATE SET Description = Source.Description, api_path = Source.api_path
WHEN NOT MATCHED THEN
    INSERT (FunctionName, Description, api_path, IsActive) VALUES (Source.FunctionName, Source.Description, Source.api_path, 1);
GO

-- 4. 重新同步 RoleFunctions 權限關聯
-- 為確保資料乾淨，先清除現有對應關係
DELETE FROM [dbo].[RoleFunctions];
GO

-- 重新插入關聯
INSERT INTO [dbo].[RoleFunctions] ([RoleId], [FunctionId])
SELECT r.Id, f.Id
FROM [dbo].[Roles] r, [dbo].[Functions] f
WHERE 
(f.FunctionName = 'edit_Password' AND r.RoleName IN ('instructor','purchasor','marketor','admin')) OR
(f.FunctionName = 'edit_IntructorDetails' AND r.RoleName = 'instructor') OR
(f.FunctionName = 'edit_InstructorShifts' AND r.RoleName = 'instructor') OR
(f.FunctionName = 'view_InstructorShifts' AND r.RoleName = 'admin') OR
(f.FunctionName = 'edit_UserAccounts' AND r.RoleName = 'admin') OR
(f.FunctionName = 'edit_RoleFunctions' AND r.RoleName = 'admin') OR
(f.FunctionName = 'edit_UserRoles' AND r.RoleName = 'admin') OR
(f.FunctionName = 'edit_ProductCategories' AND r.RoleName IN ('admin','purchasor')) OR
(f.FunctionName = 'edit_ProductItems' AND r.RoleName IN ('admin','purchasor')) OR
(f.FunctionName = 'edit_ProductOrders' AND r.RoleName IN ('admin','purchasor')) OR
(f.FunctionName = 'edit_Plans' AND r.RoleName IN ('admin','marketor')) OR
(f.FunctionName = 'edit_PlanOrders' AND r.RoleName IN ('admin','marketor')) OR
(f.FunctionName = 'view_PointRecords' AND r.RoleName IN ('admin','marketor')) OR
(f.FunctionName = 'view_ClientFoodRecords' AND r.RoleName IN ('admin','instructor')) OR
(f.FunctionName = 'view_ClientBodyData' AND r.RoleName IN ('admin','instructor')) OR
(f.FunctionName = 'edit_Comments_admin' AND r.RoleName = 'admin') OR
(f.FunctionName = 'edit_Comments_instructor' AND r.RoleName = 'instructor');
GO
