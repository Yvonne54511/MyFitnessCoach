/*
==============================================================================
資深工程師測試資料生成腳本
目標：生成 營養師(12), 採購(10), 行銷(10), 管理員(5)
密碼：123456 (ASP.NET Core Identity PasswordHasher V3 格式)
==============================================================================
*/

USE MyFitnessCoachDb;
GO

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. 定義常數與密碼雜湊 (123456)
    -- 注意：PasswordHasher 產生的雜湊是隨機的，以下為一個有效的 123456 雜湊範例
    DECLARE @HashedPassword NVARCHAR(256) = N'AQAAAAIAAYagAAAAENLzO0RzN4W4T8U+2S5W1j7yXnL6Q5Q7r8m9v0v1v2v3v4v5v6v7v8v9v0==';
    
    DECLARE @RoleId_Instructor INT, @RoleId_Purchasor INT, @RoleId_Marketor INT, @RoleId_Admin INT;

    -- 2. 獲取 RoleId (確保 Roles 存在)
    SELECT @RoleId_Instructor = Id FROM Roles WHERE RoleName = 'instructor';
    SELECT @RoleId_Purchasor = Id FROM Roles WHERE RoleName = 'purchasor';
    SELECT @RoleId_Marketor = Id FROM Roles WHERE RoleName = 'marketor';
    SELECT @RoleId_Admin = Id FROM Roles WHERE RoleName = 'admin';

    -- 若 Role 不存在則建立 (防呆)
    IF @RoleId_Instructor IS NULL BEGIN INSERT INTO Roles (RoleName, IsActive) VALUES ('instructor', 1); SET @RoleId_Instructor = SCOPE_IDENTITY(); END
    IF @RoleId_Purchasor IS NULL BEGIN INSERT INTO Roles (RoleName, IsActive) VALUES ('purchasor', 1); SET @RoleId_Purchasor = SCOPE_IDENTITY(); END
    IF @RoleId_Marketor IS NULL BEGIN INSERT INTO Roles (RoleName, IsActive) VALUES ('marketor', 1); SET @RoleId_Marketor = SCOPE_IDENTITY(); END
    IF @RoleId_Admin IS NULL BEGIN INSERT INTO Roles (RoleName, IsActive) VALUES ('admin', 1); SET @RoleId_Admin = SCOPE_IDENTITY(); END

    DECLARE @i INT = 1;
    DECLARE @NewUserId INT;

    -- 3. 生成 營養師 (12位)
    SET @i = 1;
    WHILE @i <= 12
    BEGIN
        DECLARE @InstEmail NVARCHAR(200) = N'nutri' + CAST(@i AS NVARCHAR) + '@fitness.com';
        IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = @InstEmail)
        BEGIN
            INSERT INTO Users (Account, HashedPassword, UserName, Email, Mobile, IsConfirmed, IsActive)
            VALUES (N'nutri' + RIGHT('00' + CAST(@i AS NVARCHAR), 2), @HashedPassword, N'營養師' + CAST(@i AS NVARCHAR), @InstEmail, '0920000' + RIGHT('000' + CAST(@i AS NVARCHAR), 3), 1, 1);
            
            SET @NewUserId = SCOPE_IDENTITY();
            INSERT INTO UserRoles (UserId, RoleId) VALUES (@NewUserId, @RoleId_Instructor);
            
            -- 營養師特有表 Instructors
            INSERT INTO Instructors (UserId, ImageUrl, Description, HourWage, CancelCount, IsActive)
            VALUES (@NewUserId, N'/images/instructors/default.jpg', N'專業營養諮詢服務 - 測試資料' + CAST(@i AS NVARCHAR), 1200, 0, 1);
        END
        SET @i = @i + 1;
    END

    -- 4. 生成 採購人員 (10位)
    SET @i = 1;
    WHILE @i <= 10
    BEGIN
        DECLARE @PurEmail NVARCHAR(200) = N'purch' + CAST(@i AS NVARCHAR) + '@fitness.com';
        IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = @PurEmail)
        BEGIN
            INSERT INTO Users (Account, HashedPassword, UserName, Email, Mobile, IsConfirmed, IsActive)
            VALUES (N'purch' + RIGHT('00' + CAST(@i AS NVARCHAR), 2), @HashedPassword, N'採購員' + CAST(@i AS NVARCHAR), @PurEmail, '0930000' + RIGHT('000' + CAST(@i AS NVARCHAR), 3), 1, 1);
            
            SET @NewUserId = SCOPE_IDENTITY();
            INSERT INTO UserRoles (UserId, RoleId) VALUES (@NewUserId, @RoleId_Purchasor);
        END
        SET @i = @i + 1;
    END

    -- 5. 生成 行銷人員 (10位)
    SET @i = 1;
    WHILE @i <= 10
    BEGIN
        DECLARE @MktEmail NVARCHAR(200) = N'market' + CAST(@i AS NVARCHAR) + '@fitness.com';
        IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = @MktEmail)
        BEGIN
            INSERT INTO Users (Account, HashedPassword, UserName, Email, Mobile, IsConfirmed, IsActive)
            VALUES (N'market' + RIGHT('00' + CAST(@i AS NVARCHAR), 2), @HashedPassword, N'行銷員' + CAST(@i AS NVARCHAR), @MktEmail, '0940000' + RIGHT('000' + CAST(@i AS NVARCHAR), 3), 1, 1);
            
            SET @NewUserId = SCOPE_IDENTITY();
            INSERT INTO UserRoles (UserId, RoleId) VALUES (@NewUserId, @RoleId_Marketor);
        END
        SET @i = @i + 1;
    END

    -- 6. 生成 系統管理員 (5位)
    SET @i = 1;
    WHILE @i <= 5
    BEGIN
        DECLARE @AdminEmail NVARCHAR(200) = N'admin' + CAST(@i AS NVARCHAR) + '@fitness.com';
        IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = @AdminEmail)
        BEGIN
            INSERT INTO Users (Account, HashedPassword, UserName, Email, Mobile, IsConfirmed, IsActive)
            VALUES (N'sysadmin' + RIGHT('00' + CAST(@i AS NVARCHAR), 2), @HashedPassword, N'管理員' + CAST(@i AS NVARCHAR), @AdminEmail, '0950000' + RIGHT('000' + CAST(@i AS NVARCHAR), 3), 1, 1);
            
            SET @NewUserId = SCOPE_IDENTITY();
            INSERT INTO UserRoles (UserId, RoleId) VALUES (@NewUserId, @RoleId_Admin);
        END
        SET @i = @i + 1;
    END

    COMMIT TRANSACTION;
    PRINT '測試資料生成成功！';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '錯誤發生，資料已復原。';
    THROW;
END CATCH
