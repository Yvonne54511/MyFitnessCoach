/*
==============================================================================
資深工程師：150 名會員帳號(Account)真實化更新腳本
目標：將 member001-member150 的帳號格式改為「羅馬拼音+數字」
邏輯：按 Id 順序排序，前 50 筆自動補齊，51-150 筆使用指定清單
==============================================================================
*/

USE MyFitnessCoachDb;
GO

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. 建立帳號臨時表
    CREATE TABLE #TempAccounts (
        RowID INT IDENTITY(1,1),
        NewAccount NVARCHAR(50)
    );

    -- 2. 插入前 50 筆 (根據姓名補齊)
    INSERT INTO #TempAccounts (NewAccount) VALUES 
    ('liulinjin01'), ('chenhanmu02'), ('linlannan03'), ('chenshuan04'), ('huqingqing05'), 
    ('lishilin06'), ('wulangyan07'), ('gaozhuohang08'), ('luomuchen09'), ('xuyaoze10'), 
    ('zhouchenhan11'), ('huqingwei12'), ('liweiyin13'), ('luoqinglin14'), ('zhouanrou15'), 
    ('zhuchenyuan16'), ('linningran17'), ('liyaoqing18'), ('herouran19'), ('liuweiyin20'), 
    ('lizeqing21'), ('linranlan22'), ('maruoyun23'), ('lilangyao24'), ('gaojingwei25'), 
    ('gaoqingxing26'), ('wangyinning27'), ('zhaochenting28'), ('gaoshining29'), ('maruoyao30'), 
    ('zhanglinjin31'), ('wuqingyang32'), ('heyaze33'), ('liuchenrou34'), ('huangyanghang35'), 
    ('zhaoyuqing36'), ('chenrouchen37'), ('yangyangyuan38'), ('huanghanya39'), ('sunnanqing40'), 
    ('zhanglangwei41'), ('zhaoweimu42'), ('sunanwei43'), ('liushumu44'), ('linchenshu45'), 
    ('lilinnan46'), ('huangyanning47'), ('zhouranhang48'), ('liuyangrou49'), ('gaochenze50');

    -- 3. 插入 51-150 筆 (使用您提供的清單)
    INSERT INTO #TempAccounts (NewAccount) VALUES 
    ('linxuanyu51'), ('liuyuanlang52'), ('huangyunyang53'), ('guohanqing54'), ('sunyanshi55'), 
    ('chenlinwei56'), ('luoxinghao57'), ('xuyangan58'), ('xuweizhuo59'), ('huangqingjin60'), 
    ('liuhaoya61'), ('guoxinglang62'), ('sunlanran63'), ('mayarou64'), ('chenshuxuan65'), 
    ('huqinghan66'), ('wuxuanwei67'), ('guomuan68'), ('zhangchenyao69'), ('heyunshu70'), 
    ('luoweiwei71'), ('zhuyinyuan72'), ('zhaohaoshi73'), ('maqingrou74'), ('liuyaoze75'), 
    ('liuanhang76'), ('zhangzhuoqing77'), ('guolinwei78'), ('zhangmulan79'), ('zhujinting80'), 
    ('maboze81'), ('zhoumuqing82'), ('zhaojingze83'), ('zhangmuning84'), ('zhaotingjing85'), 
    ('mananzhuo86'), ('guozhuolang87'), ('yangzechen88'), ('wuxinghao89'), ('luozehan90'), 
    ('sunhanyin91'), ('luoqingning92'), ('wulangchuan93'), ('liyalin94'), ('huyanting95'), 
    ('zhangchenya96'), ('chenyuchen97'), ('zhanganyang98'), ('xuchenyun99'), ('zhurouqing100'), 
    ('gaomuyan101'), ('zhangxuanting102'), ('yangnanhang103'), ('luoyaoyan104'), ('majingyin105'), 
    ('xubaihao106'), ('zhuoruolang107'), ('yangyuyang108'), ('zhaoyaoqing109'), ('heweihao110'), 
    ('zhouhangyu111'), ('wuweiyang112'), ('wulinyao113'), ('zhouyunya114'), ('zhouyanyang115'), 
    ('sunbaihao116'), ('sunruozhuo117'), ('sunmumu118'), ('zhoulinyan119'), ('linzeting120'), 
    ('hejinze121'), ('wunanlin122'), ('wuyanhan123'), ('luoweiyan124'), ('heweihao125'), 
    ('zhoutingzhuo126'), ('wuranze127'), ('lizemu128'), ('linyinting129'), ('heyuruo130'), 
    ('gaoanqing131'), ('zhaolangyao132'), ('wangjinjin133'), ('gaoyunan134'), ('malangyan135'), 
    ('gaoqingan136'), ('liulinran137'), ('huningya138'), ('zhouhangjing139'), ('huqingyang140'), 
    ('huyanshi141'), ('zhuhaolin142'), ('xumuyang143'), ('wuhanghang144'), ('wuyuxing145'), 
    ('huangshijing146'), ('heyanyun147'), ('gaoyangbai148'), ('zhuqinghan149'), ('zhangxingnan150');

    -- 4. 使用 CTE 更新 Users 表的前 150 筆 Account
    WITH UserList AS (
        SELECT Id, Account, ROW_NUMBER() OVER (ORDER BY Id) as RowNum
        FROM Users
    )
    UPDATE u
    SET u.Account = t.NewAccount
    FROM UserList u
    JOIN #TempAccounts t ON u.RowNum = t.RowID;

    -- 5. 清理
    DROP TABLE #TempAccounts;

    COMMIT TRANSACTION;
    PRINT '成功將 150 位使用者的帳號更新為羅馬拼音格式！';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    IF OBJECT_ID('tempdb..#TempAccounts') IS NOT NULL DROP TABLE #TempAccounts;
    PRINT '更新失敗，資料已復原。';
    THROW;
END CATCH
