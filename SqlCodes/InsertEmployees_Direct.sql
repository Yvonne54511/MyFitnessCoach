USE MyFitnessCoachDb;
GO

-- ============================================================
--  採購部員工 (UserId 2027~2036)
--  2027~2031 → 陳志明管轄
--  2032~2036 → 林美玲管轄
-- ============================================================
INSERT INTO Employees (UserId, DepartmentId, ManagerId, WorkDelegateId, HiredDate, IsActive)
SELECT
    u.Id,
    (SELECT Id FROM Departments WHERE Name = N'採購部'),
    (SELECT e.Id FROM Employees e JOIN Users m ON m.Id = e.UserId WHERE m.Account = 'chenzhiming1'),
    NULL,
    DATEADD(DAY, ABS(CHECKSUM(u.Id * 1000003)) % 1461, '2019-01-01'),
    1
FROM Users u
WHERE u.Id BETWEEN 2027 AND 2031
AND NOT EXISTS (SELECT 1 FROM Employees WHERE UserId = u.Id);

INSERT INTO Employees (UserId, DepartmentId, ManagerId, WorkDelegateId, HiredDate, IsActive)
SELECT
    u.Id,
    (SELECT Id FROM Departments WHERE Name = N'採購部'),
    (SELECT e.Id FROM Employees e JOIN Users m ON m.Id = e.UserId WHERE m.Account = 'linmeiling2'),
    NULL,
    DATEADD(DAY, ABS(CHECKSUM(u.Id * 1000003)) % 1461, '2019-01-01'),
    1
FROM Users u
WHERE u.Id BETWEEN 2032 AND 2036
AND NOT EXISTS (SELECT 1 FROM Employees WHERE UserId = u.Id);

PRINT N'採購員工已插入：' + CAST(@@ROWCOUNT AS NVARCHAR) + N' 筆';
GO

-- ============================================================
--  行銷部員工 (UserId 2037~2046)
--  2037~2041 → 張建國管轄
--  2042~2046 → 王淑芬管轄
-- ============================================================
INSERT INTO Employees (UserId, DepartmentId, ManagerId, WorkDelegateId, HiredDate, IsActive)
SELECT
    u.Id,
    (SELECT Id FROM Departments WHERE Name = N'行銷部'),
    (SELECT e.Id FROM Employees e JOIN Users m ON m.Id = e.UserId WHERE m.Account = 'zhangjianguo3'),
    NULL,
    DATEADD(DAY, ABS(CHECKSUM(u.Id * 1000003)) % 1461, '2019-06-01'),
    1
FROM Users u
WHERE u.Id BETWEEN 2037 AND 2041
AND NOT EXISTS (SELECT 1 FROM Employees WHERE UserId = u.Id);

INSERT INTO Employees (UserId, DepartmentId, ManagerId, WorkDelegateId, HiredDate, IsActive)
SELECT
    u.Id,
    (SELECT Id FROM Departments WHERE Name = N'行銷部'),
    (SELECT e.Id FROM Employees e JOIN Users m ON m.Id = e.UserId WHERE m.Account = 'wangshufen4'),
    NULL,
    DATEADD(DAY, ABS(CHECKSUM(u.Id * 1000003)) % 1461, '2019-06-01'),
    1
FROM Users u
WHERE u.Id BETWEEN 2042 AND 2046
AND NOT EXISTS (SELECT 1 FROM Employees WHERE UserId = u.Id);

PRINT N'行銷員工已插入：' + CAST(@@ROWCOUNT AS NVARCHAR) + N' 筆';
GO

-- ============================================================
--  WorkDelegateId 環形分配 (+3 位移)
-- ============================================================
UPDATE emp
SET    emp.WorkDelegateId = r2.EmpId
FROM   Employees emp
JOIN (
    SELECT e.Id AS EmpId, e.DepartmentId,
           ROW_NUMBER() OVER (PARTITION BY e.DepartmentId ORDER BY e.UserId) - 1 AS Rn,
           COUNT(*)      OVER (PARTITION BY e.DepartmentId)                       AS Cnt
    FROM   Employees e
    WHERE  e.UserId BETWEEN 2027 AND 2046
) r1 ON r1.EmpId = emp.Id
JOIN (
    SELECT e.Id AS EmpId, e.DepartmentId,
           ROW_NUMBER() OVER (PARTITION BY e.DepartmentId ORDER BY e.UserId) - 1 AS Rn
    FROM   Employees e
    WHERE  e.UserId BETWEEN 2027 AND 2046
) r2 ON  r2.DepartmentId = r1.DepartmentId
     AND r2.Rn            = (r1.Rn + 3) % r1.Cnt;

PRINT N'WorkDelegateId 環形分配完成：' + CAST(@@ROWCOUNT AS NVARCHAR) + N' 筆';
GO

-- ============================================================
--  驗證結果
-- ============================================================
SELECT UserName, Role, DepartmentName, ManagerName
FROM   vw_EmployeeDeptInfo
ORDER  BY DepartmentName, Role DESC, UserName;

==========================================

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
