/*
==============================================================================
資深工程師專業化測試資料更新腳本
目標：將自動生成的帳號（nutri, purch, market, sysadmin）更新為真實姓名與電話
適用對象：已執行的測試資料，需提升 Demo 專業度
==============================================================================
*/

USE MyFitnessCoachDb;
GO

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. 更新 營養師 (12位)
    UPDATE Users SET 
        UserName = CASE Account
            WHEN 'nutri01' THEN N'林思敏' WHEN 'nutri02' THEN N'陳大為' WHEN 'nutri03' THEN N'張嘉玲'
            WHEN 'nutri04' THEN N'王志宏' WHEN 'nutri05' THEN N'李美惠' WHEN 'nutri06' THEN N'趙育誠'
            WHEN 'nutri07' THEN N'郭芷瑄' WHEN 'nutri08' THEN N'何明翰' WHEN 'nutri09' THEN N'謝淑芬'
            WHEN 'nutri10' THEN N'蕭建平' WHEN 'nutri11' THEN N'曾雅雯' WHEN 'nutri12' THEN N'潘俊傑'
            ELSE UserName END,
        Mobile = CASE Account
            WHEN 'nutri01' THEN '0912384756' WHEN 'nutri02' THEN '0921475869' WHEN 'nutri03' THEN '0933582417'
            WHEN 'nutri04' THEN '0975614238' WHEN 'nutri05' THEN '0988231457' WHEN 'nutri06' THEN '0919456782'
            WHEN 'nutri07' THEN '0928374651' WHEN 'nutri08' THEN '0932145698' WHEN 'nutri09' THEN '0955874123'
            WHEN 'nutri10' THEN '0910234567' WHEN 'nutri11' THEN '0963214587' WHEN 'nutri12' THEN '0972581436'
            ELSE Mobile END
    WHERE Account LIKE 'nutri%';

    -- 2. 更新 採購人員 (10位)
    UPDATE Users SET 
        UserName = CASE Account
            WHEN 'purch01' THEN N'周杰倫' WHEN 'purch02' THEN N'蔡依林' WHEN 'purch03' THEN N'林俊傑'
            WHEN 'purch04' THEN N'田馥甄' WHEN 'purch05' THEN N'蕭敬騰' WHEN 'purch06' THEN N'楊丞琳'
            WHEN 'purch07' THEN N'潘瑋柏' WHEN 'purch08' THEN N'張惠妹' WHEN 'purch09' THEN N'羅志祥'
            WHEN 'purch10' THEN N'梁靜茹'
            ELSE UserName END,
        Mobile = CASE Account
            WHEN 'purch01' THEN '0937123456' WHEN 'purch02' THEN '0911223344' WHEN 'purch03' THEN '0922334455'
            WHEN 'purch04' THEN '0955667788' WHEN 'purch05' THEN '0966778899' WHEN 'purch06' THEN '0977889900'
            WHEN 'purch07' THEN '0988990011' WHEN 'purch08' THEN '0900112233' WHEN 'purch09' THEN '0911558899'
            WHEN 'purch10' THEN '0922446688'
            ELSE Mobile END
    WHERE Account LIKE 'purch%';

    -- 3. 更新 行銷人員 (10位)
    UPDATE Users SET 
        UserName = CASE Account
            WHEN 'market01' THEN N'劉德華' WHEN 'market02' THEN N'張學友' WHEN 'market03' THEN N'郭富城'
            WHEN 'market04' THEN N'黎明'   WHEN 'market05' THEN N'王菲'   WHEN 'market06' THEN N'鄭秀文'
            WHEN 'market07' THEN N'陳奕迅' WHEN 'market08' THEN N'容祖兒' WHEN 'market09' THEN N'古巨基'
            WHEN 'market10' THEN N'謝霆鋒'
            ELSE UserName END,
        Mobile = CASE Account
            WHEN 'market01' THEN '0910001111' WHEN 'market02' THEN '0920002222' WHEN 'market03' THEN '0930003333'
            WHEN 'market04' THEN '0940004444' WHEN 'market05' THEN '0950005555' WHEN 'market06' THEN '0960006666'
            WHEN 'market07' THEN '0970007777' WHEN 'market08' THEN '0980008888' WHEN 'market09' THEN '0990009999'
            WHEN 'market10' THEN '0900000000'
            ELSE Mobile END
    WHERE Account LIKE 'market%';

    -- 4. 更新 系統管理員 (5位)
    UPDATE Users SET 
        UserName = CASE Account
            WHEN 'sysadmin01' THEN N'管理者一號' WHEN 'sysadmin02' THEN N'技術總監' WHEN 'sysadmin03' THEN N'維運經理'
            WHEN 'sysadmin04' THEN N'資安主管'   WHEN 'sysadmin05' THEN N'系統架構師'
            ELSE UserName END,
        Mobile = CASE Account
            WHEN 'sysadmin01' THEN '0912121212' WHEN 'sysadmin02' THEN '0923232323' WHEN 'sysadmin03' THEN '0934343434'
            WHEN 'sysadmin04' THEN '0945454545' WHEN 'sysadmin05' THEN '0956565656'
            ELSE Mobile END
    WHERE Account LIKE 'sysadmin%';

    COMMIT TRANSACTION;
    PRINT '所有測試帳號姓名與電話已更新為專業格式！';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '更新過程中發生錯誤，資料已回滾。';
    THROW;
END CATCH
