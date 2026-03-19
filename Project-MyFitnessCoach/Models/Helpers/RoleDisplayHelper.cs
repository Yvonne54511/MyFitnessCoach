namespace Project_MyFitnessCoach.Models.Helpers
{
    /// <summary>
    /// 角色名稱中英對照
    /// </summary>
    public static class RoleDisplayHelper
    {
        private static readonly Dictionary<string, string> _roleMapping = new(StringComparer.OrdinalIgnoreCase)
        {
			{ "Role_forDemo", "Demo用角色" },
			{ "visitor", "訪客" },
			{ "member", "會員" },
            { "instructor", "營養師" },
            { "purchasor", "採購人員" },
            { "marketor", "行銷人員" },
            { "admin", "系統管理員" },
            { "manager", "主管" }
        };

        /// <summary>
        /// 將英文角色名稱轉換為中文顯示名稱，找不到則回傳原始值
        /// </summary>
        public static string ToDisplayName(string roleName)
        {
            if (string.IsNullOrEmpty(roleName))
                return roleName;

            return _roleMapping.TryGetValue(roleName, out var displayName) ? displayName : roleName;
        }

        /// <summary>
        /// 將多個英文角色名稱轉換為中文，以逗號分隔
        /// </summary>
        public static string ToDisplayNames(IEnumerable<string> roleNames, string separator = ", ")
        {
            return string.Join(separator, roleNames.Select(ToDisplayName));
        }
    }
}
