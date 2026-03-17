-- ============================================================
--  請假系統資料庫建表腳本 v3 (修正版)
--  目標：建立請假系統核心表，並與既有 Users 表關聯
-- ============================================================

USE MyFitnessCoachDb;
GO

-- ============================================================
--  Step 1：刪除請假相關資料表（注意順序：子表先刪）
-- ============================================================
IF OBJECT_ID('FK_Dept_Manager', 'F') IS NOT NULL ALTER TABLE Departments DROP CONSTRAINT FK_Dept_Manager;

DROP TABLE IF EXISTS LeaveBalances;
DROP TABLE IF EXISTS LeaveAttachments;
DROP TABLE IF EXISTS LeaveRequests;
DROP TABLE IF EXISTS LeaveTypes;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Departments;
GO

-- ============================================================
--  PHASE 1：部門 / 員工 / 申請 / 附件
-- ============================================================

-- ------------------------------------------------------------
--  Departments (部門表)
-- ------------------------------------------------------------
CREATE TABLE Departments (
    Id        INT          NOT NULL IDENTITY(1,1),
    Name      NVARCHAR(50) NOT NULL,
    ManagerId INT          NULL,     -- 指向 Employees(Id)

    CONSTRAINT PK_Departments PRIMARY KEY (Id)
);

-- ------------------------------------------------------------
--  Employees (員工擴充表)
--  UserId 對應既有的 Users.Id
-- ------------------------------------------------------------
CREATE TABLE Employees (
    Id             INT  NOT NULL IDENTITY(1,1),
    UserId         INT  NOT NULL,
    DepartmentId   INT  NOT NULL,
    ManagerId      INT  NULL,   -- 直屬主管（自我關聯）
    WorkDelegateId INT  NULL,   -- 主管請假時的審核代理人
    HiredDate      DATE NOT NULL,
    IsActive       BIT  NOT NULL DEFAULT 1,

    CONSTRAINT PK_Employees         PRIMARY KEY (Id),
    CONSTRAINT UQ_Employees_UserId  UNIQUE (UserId),
    CONSTRAINT FK_Employees_Users   FOREIGN KEY (UserId)         REFERENCES Users(Id),
    CONSTRAINT FK_Employees_Dept    FOREIGN KEY (DepartmentId)   REFERENCES Departments(Id),
    CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerId)      REFERENCES Employees(Id),
    CONSTRAINT FK_Employees_WorkDel FOREIGN KEY (WorkDelegateId) REFERENCES Employees(Id)
);

-- 補回 Departments 的 ManagerId 外鍵
ALTER TABLE Departments
    ADD CONSTRAINT FK_Dept_Manager
    FOREIGN KEY (ManagerId) REFERENCES Employees(Id);

-- ------------------------------------------------------------
--  LeaveRequests (請假申請單)
-- ------------------------------------------------------------
CREATE TABLE LeaveRequests (
    Id              INT           NOT NULL IDENTITY(1,1),
    EmployeeId      INT           NOT NULL,
    StartDate       DATETIME      NOT NULL,
    EndDate         DATETIME      NOT NULL,
    DaysUsed        DECIMAL(4,1)  NOT NULL,
    Reason          NVARCHAR(500) NULL,
    Status          NVARCHAR(20)  NOT NULL DEFAULT 'Pending',
    LeaveDelegateId INT           NULL,   -- 職務代理人
    ApprovedBy      INT           NULL,   -- 審核人
    ApprovedAt      DATETIME2(0)  NULL,
    RejectReason    NVARCHAR(300) NULL,
    CreatedAt       DATETIME2(0)  NOT NULL DEFAULT GETDATE(),
    LeaveTypeId     INT           NULL,   -- Phase 2 再關聯 LeaveTypes

    CONSTRAINT PK_LeaveRequests        PRIMARY KEY (Id),
    CONSTRAINT CK_LeaveRequests_Status CHECK (Status IN ('Pending','Approved','Rejected','Cancelled')),
    CONSTRAINT FK_Leave_Employee       FOREIGN KEY (EmployeeId)      REFERENCES Employees(Id),
    CONSTRAINT FK_Leave_LeaveDelegate  FOREIGN KEY (LeaveDelegateId) REFERENCES Employees(Id),
    CONSTRAINT FK_Leave_ApprovedBy     FOREIGN KEY (ApprovedBy)      REFERENCES Employees(Id)
);

CREATE INDEX IX_LeaveRequests_EmployeeId ON LeaveRequests (EmployeeId);
CREATE INDEX IX_LeaveRequests_Status     ON LeaveRequests (Status);

-- ------------------------------------------------------------
--  LeaveAttachments (附件表)
-- ------------------------------------------------------------
CREATE TABLE LeaveAttachments (
    Id         INT           NOT NULL IDENTITY(1,1),
    RequestId  INT           NOT NULL,
    FileName   NVARCHAR(200) NOT NULL,
    FileUrl    NVARCHAR(500) NOT NULL,
    UploadedAt DATETIME2(0)  NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_LeaveAttachments PRIMARY KEY (Id),
    CONSTRAINT FK_Attach_Request   FOREIGN KEY (RequestId) REFERENCES LeaveRequests(Id)
);

-- ============================================================
--  PHASE 2：假別 & 餘額
-- ============================================================

CREATE TABLE LeaveTypes (
    Id          INT          NOT NULL IDENTITY(1,1),
    Name        NVARCHAR(30) NOT NULL,
    DaysPerYear INT          NOT NULL,
    CarryOver   BIT          NOT NULL DEFAULT 0,
    RequiresDoc BIT          NOT NULL DEFAULT 0,
    IsActive    BIT          NOT NULL DEFAULT 1,

    CONSTRAINT PK_LeaveTypes PRIMARY KEY (Id)
);

INSERT INTO LeaveTypes (Name, DaysPerYear, CarryOver, RequiresDoc, IsActive) VALUES
    (N'特休',  15, 1, 0, 1),
    (N'病假',  30, 0, 1, 1),
    (N'事假',  14, 0, 0, 1),
    (N'婚假',   8, 0, 1, 1),
    (N'喪假',   8, 0, 1, 1),
    (N'公假',   0, 0, 1, 1);

CREATE TABLE LeaveBalances (
    Id            INT          NOT NULL IDENTITY(1,1),
    EmployeeId    INT          NOT NULL,
    LeaveTypeId   INT          NOT NULL,
    Year          INT          NOT NULL,
    TotalDays     DECIMAL(4,1) NOT NULL,
    UsedDays      DECIMAL(4,1) NOT NULL DEFAULT 0,
    RemainingDays AS (TotalDays - UsedDays) PERSISTED,

    CONSTRAINT PK_LeaveBalances     PRIMARY KEY (Id),
    CONSTRAINT UQ_LeaveBalances_Key UNIQUE (EmployeeId, LeaveTypeId, Year),
    CONSTRAINT FK_Balance_Employee  FOREIGN KEY (EmployeeId)  REFERENCES Employees(Id),
    CONSTRAINT FK_Balance_LeaveType FOREIGN KEY (LeaveTypeId) REFERENCES LeaveTypes(Id)
);

-- 更新 LeaveRequests 關聯 LeaveTypes
ALTER TABLE LeaveRequests
    ALTER COLUMN LeaveTypeId INT NOT NULL;

ALTER TABLE LeaveRequests
    ADD CONSTRAINT FK_Leave_LeaveType
    FOREIGN KEY (LeaveTypeId) REFERENCES LeaveTypes(Id);

PRINT '請假系統資料表建立完成 (Phase 1 & 2)。';
