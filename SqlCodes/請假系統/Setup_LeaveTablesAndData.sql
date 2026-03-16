/*
==============================================================================
  建立 LeaveTypes / LeaveRequests / LeaveAttachments / LeaveBalances
  + 種子資料 + 每位員工 5 筆請假紀錄 + 勞基法特休計算
  前置條件：Departments、Employees 資料表已存在且有資料
==============================================================================
*/
USE MyFitnessCoachDb;
GO

-- ============================================================
--  PHASE 1：建立 LeaveTypes
-- ============================================================
IF OBJECT_ID('dbo.LeaveTypes', 'U') IS NULL
BEGIN
    CREATE TABLE LeaveTypes (
        Id          INT          NOT NULL IDENTITY(1,1),
        Name        NVARCHAR(30) NOT NULL,
        DaysPerYear INT          NOT NULL,
        CarryOver   BIT          NOT NULL DEFAULT 0,
        RequiresDoc BIT          NOT NULL DEFAULT 0,
        IsActive    BIT          NOT NULL DEFAULT 1,
        CONSTRAINT PK_LeaveTypes PRIMARY KEY (Id)
    );
    PRINT N'[DDL] LeaveTypes 建立完成';
END
ELSE PRINT N'[DDL] LeaveTypes 已存在';
GO

-- ============================================================
--  PHASE 2：建立 LeaveRequests
-- ============================================================
IF OBJECT_ID('dbo.LeaveRequests', 'U') IS NULL
BEGIN
    CREATE TABLE LeaveRequests (
        Id              INT           NOT NULL IDENTITY(1,1),
        EmployeeId      INT           NOT NULL,
        LeaveTypeId     INT           NOT NULL,
        StartDate       DATETIME      NOT NULL,
        EndDate         DATETIME      NOT NULL,
        DaysUsed        DECIMAL(4,1)  NOT NULL,
        Reason          NVARCHAR(500) NULL,
        Status          NVARCHAR(20)  NOT NULL DEFAULT 'Pending',
        LeaveDelegateId INT           NULL,
        ApprovedBy      INT           NULL,
        ApprovedAt      DATETIME2(0)  NULL,
        RejectReason    NVARCHAR(300) NULL,
        CreatedAt       DATETIME2(0)  NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_LeaveRequests        PRIMARY KEY (Id),
        CONSTRAINT CK_LeaveRequests_Status CHECK (Status IN ('Pending','Approved','Rejected','Cancelled')),
        CONSTRAINT FK_Leave_Employee       FOREIGN KEY (EmployeeId)      REFERENCES Employees(Id),
        CONSTRAINT FK_Leave_LeaveType      FOREIGN KEY (LeaveTypeId)     REFERENCES LeaveTypes(Id),
        CONSTRAINT FK_Leave_LeaveDelegate  FOREIGN KEY (LeaveDelegateId) REFERENCES Employees(Id),
        CONSTRAINT FK_Leave_ApprovedBy     FOREIGN KEY (ApprovedBy)      REFERENCES Employees(Id)
    );
    CREATE INDEX IX_LeaveRequests_EmployeeId ON LeaveRequests (EmployeeId);
    CREATE INDEX IX_LeaveRequests_Status     ON LeaveRequests (Status);
    PRINT N'[DDL] LeaveRequests 建立完成';
END
ELSE PRINT N'[DDL] LeaveRequests 已存在';
GO

-- ============================================================
--  PHASE 3：建立 LeaveAttachments
-- ============================================================
IF OBJECT_ID('dbo.LeaveAttachments', 'U') IS NULL
BEGIN
    CREATE TABLE LeaveAttachments (
        Id         INT           NOT NULL IDENTITY(1,1),
        RequestId  INT           NOT NULL,
        FileName   NVARCHAR(200) NOT NULL,
        FileUrl    NVARCHAR(500) NOT NULL,
        UploadedAt DATETIME2(0)  NOT NULL DEFAULT GETDATE(),
        CONSTRAINT PK_LeaveAttachments PRIMARY KEY (Id),
        CONSTRAINT FK_Attach_Request   FOREIGN KEY (RequestId) REFERENCES LeaveRequests(Id)
    );
    PRINT N'[DDL] LeaveAttachments 建立完成';
END
ELSE PRINT N'[DDL] LeaveAttachments 已存在';
GO

-- ============================================================
--  PHASE 4：建立 LeaveBalances
-- ============================================================
IF OBJECT_ID('dbo.LeaveBalances', 'U') IS NULL
BEGIN
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
    PRINT N'[DDL] LeaveBalances 建立完成';
END
ELSE PRINT N'[DDL] LeaveBalances 已存在';
GO

