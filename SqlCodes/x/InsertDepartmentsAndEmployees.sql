/*
==============================================================================
  建立 Departments、Employees 資料表 + 插入資料 + View
  前置條件：已執行
    1. InsertManagerRoleAndUsers.sql    (4 位主管帳號)
    2. GenerateTestData_Staff.sql       (採購 purch01~10、行銷 market01~10)
==============================================================================
*/

USE MyFitnessCoachDb;
GO

-- ============================================================
--  PHASE 1-A：建立 Departments (ManagerId 暫不加外鍵)
-- ============================================================
IF OBJECT_ID('FK_Dept_Manager', 'F') IS NOT NULL
    ALTER TABLE Departments DROP CONSTRAINT FK_Dept_Manager;

IF OBJECT_ID('dbo.Departments', 'U') IS NULL
BEGIN
    CREATE TABLE Departments (
        Id        INT          NOT NULL IDENTITY(1,1),
        Name      NVARCHAR(50) NOT NULL,
        ManagerId INT          NULL,
        CONSTRAINT PK_Departments PRIMARY KEY (Id)
    );
    PRINT N'[DDL] Departments 建立完成';
END
ELSE
    PRINT N'[DDL] Departments 已存在，略過';
GO

-- ============================================================
--  PHASE 1-B：建立 Employees
-- ============================================================
IF OBJECT_ID('dbo.Employees', 'U') IS NULL
BEGIN
    CREATE TABLE Employees (
        Id             INT  NOT NULL IDENTITY(1,1),
        UserId         INT  NOT NULL,
        DepartmentId   INT  NOT NULL,
        ManagerId      INT  NULL,
        WorkDelegateId INT  NULL,
        HiredDate      DATE NOT NULL,
        IsActive       BIT  NOT NULL DEFAULT 1,

        CONSTRAINT PK_Employees         PRIMARY KEY (Id),
        CONSTRAINT UQ_Employees_UserId  UNIQUE (UserId),
        CONSTRAINT FK_Employees_Users   FOREIGN KEY (UserId)         REFERENCES Users(Id),
        CONSTRAINT FK_Employees_Dept    FOREIGN KEY (DepartmentId)   REFERENCES Departments(Id),
        CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerId)      REFERENCES Employees(Id),
        CONSTRAINT FK_Employees_WorkDel FOREIGN KEY (WorkDelegateId) REFERENCES Employees(Id)
    );
    PRINT N'[DDL] Employees 建立完成';
END
ELSE
    PRINT N'[DDL] Employees 已存在，略過';
GO

-- ============================================================
--  PHASE 1-C：補回 Departments → Employees 的外鍵
-- ============================================================
IF OBJECT_ID('FK_Dept_Manager', 'F') IS NULL
BEGIN
    ALTER TABLE Departments
        ADD CONSTRAINT FK_Dept_Manager
        FOREIGN KEY (ManagerId) REFERENCES Employees(Id);
    PRINT N'[DDL] FK_Dept_Manager 建立完成';
END
GO

-- ============================================================
--  PHASE 2：插入資料
--  注意：DECLARE 必須在 BEGIN TRANSACTION 之前宣告，
--        否則 TRY 區塊內的 CTE / 複雜語法會導致整批解析失敗
-- ============================================================
DECLARE @DeptPurId INT, @DeptMktId INT;
DECLARE @UID_CZM   INT, @UID_LML INT, @UID_ZJG INT, @UID_WSF INT;
DECLARE @EID_CZM   INT, @EID_LML INT, @EID_ZJG INT, @EID_WSF INT;
DECLARE @i INT, @uid INT, @mgr INT, @hired DATE;

