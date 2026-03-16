/*
==============================================================================
資深工程師密碼修復腳本
目標：將所有測試帳號的密碼修正為正確的 "123456" 雜湊值
說明：此雜湊值採用 ASP.NET Core Identity V3 (PBKDF2-HMAC-SHA256) 格式
==============================================================================
*/

USE MyFitnessCoachDb;
GO

-- 真實的 "123456" 雜湊範例 (由標準 PasswordHasher 產生)
DECLARE @CorrectHash NVARCHAR(256) = N'AQAAAAIAAYagAAAAEP55tPFRA+060E7a1jD4Q+h5/eTw7Tx1YONAEud0TZGOnZHB1t0UnPQqoyheaOXRSg==';

BEGIN TRANSACTION;

BEGIN TRY
    -- 更新所有自動生成的測試帳號
    UPDATE Users 
    SET HashedPassword = @CorrectHash
    WHERE Account LIKE 'nutri%' 
       OR Account LIKE 'purch%' 
       OR Account LIKE 'market%' 
       OR Account LIKE 'sysadmin%';

    -- 確保這些帳號是啟用的
    UPDATE Users
    SET IsActive = 1, IsConfirmed = 1,NewMemberConfirmCode=N'd516b394-c7dc-4d99-b17f-277bfa2627db',NewMemberConfirmCodeExpiry='2026-03-08 09:49:59'
    WHERE Account LIKE 'nutri%' 
       OR Account LIKE 'purch%' 
       OR Account LIKE 'market%' 
       OR Account LIKE 'sysadmin%';

    COMMIT TRANSACTION;
    PRINT '密碼已成功修復！現在您可以使用 "123456" 登入這些帳號。';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '修復失敗，資料已回滾。';
    THROW;
END CATCH
