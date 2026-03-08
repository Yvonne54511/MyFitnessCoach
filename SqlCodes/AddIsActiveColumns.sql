USE MyFitnessCoachDb;
GO

-- 1. Add columns
IF COL_LENGTH('dbo.Users', 'IsActive') IS NULL
BEGIN
    ALTER TABLE dbo.Users
    ADD IsActive BIT NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT (0);
END;
GO

IF COL_LENGTH('dbo.Roles', 'IsActive') IS NULL
BEGIN
    ALTER TABLE dbo.Roles
    ADD IsActive BIT NOT NULL CONSTRAINT DF_Roles_IsActive DEFAULT (0);
END;
GO

IF COL_LENGTH('dbo.Functions', 'IsActive') IS NULL
BEGIN
    ALTER TABLE dbo.[Functions]
    ADD IsActive BIT NOT NULL CONSTRAINT DF_Functions_IsActive DEFAULT (0);
END;
GO

-- 2. Update values
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
