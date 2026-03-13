using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System.Security.Claims;

namespace Project_MyFitnessCoach.Models.Infra
{
    /// <summary>
    /// 自定義功能授權過濾器
    /// </summary>
    public class FunctionAttribute : AuthorizeAttribute, IAsyncAuthorizationFilter
    {
        public string FunctionName { get; }

        public FunctionAttribute(string functionName)
        {
            FunctionName = functionName;
        }

        public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
        {
            // 1. 檢查是否已登入 (由 [Authorize] 先處理，這裡作為保險)
            if (context.HttpContext.User.Identity?.IsAuthenticated != true)
            {
                // 如果未登入且沒有 AllowAnonymous，由 [Authorize] 導向 LoginPath
                return;
            }

            // 2. 檢查使用者是否有該 Function 的 Claim
            var userFunctions = context.HttpContext.User.FindAll("Function")
                                     .Select(c => c.Value);

            if (!userFunctions.Contains(FunctionName))
            {
                // 如果沒有權限，導向 AccessDeniedPath (即 /Home/Error/403)
                context.Result = new ForbidResult();
            }
        }
    }
}
