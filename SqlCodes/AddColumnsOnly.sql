SET QUOTED_IDENTIFIER ON;
GO
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
