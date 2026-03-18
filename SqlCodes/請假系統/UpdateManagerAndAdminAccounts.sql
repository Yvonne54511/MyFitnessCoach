/*
==============================================================================
  更新帳號腳本
  1. 4 位 Manager：Email 改為 manager01~04@fitness.com
  2. 5 位 Admin：Account + UserName 改為 admin1~5（通用管理帳號）
==============================================================================
*/

USE MyFitnessCoachDb;
GO

BEGIN TRANSACTION;

BEGIN TRY

    -- -------------------------------------------------------
    --  Part 1：Manager Email 更新
    --  舊 Email：chenzhiming1@fitness.com ...
    --  新 Email：manager01~04@fitness.com
    -- -------------------------------------------------------
    UPDATE Users SET Email = 'manager01@fitness.com' WHERE Account = 'chenzhiming1';
    UPDATE Users SET Email = 'manager02@fitness.com' WHERE Account = 'linmeiling2';
    UPDATE Users SET Email = 'manager03@fitness.com' WHERE Account = 'zhangjianguo3';
    UPDATE Users SET Email = 'manager04@fitness.com' WHERE Account = 'wangshufen4';

    PRINT N'Manager Email 更新完成';

    -- -------------------------------------------------------
    --  Part 2：Admin Account + UserName 更新
    --  舊 Account：sysadmin01~05 / 舊 UserName：管理員1~5
    --  新 Account：admin1~5     / 新 UserName：admin1~5
    -- -------------------------------------------------------
    UPDATE Users SET Account = 'admin1', UserName = 'admin1' WHERE Account = 'sysadmin01';
    UPDATE Users SET Account = 'admin2', UserName = 'admin2' WHERE Account = 'sysadmin02';
    UPDATE Users SET Account = 'admin3', UserName = 'admin3' WHERE Account = 'sysadmin03';
    UPDATE Users SET Account = 'admin4', UserName = 'admin4' WHERE Account = 'sysadmin04';
    UPDATE Users SET Account = 'admin5', UserName = 'admin5' WHERE Account = 'sysadmin05';

    PRINT N'Admin Account / UserName 更新完成';

    COMMIT TRANSACTION;
    PRINT N'';
    PRINT N'=== 所有帳號更新完成 ===';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'錯誤發生，資料已復原。';
    THROW;
END CATCH
GO

-- -------------------------------------------------------
--  驗證查詢
-- -------------------------------------------------------
SELECT u.Account, u.UserName, u.Email, r.RoleName
FROM Users u
JOIN UserRoles ur ON ur.UserId = u.Id
JOIN Roles r ON r.Id = ur.RoleId
WHERE r.RoleName IN ('manager', 'admin')
ORDER BY r.RoleName, u.Account;
