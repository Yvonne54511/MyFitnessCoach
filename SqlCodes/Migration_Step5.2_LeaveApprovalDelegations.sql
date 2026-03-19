-- ============================================================
-- Migration Script: Step 5.2 - LeaveApprovalDelegations + RoleFunctions
-- 目的：
--   1. 建立 LeaveApprovalDelegations 資料表（主管假單代審機制）
--   2. 補齊 admin_Holidays / admin_LeaveBalances 的 RoleFunctions
-- ============================================================

USE [MyFitnessCoachDb];
GO

-- ============================================================
-- 1. 建立 LeaveApprovalDelegations 資料表
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'LeaveApprovalDelegations')
BEGIN
    CREATE TABLE LeaveApprovalDelegations (
        Id                  INT IDENTITY(1,1) PRIMARY KEY,
        ManagerEmployeeId   INT NOT NULL,           -- FK -> Employees.Id (委託的主管)
        DelegateEmployeeId  INT NOT NULL,           -- FK -> Employees.Id (被授權的下屬)
        LeaveRequestId      INT NOT NULL,           -- FK -> LeaveRequests.Id (綁定哪張假單)
        StartDate           DATETIME2 NOT NULL,     -- = 主管假單的 StartDate
        EndDate             DATETIME2 NOT NULL,     -- = 主管假單的 EndDate
        IsActive            BIT NOT NULL DEFAULT 1,
        CreatedAt           DATETIME2 NOT NULL DEFAULT GETDATE()
    );

    -- 建立外鍵約束
    ALTER TABLE LeaveApprovalDelegations
        ADD CONSTRAINT FK_ApprDel_Manager
        FOREIGN KEY (ManagerEmployeeId) REFERENCES Employees(Id);

    ALTER TABLE LeaveApprovalDelegations
        ADD CONSTRAINT FK_ApprDel_Delegate
        FOREIGN KEY (DelegateEmployeeId) REFERENCES Employees(Id);

    ALTER TABLE LeaveApprovalDelegations
        ADD CONSTRAINT FK_ApprDel_LeaveReq
        FOREIGN KEY (LeaveRequestId) REFERENCES LeaveRequests(Id);

    PRINT N'[OK] LeaveApprovalDelegations 資料表已建立';
END
ELSE
BEGIN
    PRINT N'[SKIP] LeaveApprovalDelegations 資料表已存在';
END
GO

-- ============================================================
-- 2. 補齊 RoleFunctions: admin_Holidays + admin_LeaveBalances
-- ============================================================

-- admin (RoleId=5) + admin_Holidays (FunctionId=50)
IF NOT EXISTS (SELECT 1 FROM RoleFunctions WHERE RoleId = 5 AND FunctionId = 50)
BEGIN
    INSERT INTO RoleFunctions (RoleId, FunctionId) VALUES (5, 50);
    PRINT N'[OK] 已將 admin_Holidays 指派給 admin 角色';
END
ELSE
BEGIN
    PRINT N'[SKIP] admin 角色已有 admin_Holidays';
END

-- admin (RoleId=5) + admin_LeaveBalances (FunctionId=51)
IF NOT EXISTS (SELECT 1 FROM RoleFunctions WHERE RoleId = 5 AND FunctionId = 51)
BEGIN
    INSERT INTO RoleFunctions (RoleId, FunctionId) VALUES (5, 51);
    PRINT N'[OK] 已將 admin_LeaveBalances 指派給 admin 角色';
END
ELSE
BEGIN
    PRINT N'[SKIP] admin 角色已有 admin_LeaveBalances';
END

-- Role_forDemo (RoleId=11) + admin_Holidays (FunctionId=50)
IF NOT EXISTS (SELECT 1 FROM RoleFunctions WHERE RoleId = 11 AND FunctionId = 50)
BEGIN
    INSERT INTO RoleFunctions (RoleId, FunctionId) VALUES (11, 50);
    PRINT N'[OK] 已將 admin_Holidays 指派給 Role_forDemo 角色';
END
ELSE
BEGIN
    PRINT N'[SKIP] Role_forDemo 角色已有 admin_Holidays';
END

-- Role_forDemo (RoleId=11) + admin_LeaveBalances (FunctionId=51)
IF NOT EXISTS (SELECT 1 FROM RoleFunctions WHERE RoleId = 11 AND FunctionId = 51)
BEGIN
    INSERT INTO RoleFunctions (RoleId, FunctionId) VALUES (11, 51);
    PRINT N'[OK] 已將 admin_LeaveBalances 指派給 Role_forDemo 角色';
END
ELSE
BEGIN
    PRINT N'[SKIP] Role_forDemo 角色已有 admin_LeaveBalances';
END
GO

-- ============================================================
-- 3. 驗證結果
-- ============================================================
PRINT N'';
PRINT N'=== 驗證 ===';

SELECT 'LeaveApprovalDelegations' AS TableName, COUNT(*) AS ColumnCount
FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LeaveApprovalDelegations';

SELECT rf.Id, r.RoleName, f.FunctionName
FROM RoleFunctions rf
JOIN Roles r ON rf.RoleId = r.Id
JOIN Functions f ON rf.FunctionId = f.Id
WHERE f.FunctionName IN ('admin_Holidays', 'admin_LeaveBalances')
ORDER BY r.RoleName, f.FunctionName;

PRINT N'[DONE] Migration 完成';
GO
