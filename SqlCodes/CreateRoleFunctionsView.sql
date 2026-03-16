IF OBJECT_ID(N'[dbo].[vw_RoleFunctions]', 'V') IS NOT NULL
    DROP VIEW [dbo].[vw_RoleFunctions];
GO

CREATE VIEW [dbo].[vw_RoleFunctions] AS
SELECT 
    r.RoleName,
    f.FunctionName
FROM 
    [dbo].[Roles] r
JOIN 
    [dbo].[RoleFunctions] rf ON r.Id = rf.RoleId
JOIN 
    [dbo].[Functions] f ON rf.FunctionId = f.Id;
GO
