/*
==============================================================================
  新增 Manager 角色 + 4 位主管帳號
  密碼：123456 (ASP.NET Core Identity V3 PBKDF2-HMAC-SHA256)
==============================================================================
*/

USE MyFitnessCoachDb;
GO

BEGIN TRANSACTION;

BEGIN TRY

    -- -------------------------------------------------------
    --  Step 1：新增 manager Role（若已存在則略過）
    -- -------------------------------------------------------
    DECLARE @ManagerRoleId INT;

    SELECT @ManagerRoleId = Id FROM Roles WHERE RoleName = 'manager';

    IF @ManagerRoleId IS NULL
    BEGIN
        INSERT INTO Roles (RoleName, IsActive, Description)
        VALUES ('manager', 1, N'部門主管，負責審核請假申請');

        SET @ManagerRoleId = SCOPE_IDENTITY();
        PRINT N'角色 [manager] 建立成功，RoleId = ' + CAST(@ManagerRoleId AS NVARCHAR);
    END
    ELSE
    BEGIN
        PRINT N'角色 [manager] 已存在，RoleId = ' + CAST(@ManagerRoleId AS NVARCHAR);
    END

    -- -------------------------------------------------------
    --  Step 2：4 位主管帳號
    --  密碼：123456
    -- -------------------------------------------------------
    DECLARE @Hash NVARCHAR(256) = N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==';
    DECLARE @NewUserId INT;

    -- 主管 1：陳志明
    IF NOT EXISTS (SELECT 1 FROM Users WHERE Account = 'chenzhiming1')
    BEGIN
        INSERT INTO Users (Account, HashedPassword, UserName, Email, Mobile, IsConfirmed, IsActive)
        VALUES ('chenzhiming1', @Hash, N'陳志明', 'chenzhiming1@fitness.com', '0960000001', 1, 1);

        SET @NewUserId = SCOPE_IDENTITY();
        INSERT INTO UserRoles (UserId, RoleId) VALUES (@NewUserId, @ManagerRoleId);
        PRINT N'帳號 chenzhiming1 (陳志明) 建立成功';
    END
    ELSE PRINT N'帳號 chenzhiming1 已存在，略過';

    -- 主管 2：林美玲
    IF NOT EXISTS (SELECT 1 FROM Users WHERE Account = 'linmeiling2')
    BEGIN
        INSERT INTO Users (Account, HashedPassword, UserName, Email, Mobile, IsConfirmed, IsActive)
        VALUES ('linmeiling2', @Hash, N'林美玲', 'linmeiling2@fitness.com', '0960000002', 1, 1);

        SET @NewUserId = SCOPE_IDENTITY();
        INSERT INTO UserRoles (UserId, RoleId) VALUES (@NewUserId, @ManagerRoleId);
        PRINT N'帳號 linmeiling2 (林美玲) 建立成功';
    END
    ELSE PRINT N'帳號 linmeiling2 已存在，略過';

    -- 主管 3：張建國
    IF NOT EXISTS (SELECT 1 FROM Users WHERE Account = 'zhangjianguo3')
    BEGIN
        INSERT INTO Users (Account, HashedPassword, UserName, Email, Mobile, IsConfirmed, IsActive)
        VALUES ('zhangjianguo3', @Hash, N'張建國', 'zhangjianguo3@fitness.com', '0960000003', 1, 1);

        SET @NewUserId = SCOPE_IDENTITY();
        INSERT INTO UserRoles (UserId, RoleId) VALUES (@NewUserId, @ManagerRoleId);
        PRINT N'帳號 zhangjianguo3 (張建國) 建立成功';
    END
    ELSE PRINT N'帳號 zhangjianguo3 已存在，略過';

    -- 主管 4：王淑芬
    IF NOT EXISTS (SELECT 1 FROM Users WHERE Account = 'wangshufen4')
    BEGIN
        INSERT INTO Users (Account, HashedPassword, UserName, Email, Mobile, IsConfirmed, IsActive)
        VALUES ('wangshufen4', @Hash, N'王淑芬', 'wangshufen4@fitness.com', '0960000004', 1, 1);

        SET @NewUserId = SCOPE_IDENTITY();
        INSERT INTO UserRoles (UserId, RoleId) VALUES (@NewUserId, @ManagerRoleId);
        PRINT N'帳號 wangshufen4 (王淑芬) 建立成功';
    END
    ELSE PRINT N'帳號 wangshufen4 已存在，略過';

    COMMIT TRANSACTION;
    PRINT N'';
    PRINT N'=== 完成：Manager 角色與 4 位主管帳號已就緒 ===';

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
WHERE r.RoleName = 'manager'
ORDER BY u.Account;
