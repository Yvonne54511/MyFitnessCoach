-- ============================================================
-- 步驟 4.4 資料庫遷移腳本
-- 新增 Functions + RoleFunctions (國定假日管理 + 假別額度管理)
-- ============================================================

USE MyFitnessCoachDb;
GO

-- ============================================================
-- 1. 新增 Functions
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM Functions WHERE FunctionName = 'admin_Holidays')
BEGIN
    INSERT INTO Functions (FunctionName, Api_path) VALUES ('admin_Holidays', '/AdminLeave/HolidayList');
    PRINT 'OK: Function admin_Holidays added';
END
ELSE
    PRINT 'SKIP: Function admin_Holidays already exists';

IF NOT EXISTS (SELECT 1 FROM Functions WHERE FunctionName = 'admin_LeaveBalances')
BEGIN
    INSERT INTO Functions (FunctionName, Api_path) VALUES ('admin_LeaveBalances', '/AdminLeave/BalanceList');
    PRINT 'OK: Function admin_LeaveBalances added';
END
ELSE
    PRINT 'SKIP: Function admin_LeaveBalances already exists';
GO

-- ============================================================
-- 2. 新增 RoleFunctions（admin = RoleId 5）
-- ============================================================
DECLARE @holidayFuncId INT = (SELECT Id FROM Functions WHERE FunctionName = 'admin_Holidays');
DECLARE @balanceFuncId INT = (SELECT Id FROM Functions WHERE FunctionName = 'admin_LeaveBalances');
DECLARE @adminRoleId INT = 5;

IF NOT EXISTS (SELECT 1 FROM RoleFunctions WHERE RoleId = @adminRoleId AND FunctionId = @holidayFuncId)
BEGIN
    INSERT INTO RoleFunctions (RoleId, FunctionId) VALUES (@adminRoleId, @holidayFuncId);
    PRINT 'OK: RoleFunction admin -> admin_Holidays added';
END
ELSE
    PRINT 'SKIP: RoleFunction admin -> admin_Holidays already exists';

IF NOT EXISTS (SELECT 1 FROM RoleFunctions WHERE RoleId = @adminRoleId AND FunctionId = @balanceFuncId)
BEGIN
    INSERT INTO RoleFunctions (RoleId, FunctionId) VALUES (@adminRoleId, @balanceFuncId);
    PRINT 'OK: RoleFunction admin -> admin_LeaveBalances added';
END
ELSE
    PRINT 'SKIP: RoleFunction admin -> admin_LeaveBalances already exists';
GO

-- ============================================================
-- 3. 驗證
-- ============================================================
SELECT f.Id, f.FunctionName, f.Api_path, r.RoleName
FROM RoleFunctions rf
JOIN Roles r ON rf.RoleId = r.Id
JOIN Functions f ON rf.FunctionId = f.Id
WHERE f.FunctionName IN ('admin_Holidays', 'admin_LeaveBalances')
ORDER BY f.FunctionName;
GO

PRINT '';
PRINT '========================================';
PRINT 'Step 4.4 migration complete!';
PRINT '========================================';
GO
