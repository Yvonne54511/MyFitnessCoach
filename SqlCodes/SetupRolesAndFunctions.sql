-- 1. 新增 Description 欄位 (分開批次)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Roles') AND name = 'Description')
BEGIN
    ALTER TABLE Roles ADD [Description] NVARCHAR(MAX);
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Functions') AND name = 'Description')
BEGIN
    ALTER TABLE Functions ADD [Description] NVARCHAR(MAX);
END
GO

-- 2. 插入/更新 Roles
-- 先更新已存在的
UPDATE Roles SET [Description] = N'訪客(未登入前)，只能瀏覽網頁' WHERE RoleName = 'visitor';
UPDATE Roles SET [Description] = N'登入會員，可使用飲食、生理數據紀錄、方案購買權限、購買運動用品' WHERE RoleName = 'member';
UPDATE Roles SET [Description] = N'專業教練' WHERE RoleName = 'instructor';
UPDATE Roles SET [Description] = N'採購人員，負責上下架商品及庫存管理' WHERE RoleName = 'purchasor';
UPDATE Roles SET [Description] = N'行銷人員，負責制定促銷方案或活動折扣' WHERE RoleName = 'marketor';
UPDATE Roles SET [Description] = N'系統管理員' WHERE RoleName = 'admin';

-- 插入不存在的
IF NOT EXISTS (SELECT * FROM Roles WHERE RoleName = 'visitor') INSERT INTO Roles (RoleName, [Description], IsActive) VALUES ('visitor', N'訪客(未登入前)，只能瀏覽網頁', 1);
IF NOT EXISTS (SELECT * FROM Roles WHERE RoleName = 'member') INSERT INTO Roles (RoleName, [Description], IsActive) VALUES ('member', N'登入會員，可使用飲食、生理數據紀錄、方案購買權限、購買運動用品', 1);
IF NOT EXISTS (SELECT * FROM Roles WHERE RoleName = 'instructor') INSERT INTO Roles (RoleName, [Description], IsActive) VALUES ('instructor', N'專業教練', 1);
IF NOT EXISTS (SELECT * FROM Roles WHERE RoleName = 'purchasor') INSERT INTO Roles (RoleName, [Description], IsActive) VALUES ('purchasor', N'採購人員，負責上下架商品及庫存管理', 1);
IF NOT EXISTS (SELECT * FROM Roles WHERE RoleName = 'marketor') INSERT INTO Roles (RoleName, [Description], IsActive) VALUES ('marketor', N'行銷人員，負責制定促銷方案或活動折扣', 1);
IF NOT EXISTS (SELECT * FROM Roles WHERE RoleName = 'admin') INSERT INTO Roles (RoleName, [Description], IsActive) VALUES ('admin', N'系統管理員', 1);
GO

-- 3. 清除舊有的權限對應關係，重新建立
DELETE FROM RoleFunctions;
GO

-- 4. 插入/更新 Functions (先刪除後插入，因為 Functions 相對獨立)
-- 由於有 RoleFunctions 外鍵約束，必須先 DELETE RoleFunctions
DELETE FROM Functions;
GO

INSERT INTO Functions (FunctionName, [Description], IsActive) VALUES
('edit_Password', N'修改個人自己的登入密碼', 1),
('edit_IntructorDetails', N'修改教練自己的個人簡介', 1),
('edit_InstructorShifts', N'安排或修改教練自己的排班', 1),
('view_InstructorShifts', N'查看所有教練的排班情況', 1),
('edit_UserAccounts', N'管理、設定、修改、停用、恢復所有使用者的帳號', 1),
('edit_RoleFunctions', N'設定每個角色可以使用哪些系統功能(設定每個角色的權限設定)', 1),
('edit_UserRoles', N'新增或修改使用者的所屬角色', 1),
('edit_ProductCategories', N'管理商品的商品分類', 1),
('edit_ProductItems', N'管理商品的商品', 1),
('edit_ProductOrders', N'處理商品的訂單', 1),
('edit_Plans', N'制定或修改促銷方案', 1),
('edit_PlanOrders', N'處理促銷方案或課程購買生成的訂單', 1),
('view_PointRecords', N'查看會員的點數取得及使用紀錄', 1),
('view_ClientFoodRecords', N'查看會員每日的飲食紀錄', 1),
('view_ClientBodyData', N'查看會員生理數據變化', 1),
('edit_Comments_admin', N'系統管理員回覆評論或刪除', 1),
('edit_Comments_instructor', N'專業教練回覆評論', 1);
GO

-- 5. 插入 RoleFunctions 對應關係
INSERT INTO RoleFunctions (RoleId, FunctionId)
SELECT r.Id, f.Id
FROM Roles r, Functions f
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
