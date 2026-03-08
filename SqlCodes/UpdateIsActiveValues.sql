SET QUOTED_IDENTIFIER ON;
GO
USE MyFitnessCoachDb;
GO

UPDATE dbo.Users
SET IsActive = CASE WHEN IsConfirmed = 1 THEN 1 ELSE 0 END;
GO

UPDATE dbo.Roles
SET IsActive = 1;
GO

UPDATE dbo.[Functions]
SET IsActive = 1;
GO

-- 3. Show results
SELECT 'Users' AS TableName, COUNT(*) AS TotalRows, SUM(CAST(IsActive AS INT)) AS ActiveRows
FROM dbo.Users
UNION ALL
SELECT 'Roles', COUNT(*), SUM(CAST(IsActive AS INT))
FROM dbo.Roles
UNION ALL
SELECT 'Functions', COUNT(*), SUM(CAST(IsActive AS INT))
FROM dbo.[Functions];
GO