-- ============================================================
--  PHASE 5：LeaveTypes 種子資料
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM LeaveTypes)
BEGIN
    INSERT INTO LeaveTypes (Name, DaysPerYear, CarryOver, RequiresDoc, IsActive) VALUES
        (N'特休', 15, 1, 0, 1),
        (N'病假', 30, 0, 1, 1),
        (N'事假', 14, 0, 0, 1),
        (N'婚假',  8, 0, 1, 1),
        (N'喪假',  8, 0, 1, 1),
        (N'公假',  0, 0, 1, 1);
    PRINT N'[種子] LeaveTypes 6 筆已插入';
END
ELSE PRINT N'[種子] LeaveTypes 已存在';
GO

-- ============================================================
--  PHASE 6：LeaveBalances — 依勞基法第 38 條計算 2026 年特休
--
--  完整年資公式（精確到日）：
--    fullYears = DATEDIFF(YEAR, HiredDate, '2026-01-01')
--      - CASE WHEN anniversary > '2026-01-01' THEN 1 ELSE 0 END
--
--  勞基法第 38 條：
--    滿 6 個月未滿 1 年 → 3 天
--    滿 1 年未滿 2 年   → 7 天
--    滿 2 年未滿 3 年   → 10 天
--    滿 3 年未滿 5 年   → 14 天
--    滿 5 年未滿 10 年  → 15 天
--    滿 10 年起         → 每年 +1 天，上限 30 天
-- ============================================================
INSERT INTO LeaveBalances (EmployeeId, LeaveTypeId, Year, TotalDays, UsedDays)
SELECT
    e.Id,
    lt.Id,
    2026,
    CASE lt.Name
        WHEN N'特休' THEN
            CASE
                WHEN fullYears >= 10 THEN CAST(LEAST(15 + fullYears - 10, 30) AS DECIMAL(4,1))
                WHEN fullYears >= 5  THEN 15.0
                WHEN fullYears >= 3  THEN 14.0
                WHEN fullYears >= 2  THEN 10.0
                WHEN fullYears >= 1  THEN 7.0
                WHEN fullMonths >= 6 THEN 3.0
                ELSE 0.0
            END
        WHEN N'病假' THEN 30.0
        WHEN N'事假' THEN 14.0
        WHEN N'婚假' THEN 8.0
        WHEN N'喪假' THEN 8.0
        WHEN N'公假' THEN 0.0
    END,
    0.0
FROM Employees e
CROSS JOIN LeaveTypes lt
CROSS APPLY (
    SELECT
        DATEDIFF(YEAR, e.HiredDate, '2026-01-01')
            - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, e.HiredDate, '2026-01-01'), e.HiredDate) > '2026-01-01'
                   THEN 1 ELSE 0 END AS fullYears,
        DATEDIFF(MONTH, e.HiredDate, '2026-01-01')
            - CASE WHEN DATEADD(MONTH, DATEDIFF(MONTH, e.HiredDate, '2026-01-01'), e.HiredDate) > '2026-01-01'
                   THEN 1 ELSE 0 END AS fullMonths
) calc
WHERE e.IsActive = 1
AND NOT EXISTS (
    SELECT 1 FROM LeaveBalances lb
    WHERE lb.EmployeeId = e.Id AND lb.LeaveTypeId = lt.Id AND lb.Year = 2026
);

PRINT N'[Balance] LeaveBalances 2026 年度已插入：' + CAST(@@ROWCOUNT AS NVARCHAR) + N' 筆';
GO

-- ============================================================
--  PHASE 7：每位員工 5 筆 LeaveRequests
--
--  #1  特休 1天   Approved   1月
--  #2  病假 1天   Approved   2月（需附件）
--  #3  事假 1天   Rejected   2月
--  #4  特休 1天   Pending    4月（未來）
--  #5  事假 0.5天 Cancelled  3月
--
--  日期依 Employee.Id 偏移，避免全員同日請假
--  ApprovedBy：有主管用主管，主管本人則用 WorkDelegateId
-- ============================================================
INSERT INTO LeaveRequests
    (EmployeeId, LeaveTypeId, StartDate, EndDate, DaysUsed,
     Reason, Status, LeaveDelegateId, ApprovedBy, ApprovedAt, RejectReason, CreatedAt)
SELECT
    e.Id,
    lt_id,
    start_dt,
    CASE WHEN days_used = 0.5 THEN start_dt ELSE DATEADD(DAY, 1, start_dt) END,
    days_used,
    reason,
    status,
    e.WorkDelegateId,
    CASE WHEN status IN ('Approved','Rejected') THEN ISNULL(e.ManagerId, e.WorkDelegateId) ELSE NULL END,
    CASE WHEN status IN ('Approved','Rejected') THEN DATEADD(DAY, -1, start_dt) ELSE NULL END,
    CASE WHEN status = 'Rejected' THEN N'該日部門人力不足，建議改期' ELSE NULL END,
    DATEADD(DAY, -3, start_dt)
