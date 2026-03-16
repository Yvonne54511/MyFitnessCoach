USE MyFitnessCoachDb;
GO

-- =============================================
-- 1. 建立 Departments 與 Employees 資料表
-- =============================================

-- 刪除舊表（依相依性順序）
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID('dbo.Departments', 'U') IS NOT NULL DROP TABLE dbo.Departments;

-- 建立 Departments
CREATE TABLE dbo.Departments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    ManagerId INT NULL -- 稍後建立 Employees 後再設定 FK
);

-- 建立 Employees
CREATE TABLE dbo.Employees (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL UNIQUE, -- 1-to-1 with Users
    DepartmentId INT NOT NULL,
    ManagerId INT NULL,
    WorkDelegateId INT NULL,
    HiredDate DATE NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Employees_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id),
    CONSTRAINT FK_Employees_Departments FOREIGN KEY (DepartmentId) REFERENCES dbo.Departments(Id),
    CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerId) REFERENCES dbo.Employees(Id),
    CONSTRAINT FK_Employees_Delegate FOREIGN KEY (WorkDelegateId) REFERENCES dbo.Employees(Id)
);

-- 為 Departments 補上 ManagerId 的 FK
ALTER TABLE dbo.Departments 
ADD CONSTRAINT FK_Departments_Manager FOREIGN KEY (ManagerId) REFERENCES dbo.Employees(Id);
GO

-- =============================================
-- 2. 插入部門資料
-- =============================================
INSERT INTO dbo.Departments (Name) VALUES (N'採購部'), (N'行銷部');
GO

-- =============================================
-- 3. 插入員工資料
-- =============================================
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @DeptPurchasing INT, @DeptMarketing INT;
    SELECT @DeptPurchasing = Id FROM dbo.Departments WHERE Name = N'採購部';
    SELECT @DeptMarketing = Id FROM dbo.Departments WHERE Name = N'行銷部';

    -- A. 插入主管級 Employees
    -- 採購主管：陳志明, 林美玲
    INSERT INTO dbo.Employees (UserId, DepartmentId, HiredDate)
    SELECT Id, @DeptPurchasing, DATEADD(DAY, - (ABS(CHECKSUM(NEWID()) % 1000) + 1000), GETDATE())
    FROM dbo.Users WHERE Account IN ('chenzhiming1', 'linmeiling2');

    -- 行銷主管：張建國, 王淑芬
    INSERT INTO dbo.Employees (UserId, DepartmentId, HiredDate)
    SELECT Id, @DeptMarketing, DATEADD(DAY, - (ABS(CHECKSUM(NEWID()) % 1000) + 1000), GETDATE())
    FROM dbo.Users WHERE Account IN ('zhangjianguo3', 'wangshufen4');

    -- B. 獲取主管的 EmployeeId 供後續使用
    DECLARE @EmpId_Chen INT, @EmpId_Lin INT, @EmpId_Zhang INT, @EmpId_Wang INT;
    SELECT @EmpId_Chen = e.Id FROM dbo.Employees e JOIN dbo.Users u ON e.UserId = u.Id WHERE u.Account = 'chenzhiming1';
    SELECT @EmpId_Lin  = e.Id FROM dbo.Employees e JOIN dbo.Users u ON e.UserId = u.Id WHERE u.Account = 'linmeiling2';
    SELECT @EmpId_Zhang = e.Id FROM dbo.Employees e JOIN dbo.Users u ON e.UserId = u.Id WHERE u.Account = 'zhangjianguo3';
    SELECT @EmpId_Wang  = e.Id FROM dbo.Employees e JOIN dbo.Users u ON e.UserId = u.Id WHERE u.Account = 'wangshufen4';

    -- 設定部門的首位主管
    UPDATE dbo.Departments SET ManagerId = @EmpId_Chen WHERE Id = @DeptPurchasing;
    UPDATE dbo.Departments SET ManagerId = @EmpId_Zhang WHERE Id = @DeptMarketing;

    -- 設定主管間的長期代理 (互相代理)
    UPDATE dbo.Employees SET ManagerId = @EmpId_Lin, WorkDelegateId = @EmpId_Lin WHERE Id = @EmpId_Chen;
    UPDATE dbo.Employees SET ManagerId = @EmpId_Chen, WorkDelegateId = @EmpId_Chen WHERE Id = @EmpId_Lin;
    UPDATE dbo.Employees SET ManagerId = @EmpId_Wang, WorkDelegateId = @EmpId_Wang WHERE Id = @EmpId_Zhang;
    UPDATE dbo.Employees SET ManagerId = @EmpId_Zhang, WorkDelegateId = @EmpId_Zhang WHERE Id = @EmpId_Wang;

    -- C. 插入其餘員工 (採購 2027-2036)
    -- 主管採交互分配
    INSERT INTO dbo.Employees (UserId, DepartmentId, ManagerId, WorkDelegateId, HiredDate)
    SELECT 
        U.Id, 
        @DeptPurchasing, 
        CASE WHEN U.Id % 2 = 0 THEN @EmpId_Chen ELSE @EmpId_Lin END,
        CASE WHEN U.Id % 2 = 0 THEN @EmpId_Lin ELSE @EmpId_Chen END, -- 代理人與主管錯開
        DATEADD(DAY, - (ABS(CHECKSUM(NEWID()) % 500) + 100), GETDATE())
    FROM dbo.Users U
    WHERE U.Id BETWEEN 2027 AND 2036;

    -- D. 插入其餘員工 (行銷 2037-2046)
    INSERT INTO dbo.Employees (UserId, DepartmentId, ManagerId, WorkDelegateId, HiredDate)
    SELECT 
        U.Id, 
        @DeptMarketing, 
        CASE WHEN U.Id % 2 = 0 THEN @EmpId_Zhang ELSE @EmpId_Wang END,
        CASE WHEN U.Id % 2 = 0 THEN @EmpId_Wang ELSE @EmpId_Zhang END,
        DATEADD(DAY, - (ABS(CHECKSUM(NEWID()) % 500) + 100), GETDATE())
    FROM dbo.Users U
    WHERE U.Id BETWEEN 2037 AND 2046;

    COMMIT TRANSACTION;
    PRINT N'員工與部門資料初始化成功！';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@ErrMsg, 16, 1);
END CATCH
GO

-- =============================================
-- 4. 建立 View: vw_EmployeePersonnelDetails
-- =============================================
IF OBJECT_ID('dbo.vw_EmployeePersonnelDetails', 'V') IS NOT NULL DROP VIEW dbo.vw_EmployeePersonnelDetails;
GO

CREATE VIEW dbo.vw_EmployeePersonnelDetails AS
SELECT 
    U.UserName AS UserName,
    R.RoleName AS Role,
    D.Name AS DepartmentName,
    MU.UserName AS ManagerName
FROM dbo.Employees E
JOIN dbo.Users U ON E.UserId = U.Id
LEFT JOIN dbo.Departments D ON E.DepartmentId = D.Id
LEFT JOIN dbo.Employees ME ON E.ManagerId = ME.Id
LEFT JOIN dbo.Users MU ON ME.UserId = MU.Id
LEFT JOIN (
    -- 取使用者的第一個角色 (假設一個員工主要只有一個角色)
    SELECT UserId, MIN(RoleId) as RoleId
    FROM dbo.UserRoles
    GROUP BY UserId
) UR_MAIN ON U.Id = UR_MAIN.UserId
LEFT JOIN dbo.Roles R ON UR_MAIN.RoleId = R.Id;
GO

-- 查詢驗證
SELECT * FROM dbo.vw_EmployeePersonnelDetails;
