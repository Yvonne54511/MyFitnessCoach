/*
==============================================================================
資深工程師測試資料生成腳本 - 大量會員版
目標：生成 100 位正式會員
包含表：Users, UserRoles, Members, UserWallets
密碼：123456 (ASP.NET Core Identity V3 格式)
==============================================================================
*/

USE MyFitnessCoachDb;
GO

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. 定義常數與密碼雜湊 (123456 - 真實 V3 雜湊)
    DECLARE @HashedPassword NVARCHAR(256) = N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==';
    DECLARE @ConfirmCode NVARCHAR(100) = N'd516b394-c7dc-4d99-b17f-277bfa2627db';
    DECLARE @Expiry DATETIME2 = '2026-03-08 09:49:59';
    
    DECLARE @RoleId_Member INT;
    SELECT @RoleId_Member = Id FROM Roles WHERE RoleName = 'member';

    -- 若 Role 不存在則建立 (防呆)
    IF @RoleId_Member IS NULL 
    BEGIN 
        INSERT INTO Roles (RoleName, [Description], IsActive) VALUES ('member', N'正式會員', 1); 
        SET @RoleId_Member = SCOPE_IDENTITY(); 
    END

    DECLARE @i INT = 1;
    DECLARE @NewUserId INT;
    DECLARE @NewMemberId INT;
    DECLARE @Surname NVARCHAR(10);
    DECLARE @RandomGender TINYINT;

    -- 2. 迴圈生成 100 位會員
    WHILE @i <= 100
    BEGIN
        -- 根據序號決定姓氏 (Demo 看起來比較專業)
        SET @Surname = CASE (@i % 10)
            WHEN 0 THEN N'王' WHEN 1 THEN N'李' WHEN 2 THEN N'張' WHEN 3 THEN N'劉' WHEN 4 THEN N'陳'
            WHEN 5 THEN N'楊' WHEN 6 THEN N'黃' WHEN 7 THEN N'趙' WHEN 8 THEN N'周' WHEN 9 THEN N'吳'
            END;

        DECLARE @Account NVARCHAR(50) = N'member' + RIGHT('000' + CAST(@i AS NVARCHAR), 3);
        DECLARE @Email NVARCHAR(200) = @Account + '@fitness.com';
        DECLARE @UserName NVARCHAR(30) = @Surname + N'小明' + CAST(@i AS NVARCHAR);
        DECLARE @Mobile VARCHAR(10) = '096' + RIGHT('0000000' + CAST(@i AS NVARCHAR), 7);

        -- 檢查是否已存在 (冪等性)
        IF NOT EXISTS (SELECT 1 FROM Users WHERE Account = @Account OR Email = @Email)
        BEGIN
            -- 寫入 Users 表
            INSERT INTO Users (
                Account, HashedPassword, UserName, Email, Mobile, 
                IsConfirmed, IsActive, 
                NewMemberConfirmCode, NewMemberConfirmCodeExpiry
            )
            VALUES (
                @Account, @HashedPassword, @UserName, @Email, @Mobile, 
                1, 1, 
                @ConfirmCode, @Expiry
            );
            
            SET @NewUserId = SCOPE_IDENTITY();

            -- 寫入 UserRoles (權限關聯)
            INSERT INTO UserRoles (UserId, RoleId) VALUES (@NewUserId, @RoleId_Member);
            
            -- 決定隨機性別 (0-3)
            SET @RandomGender = CAST(ABS(CHECKSUM(NEWID())) % 2 + 1 AS TINYINT); -- 隨機產生 1(男) 或 2(女)

            -- 寫入 Members (詳細資料表)
            INSERT INTO Members (
                UserId, Gender, DateOfBirth, Weight, Height, 
                ActivityLevel, Target, BMR, TDEE, ImageUrl, CancelCount
            )
            VALUES (
                @NewUserId, 
                @RandomGender, 
                DATEADD(DAY, - (ABS(CHECKSUM(NEWID())) % 10000 + 7000), GETDATE()), -- 隨機生日 (約 20-45 歲)
                60 + (ABS(CHECKSUM(NEWID())) % 30), -- 隨機體重 60-90
                160 + (ABS(CHECKSUM(NEWID())) % 25), -- 隨機身高 160-185
                N'中度活動', 
                N'維持體重', 
                1500, 2200, 
                N'/images/members/default.jpg', 
                0
            );

            SET @NewMemberId = SCOPE_IDENTITY();

            -- 寫入 UserWallets (錢包初始化)
            INSERT INTO UserWallets (MemberId, CurrentBalance, LastUpdated)
            VALUES (@NewMemberId, 1000.00, GETDATE()); -- 初始贈送 1000 點
        END

        SET @i = @i + 1;
    END

    COMMIT TRANSACTION;
    PRINT '成功生成 100 筆專業會員測試資料！';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '錯誤發生，資料已回滾。';
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT @ErrorMessage;
END CATCH
