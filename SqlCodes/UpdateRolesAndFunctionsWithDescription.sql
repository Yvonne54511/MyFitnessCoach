-- 1. 更新 Roles 資料表架構
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Roles]') AND name = 'Description')
BEGIN
    ALTER TABLE [dbo].[Roles] ADD [Description] NVARCHAR(200) NULL;
END

-- 2. 更新 Functions 資料表架構
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Functions]') AND name = 'Description')
BEGIN
    ALTER TABLE [dbo].[Functions] ADD [Description] NVARCHAR(200) NULL;
END

-- 3. 插入或更新 Roles 資料 (附帶說明)
MERGE INTO [dbo].[Roles] AS Target
USING (VALUES 
    ('member', '一般會員'), 
    ('instructor', '健身教練'), 
    ('purchasor', '採購人員'), 
    ('marketor', '行銷人員'), 
    ('admin', '系統管理員')
) AS Source (RoleName, Description)
ON Target.RoleName = Source.RoleName
WHEN MATCHED THEN
    UPDATE SET Description = Source.Description
WHEN NOT MATCHED THEN
    INSERT (RoleName, Description, IsActive) VALUES (Source.RoleName, Source.Description, 1);

-- 4. 插入或更新 Functions 資料
MERGE INTO [dbo].[Functions] AS Target
USING (VALUES 
    ('edit_Password', '修改密碼'), ('edit_IntructorDetails', '編輯教練個人資料'), 
    ('edit_InstructorShifts', '編輯教練班表'), ('view_InstructorShifts', '查看教練班表'),
    ('edit_UserAccounts', '編輯使用者帳號'), ('edit_RoleFunctions', '編輯角色權限'), 
    ('edit_UserRoles', '編輯使用者角色'), ('edit_ProductCategories', '編輯商品分類'),
    ('edit_ProductItems', '編輯商品項目'), ('edit_ProductOrders', '編輯商品訂單'), 
    ('edit_Plans', '編輯儲值方案'), ('edit_PlanOrders', '編輯方案訂單'),
    ('view_PointRecords', '查看點數紀錄'), ('view_ClientFoodRecords', '查看客戶飲食紀錄'), 
    ('view_ClientBodyData', '查看客戶身體數據'), ('edit_Comments_admin', '管理員編輯評論'), 
    ('edit_Comments_instructor', '教練編輯評論')
) AS Source (FunctionName, Description)
ON Target.FunctionName = Source.FunctionName
WHEN MATCHED THEN
    UPDATE SET Description = Source.Description
WHEN NOT MATCHED THEN
    INSERT (FunctionName, Description, IsActive) VALUES (Source.FunctionName, Source.Description, 1);

-- 5. 重新同步 RoleFunctions 關聯
WITH Mapping AS (
    SELECT 'edit_Password' AS Func, R.RoleName FROM (VALUES ('instructor'), ('purchasor'), ('marketor'), ('admin')) AS R(RoleName) UNION ALL
    SELECT 'edit_IntructorDetails', 'instructor' UNION ALL
    SELECT 'edit_InstructorShifts', 'instructor' UNION ALL
    SELECT 'view_InstructorShifts', 'admin' UNION ALL
    SELECT 'edit_UserAccounts', 'admin' UNION ALL
    SELECT 'edit_RoleFunctions', 'admin' UNION ALL
    SELECT 'edit_UserRoles', 'admin' UNION ALL
    SELECT 'edit_ProductCategories', R.RoleName FROM (VALUES ('admin'), ('purchasor')) AS R(RoleName) UNION ALL
    SELECT 'edit_ProductItems', R.RoleName FROM (VALUES ('admin'), ('purchasor')) AS R(RoleName) UNION ALL
    SELECT 'edit_ProductOrders', R.RoleName FROM (VALUES ('admin'), ('purchasor')) AS R(RoleName) UNION ALL
    SELECT 'edit_Plans', R.RoleName FROM (VALUES ('admin'), ('marketor')) AS R(RoleName) UNION ALL
    SELECT 'edit_PlanOrders', R.RoleName FROM (VALUES ('admin'), ('marketor')) AS R(RoleName) UNION ALL
    SELECT 'view_PointRecords', R.RoleName FROM (VALUES ('admin'), ('marketor')) AS R(RoleName) UNION ALL
    SELECT 'view_ClientFoodRecords', R.RoleName FROM (VALUES ('admin'), ('instructor')) AS R(RoleName) UNION ALL
    SELECT 'view_ClientBodyData', R.RoleName FROM (VALUES ('admin'), ('instructor')) AS R(RoleName) UNION ALL
    SELECT 'edit_Comments_admin', 'admin' UNION ALL
    SELECT 'edit_Comments_instructor', 'instructor'
)
INSERT INTO [dbo].[RoleFunctions] ([RoleId], [FunctionId])
SELECT r.Id, f.Id
FROM Mapping m
JOIN [dbo].[Roles] r ON m.RoleName = r.RoleName
JOIN [dbo].[Functions] f ON m.Func = f.FunctionName
WHERE NOT EXISTS (
    SELECT 1 FROM [dbo].[RoleFunctions] rf 
    WHERE rf.RoleId = r.Id AND rf.FunctionId = f.Id
);
