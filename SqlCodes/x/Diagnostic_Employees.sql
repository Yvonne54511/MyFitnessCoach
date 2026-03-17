USE MyFitnessCoachDb;
GO

-- 1. 確認採購 / 行銷 Users 實際的 Account 格式
SELECT Id, Account, UserName, IsActive
FROM   Users
WHERE  Account LIKE 'purch%' OR Account LIKE 'market%'
ORDER  BY Account;

-- 2. 確認目前 Employees 已有幾筆
SELECT COUNT(*) AS TotalEmployees FROM Employees;

-- 3. 看目前 Employees 裡有誰（帶出 Account）
SELECT e.Id AS EmployeeId, u.Id AS UserId, u.Account, u.UserName, e.HiredDate
FROM   Employees e
JOIN   Users u ON u.Id = e.UserId
ORDER  BY u.Account;