FROM Employees e
CROSS APPLY (
    VALUES
        (1, (SELECT Id FROM LeaveTypes WHERE Name=N'特休'), 1.0, N'個人休假',             'Approved',
            DATEADD(DAY, (e.Id % 20),      '2026-01-06')),
        (2, (SELECT Id FROM LeaveTypes WHERE Name=N'病假'), 1.0, N'身體不適需就醫',       'Approved',
            DATEADD(DAY, (e.Id % 15),      '2026-02-02')),
        (3, (SELECT Id FROM LeaveTypes WHERE Name=N'事假'), 1.0, N'處理私人事務',         'Rejected',
            DATEADD(DAY, (e.Id % 10),      '2026-02-16')),
        (4, (SELECT Id FROM LeaveTypes WHERE Name=N'特休'), 1.0, N'家庭旅遊計畫',         'Pending',
            DATEADD(DAY, (e.Id % 20),      '2026-04-07')),
        (5, (SELECT Id FROM LeaveTypes WHERE Name=N'事假'), 0.5, N'辦理個人事務（半天）', 'Cancelled',
            DATEADD(DAY, (e.Id % 15),      '2026-03-02'))
) AS req(seq, lt_id, days_used, reason, status, start_dt)
WHERE e.IsActive = 1
AND NOT EXISTS (SELECT 1 FROM LeaveRequests lr WHERE lr.EmployeeId = e.Id);

PRINT N'[Leave] LeaveRequests 已插入：' + CAST(@@ROWCOUNT AS NVARCHAR) + N' 筆';
GO

-- ============================================================
--  PHASE 8：LeaveAttachments — 病假附件（RequiresDoc = 1）
-- ============================================================
INSERT INTO LeaveAttachments (RequestId, FileName, FileUrl, UploadedAt)
SELECT
    lr.Id,
    N'診斷證明_' + u.UserName + N'.pdf',
    N'/uploads/leave-docs/' + CAST(lr.Id AS NVARCHAR) + N'.pdf',
    lr.CreatedAt
FROM LeaveRequests lr
JOIN Employees e   ON e.Id  = lr.EmployeeId
JOIN Users     u   ON u.Id  = e.UserId
JOIN LeaveTypes lt ON lt.Id = lr.LeaveTypeId
WHERE lt.RequiresDoc = 1
AND   lr.Status != 'Cancelled'
AND NOT EXISTS (SELECT 1 FROM LeaveAttachments la WHERE la.RequestId = lr.Id);

PRINT N'[Attach] 病假附件已插入：' + CAST(@@ROWCOUNT AS NVARCHAR) + N' 筆';
GO

-- ============================================================
--  PHASE 9：更新 LeaveBalances.UsedDays（依已核准的申請計算）
-- ============================================================
UPDATE lb
SET    lb.UsedDays = ISNULL(agg.TotalUsed, 0)
FROM   LeaveBalances lb
LEFT JOIN (
    SELECT EmployeeId, LeaveTypeId, SUM(DaysUsed) AS TotalUsed
    FROM   LeaveRequests
    WHERE  Status = 'Approved'
    GROUP  BY EmployeeId, LeaveTypeId
) agg ON agg.EmployeeId = lb.EmployeeId AND agg.LeaveTypeId = lb.LeaveTypeId
WHERE  lb.Year = 2026;

PRINT N'[Balance] UsedDays 已更新：' + CAST(@@ROWCOUNT AS NVARCHAR) + N' 筆';
GO

-- ============================================================
--  驗證查詢
-- ============================================================

-- 1. 各假別年度配額（含特休天數 — 確認勞基法計算）
SELECT
    u.UserName,
    e.HiredDate,
    lt.Name AS LeaveType,
    lb.TotalDays,
    lb.UsedDays,
    lb.RemainingDays
FROM LeaveBalances lb
JOIN Employees e   ON e.Id  = lb.EmployeeId
JOIN Users     u   ON u.Id  = e.UserId
JOIN LeaveTypes lt ON lt.Id = lb.LeaveTypeId
WHERE lt.Name = N'特休' AND lb.Year = 2026
ORDER BY e.HiredDate;

-- 2. 請假紀錄（含狀態分布）
SELECT Status, COUNT(*) AS Cnt
FROM   LeaveRequests
GROUP  BY Status
ORDER  BY Status;

-- 3. 全部請假明細
SELECT
    u.UserName,
    lt.Name  AS LeaveType,
    lr.StartDate,
    lr.DaysUsed,
    lr.Status,
    lr.Reason,
    lr.RejectReason,
    approver.UserName AS ApprovedByName
FROM LeaveRequests lr
JOIN Employees e        ON e.Id  = lr.EmployeeId
JOIN Users     u        ON u.Id  = e.UserId
JOIN LeaveTypes lt      ON lt.Id = lr.LeaveTypeId
LEFT JOIN Employees ae  ON ae.Id = lr.ApprovedBy
LEFT JOIN Users approver ON approver.Id = ae.UserId
ORDER BY u.UserName, lr.StartDate;