BEGIN TRANSACTION;
BEGIN TRY

    -- -------------------------------------------------------
    --  Step 1：建立兩個部門
    -- -------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM Departments WHERE Name = N'採購部')
    BEGIN
        INSERT INTO Departments (Name) VALUES (N'採購部');
        SET @DeptPurId = SCOPE_IDENTITY();
    END
    ELSE SELECT @DeptPurId = Id FROM Departments WHERE Name = N'採購部';

    IF NOT EXISTS (SELECT 1 FROM Departments WHERE Name = N'行銷部')
    BEGIN
        INSERT INTO Departments (Name) VALUES (N'行銷部');
        SET @DeptMktId = SCOPE_IDENTITY();
    END
    ELSE SELECT @DeptMktId = Id FROM Departments WHERE Name = N'行銷部';

    PRINT N'[Step 1] 採購部 Id=' + CAST(@DeptPurId AS NVARCHAR)
        + N'  行銷部 Id=' + CAST(@DeptMktId AS NVARCHAR);

    -- -------------------------------------------------------
    --  Step 2：取得 4 位主管 UserId
    -- -------------------------------------------------------
    SELECT @UID_CZM = Id FROM Users WHERE Account = 'chenzhiming1';
    SELECT @UID_LML = Id FROM Users WHERE Account = 'linmeiling2';
    SELECT @UID_ZJG = Id FROM Users WHERE Account = 'zhangjianguo3';
    SELECT @UID_WSF = Id FROM Users WHERE Account = 'wangshufen4';

    IF @UID_CZM IS NULL OR @UID_LML IS NULL OR @UID_ZJG IS NULL OR @UID_WSF IS NULL
        THROW 50001, N'找不到一或多位主管帳號，請先執行 InsertManagerRoleAndUsers.sql', 1;

    -- -------------------------------------------------------
    --  Step 3：插入 4 位主管為 Employees (WorkDelegateId 暫 NULL)
    -- -------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE UserId = @UID_CZM)
    BEGIN
        INSERT INTO Employees (UserId, DepartmentId, ManagerId, WorkDelegateId, HiredDate, IsActive)
        VALUES (@UID_CZM, @DeptPurId, NULL, NULL, '2016-04-01', 1);
        SET @EID_CZM = SCOPE_IDENTITY();
    END
    ELSE SELECT @EID_CZM = Id FROM Employees WHERE UserId = @UID_CZM;

    IF NOT EXISTS (SELECT 1 FROM Employees WHERE UserId = @UID_LML)
    BEGIN
        INSERT INTO Employees (UserId, DepartmentId, ManagerId, WorkDelegateId, HiredDate, IsActive)
        VALUES (@UID_LML, @DeptPurId, NULL, NULL, '2017-09-15', 1);
        SET @EID_LML = SCOPE_IDENTITY();
    END
    ELSE SELECT @EID_LML = Id FROM Employees WHERE UserId = @UID_LML;

    IF NOT EXISTS (SELECT 1 FROM Employees WHERE UserId = @UID_ZJG)
    BEGIN
        INSERT INTO Employees (UserId, DepartmentId, ManagerId, WorkDelegateId, HiredDate, IsActive)
        VALUES (@UID_ZJG, @DeptMktId, NULL, NULL, '2015-11-20', 1);
        SET @EID_ZJG = SCOPE_IDENTITY();
    END
    ELSE SELECT @EID_ZJG = Id FROM Employees WHERE UserId = @UID_ZJG;

    IF NOT EXISTS (SELECT 1 FROM Employees WHERE UserId = @UID_WSF)
    BEGIN
        INSERT INTO Employees (UserId, DepartmentId, ManagerId, WorkDelegateId, HiredDate, IsActive)
        VALUES (@UID_WSF, @DeptMktId, NULL, NULL, '2018-03-10', 1);
        SET @EID_WSF = SCOPE_IDENTITY();
    END
    ELSE SELECT @EID_WSF = Id FROM Employees WHERE UserId = @UID_WSF;

    PRINT N'[Step 3] 主管 EmployeeId：陳志明=' + CAST(@EID_CZM AS NVARCHAR)
        + N' 林美玲='  + CAST(@EID_LML AS NVARCHAR)
        + N' 張建國='  + CAST(@EID_ZJG AS NVARCHAR)
        + N' 王淑芬='  + CAST(@EID_WSF AS NVARCHAR);

    -- -------------------------------------------------------
    --  Step 4：設定 Departments 主要主管
    -- -------------------------------------------------------
    UPDATE Departments SET ManagerId = @EID_CZM WHERE Id = @DeptPurId;
    UPDATE Departments SET ManagerId = @EID_ZJG WHERE Id = @DeptMktId;
    PRINT N'[Step 4] Departments.ManagerId 設定完成';

    -- -------------------------------------------------------
    --  Step 5：主管互相代理
    --  採購：陳志明 ↔ 林美玲 / 行銷：張建國 ↔ 王淑芬
    -- -------------------------------------------------------
    UPDATE Employees SET WorkDelegateId = @EID_LML WHERE Id = @EID_CZM;
    UPDATE Employees SET WorkDelegateId = @EID_CZM WHERE Id = @EID_LML;
    UPDATE Employees SET WorkDelegateId = @EID_WSF WHERE Id = @EID_ZJG;
    UPDATE Employees SET WorkDelegateId = @EID_ZJG WHERE Id = @EID_WSF;
    PRINT N'[Step 5] 主管代理人設定完成';

    -- -------------------------------------------------------
    --  Step 6：插入一般員工
    --  採購 purch01~05 → 陳志明；purch06~10 → 林美玲
    --  行銷 market01~05 → 張建國；market06~10 → 王淑芬
    -- -------------------------------------------------------
    SET @i = 1;
    WHILE @i <= 10
    BEGIN
        SELECT @uid = Id FROM Users
        WHERE Account = 'purch' + RIGHT('00' + CAST(@i AS NVARCHAR), 2);

        IF @uid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Employees WHERE UserId = @uid)
        BEGIN
            SET @mgr   = CASE WHEN @i <= 5 THEN @EID_CZM ELSE @EID_LML END;
            SET @hired = DATEADD(DAY, ABS(CHECKSUM(@uid * 1000003)) % 1461, '2019-01-01');
            INSERT INTO Employees (UserId, DepartmentId, ManagerId, WorkDelegateId, HiredDate, IsActive)
            VALUES (@uid, @DeptPurId, @mgr, NULL, @hired, 1);
        END
        SET @uid = NULL;
        SET @i   = @i + 1;
    END

    SET @i = 1;
    WHILE @i <= 10
    BEGIN
        SELECT @uid = Id FROM Users
        WHERE Account = 'market' + RIGHT('00' + CAST(@i AS NVARCHAR), 2);

        IF @uid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Employees WHERE UserId = @uid)
        BEGIN
            SET @mgr   = CASE WHEN @i <= 5 THEN @EID_ZJG ELSE @EID_WSF END;
            SET @hired = DATEADD(DAY, ABS(CHECKSUM(@uid * 1000003)) % 1461, '2019-06-01');
            INSERT INTO Employees (UserId, DepartmentId, ManagerId, WorkDelegateId, HiredDate, IsActive)
            VALUES (@uid, @DeptMktId, @mgr, NULL, @hired, 1);
        END
        SET @uid = NULL;
        SET @i   = @i + 1;
    END

    PRINT N'[Step 6] 一般員工插入完成';

    -- -------------------------------------------------------
    --  Step 7：WorkDelegateId 環形分配 (+3 位移)
    --  用 SELECT INTO #ring 暫存表取代 CTE，避免 TRY 內解析錯誤
    -- -------------------------------------------------------
    SELECT
        emp.Id                                                                          AS EmpId,
        emp.DepartmentId,
        CAST(ROW_NUMBER() OVER (PARTITION BY emp.DepartmentId ORDER BY usr.Account) - 1
             AS INT)                                                                    AS Rn,
        CAST(COUNT(*)      OVER (PARTITION BY emp.DepartmentId)
             AS INT)                                                                    AS Cnt
    INTO #ring
    FROM Employees emp
    JOIN Users     usr ON usr.Id = emp.UserId
    WHERE usr.Account LIKE 'purch%' OR usr.Account LIKE 'market%';

    UPDATE emp
    SET    emp.WorkDelegateId = r2.EmpId
    FROM   Employees emp
    JOIN   #ring r1 ON  r1.EmpId = emp.Id
    JOIN   #ring r2 ON  r2.DepartmentId = r1.DepartmentId
                    AND r2.Rn = (r1.Rn + 3) % r1.Cnt;

    DROP TABLE #ring;

    PRINT N'[Step 7] WorkDelegateId 環形分配完成 (+3 位移)';

    COMMIT TRANSACTION;
    PRINT N'';
    PRINT N'=== PHASE 2 完成：Departments + Employees 資料就緒 ===';

END TRY
BEGIN CATCH
    IF OBJECT_ID('tempdb..#ring') IS NOT NULL DROP TABLE #ring;
    ROLLBACK TRANSACTION;
    PRINT N'錯誤發生，資料已復原。';
    THROW;
END CATCH
GO

-- ============================================================
--  PHASE 3：建立 View
-- ============================================================
CREATE OR ALTER VIEW vw_EmployeeDeptInfo AS
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

-- ============================================================
--  驗證查詢
-- ============================================================
SELECT UserName, Role, DepartmentName, ManagerName
FROM   vw_EmployeeDeptInfo
ORDER  BY DepartmentName, Role DESC, UserName;
