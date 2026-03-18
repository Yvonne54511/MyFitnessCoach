using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;

namespace Project_MyFitnessCoach.Models.Infra
{
    /// <summary>
    /// 功能授權 OR 代審授權過濾器。
    /// 條件一：Cookie Claims 中有指定 Function → 放行
    /// 條件二：DB LeaveApprovalDelegations 有效記錄 → 放行
    /// 兩者皆不符合 → 403
    /// </summary>
    public class FunctionOrDelegationAttribute : AuthorizeAttribute, IAsyncAuthorizationFilter
    {
        public string FunctionName { get; }

        public FunctionOrDelegationAttribute(string functionName)
        {
            FunctionName = functionName;
        }

        public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
        {
            if (context.HttpContext.User.Identity?.IsAuthenticated != true)
                return;

            // 條件一：Cookie Claims 中有指定的 Function → 放行
            var userFunctions = context.HttpContext.User.FindAll("Function")
                                     .Select(c => c.Value);
            if (userFunctions.Contains(FunctionName))
                return;

            // 條件二：DB 查詢 LeaveApprovalDelegations → 放行
            var employeeIdStr = context.HttpContext.User.FindFirst("EmployeeId")?.Value;
            if (int.TryParse(employeeIdStr, out var employeeId))
            {
                var db = context.HttpContext.RequestServices
                    .GetRequiredService<MyFitnessCoachDbContext>();
                var now = DateTime.Now;
                var hasActiveDelegation = await db.LeaveApprovalDelegations
                    .AnyAsync(d => d.DelegateEmployeeId == employeeId
                        && d.IsActive
                        && d.StartDate <= now
                        && d.EndDate >= now);
                if (hasActiveDelegation)
                    return;
            }

            // 兩個條件都不符合 → 403
            context.Result = new ForbidResult();
        }
    }
}
