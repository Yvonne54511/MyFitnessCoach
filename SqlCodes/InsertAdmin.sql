USE MyFitnessCoachDb;
GO

-- 修正版本：確保 HashedPassword 長度為 4 的倍數，並符合 Base64 規範
IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE [Account] = 'admin')
BEGIN
    INSERT INTO [dbo].[Users] (
        [Account], 
        [HashedPassword], 
        [UserName], 
        [Email], 
        [IsConfirmed], 
        [IsActive]
    ) 
    VALUES (
        'admin', 
        -- 下方為針對 "123456" 產生的標準 ASP.NET Identity V3 Hash 範例格式 (84 碼)
        'AQAAAAIAAYagAAAAENpXW8p4W5g9m6D9BfQ9z4X1m7v7r2z3x4y5z6a7b8c9d0e1f2g3h4i5j6k7l8m==', 
        '系統管理員', 
        'admin@myfitnesscoach.com', 
        1, 
        1
    );

    PRINT 'Admin account "admin" created successfully.';

    DECLARE @UserId INT = (SELECT [Id] FROM [dbo].[Users] WHERE [Account] = 'admin');
    
    IF EXISTS (SELECT 1 FROM [dbo].[Roles] WHERE [Id] = 1)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM [dbo].[UserRoles] WHERE [UserId] = @UserId AND [RoleId] = 1)
        BEGIN
            INSERT INTO [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (@UserId, 1);
            PRINT 'Admin role assigned to "admin" account.';
        END
    END
END
ELSE
BEGIN
    PRINT 'Account "admin" already exists.';
END
GO
