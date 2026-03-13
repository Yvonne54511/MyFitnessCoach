IF OBJECT_ID(N'[dbo].[vw_UserRoleFunctions]', 'V') IS NOT NULL
    DROP VIEW [dbo].[vw_UserRoleFunctions];
GO

CREATE VIEW [dbo].[vw_UserRoleFunctions] AS
SELECT 
    u.UserName,
    u.Account,
    r.RoleName,
    f.FunctionName
FROM 
    [dbo].[Users] u
JOIN 
    [dbo].[UserRoles] ur ON u.Id = ur.UserId
JOIN 
    [dbo].[Roles] r ON ur.RoleId = r.Id
JOIN 
    [dbo].[RoleFunctions] rf ON r.Id = rf.RoleId
JOIN 
    [dbo].[Functions] f ON rf.FunctionId = f.Id;
GO
