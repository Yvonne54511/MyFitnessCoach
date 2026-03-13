# MyFitnessCoach 後台權限管理系統設計說明 (RBAC)

作為資深系統設計師，本文件旨在定義 MyFitnessCoach 後台的權限管理實作流程。我們將採用 **RBAC (Role-Based Access Control)** 模型，結合 ASP.NET Core 的 **Cookie Authentication** 與 **Claims-based Authorization**。

## 一、 資料庫模型基礎 (Database Schema)
權限系統的核心在於「誰 (Who)」、「可以做什麼 (What)」、「在哪裡做 (Where)」。
1. **Members / Admins (使用者)**：儲存帳號密碼。
2. **Roles (角色)**：如：超級管理員、一般員工、教練主管等。
3. **Functions / Permissions (功能/權限)**：定義系統中的各個操作點（如：`Product_Create`, `Order_Refund`, `Member_Delete`）。
4. **RoleFunctions (角色權限對照)**：定義哪些角色擁有哪些功能權限。
5. **MemberRoles (使用者角色對照)**：定義使用者所屬的角色。

## 二、 認證與授權流程 (Authentication & Authorization Steps)

### 步驟 1：登入與 Claims 封裝
當使用者通過 `LoginController` 驗證時：
- 從 `AccountRepository` 取得該使用者的角色。
- 從 `RoleFunctionRepository` 取得該角色對應的所有權限代碼（FunctionCode）。
- 將這些資訊封裝進 `List<Claim>`，例如：
    - `new Claim(ClaimTypes.Role, roleName)`
    - `new Claim("Permission", functionCode)` (多筆)
- 使用 `HttpContext.SignInAsync` 寫入加密 Cookie。

### 步驟 2：自定義授權過濾器 (Authorization Filter)
建立一個 `PermissionAttribute` (承襲 `AuthorizeAttribute` 或實作 `IAuthorizationFilter`)：
- 在 Controller 的 Action 上標註：`[Permission("Product_Edit")]`。
- 過濾器會攔截請求，檢查當前 `User.Claims` 中是否包含 "Product_Edit"。
- 若無權限，導向「權限不足」頁面 (403 Forbidden)。

### 步驟 3：中介軟體與原則 (Policy-based Authorization)
在 `Program.cs` 中註冊授權原則：
- 雖然 Claims 很方便，但透過 `AuthorizationPolicy` 可以更優雅地處理複雜的邏輯判斷。

## 三、 前端選單控管 (UI/UX Control)
權限不只是後端的攔截，前端也需要良好的使用者體驗：
- **Partial View (側邊選單)**：在 `_Layout.cshtml` 或選單組件中，判斷 `User.HasClaim("Permission", "Menu_Product")` 來決定是否渲染該選單。
- **按鈕控制**：針對敏感操作（如刪除），在 View 中使用 `@if (User.HasClaim(...))` 進行條件式渲染。

## 四、 管理模組 (Admin Modules)
系統必須包含以下管理功能，以利後續維護：
1. **角色管理**：新增/刪除角色，並勾選該角色擁有的功能清單。
2. **帳號管理**：分配使用者到特定角色。
3. **功能清單同步**：開發者新增 Controller/Action 後，需同步更新資料庫中的 `Functions` 表。

## 五、 安全性考量 (Security Best Practices)
1. **Cookie 安全性**：開啟 `HttpOnly`, `SecurePolicy = Always`, `SameSite = Lax`。
2. **防暴力破解**：登入失敗次數限制。
3. **操作稽核 (Audit Logs)**：在 `BaseController` 或過濾器中記錄誰在什麼時候執行了什麼敏感操作。

## 六、 步驟 1 ~ 5 的實作程式碼範例

### 步驟 1：登入與 Claims 封裝 (LoginController / AuthService)
在驗證使用者成功後，將權限資訊塞入 Identity：
```csharp
public async Task<ClaimsPrincipal> CreatePrincipal(Member user)
{
    // 1. 取得使用者的角色與權限 (從 Repository 撈取)
    var roles = await _roleRepo.GetByMemberId(user.Id);
    var permissions = await _roleFunctionRepo.GetPermissionsByRoleId(roles.Id);

    var claims = new List<Claim>
    {
        new Claim(ClaimTypes.Name, user.Account),
        new Claim("UserId", user.Id.ToString()),
        new Claim(ClaimTypes.Role, roles.RoleName)
    };

    // 2. 將所有權限代碼加入 Claims (例如: "Product_Edit", "Order_View")
    foreach (var p in permissions)
    {
        claims.Add(new Claim("Permission", p.FunctionCode));
    }

    var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
    return new ClaimsPrincipal(identity);
}
```

### 步驟 2：自定義授權過濾器 (PermissionAttribute)
建立一個可重複使用的過濾器，檢查 Claims 中的權限：
```csharp
public class PermissionAttribute : AuthorizeAttribute, IAuthorizationFilter
{
    private readonly string _permission;
    public PermissionAttribute(string permission) => _permission = permission;

    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var user = context.HttpContext.User;
        if (!user.Identity.IsAuthenticated) return; // 讓基底的 Authorize 處理 401

        // 檢查是否有對應的 Permission Claim
        var hasPermission = user.Claims.Any(c => c.Type == "Permission" && c.Value == _permission);
        
        if (!hasPermission)
        {
            // 若無權限，導向 403 Forbidden 或自定義錯誤頁面
            context.Result = new ForbidResult(); 
        }
    }
}

// 使用方式:
// [Permission("Product_Delete")]
// public IActionResult Delete(int id) { ... }
```

### 步驟 3：中介軟體配置 (Program.cs)
設定 Cookie 驗證的基本參數：
```csharp
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/Login";
        options.AccessDeniedPath = "/Account/AccessDenied"; // 無權限時導向的頁面
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    });
```

### 步驟 4：前端 UI 選單控管 (_Layout.cshtml)
在 Razor 視圖中根據 Claims 動態顯示功能：
```html
@if (User.HasClaim("Permission", "Menu_ProductManagement"))
{
    <li class="nav-item">
        <a class="nav-link" asp-controller="Products" asp-action="Index">商品管理</a>
    </li>
}

@if (User.HasClaim("Permission", "Btn_ProductDelete"))
{
    <button class="btn btn-danger">刪除商品</button>
}
```

### 步驟 5：安全性擴充 (BaseController)
建立一個基礎控制器，讓所有後台頁面繼承，強制要求登入：
```csharp
[Authorize] // 全域強制登入
public class AdminBaseController : Controller
{
    // 可以在這裡定義通用的 UserContext 屬性
    public int CurrentUserId => int.Parse(User.FindFirst("UserId")?.Value ?? "0");
}
```

## 七、 重點觀念分析：[Authorize] vs [Permission]

在實作權限管理時，理解這兩個 Attribute 的差異至關重要。

### 1. 定義上的差異
*   **[Authorize] (內建)**：屬於 ASP.NET Core 框架原生的身份認證。它主要確認「你是誰 (Authentication)」以及「你是否登入了」。雖然它支持 `Roles` 參數，但這通常是硬編碼在程式碼中的。
*   **[Permission] (自定義)**：這是我們基於 RBAC 架構自行實作的擴充。它確認「你能做什麼 (Authorization)」，並直接與資料庫中的 `Functions` 表對應。

### 2. 比喻說明：大樓門禁 vs 辦公室鑰匙
| 特性 | [Authorize] (大樓門禁卡) | [Permission] (辦公室鑰匙) |
| :--- | :--- | :--- |
| **主要目的** | 身分識別 (你是員工嗎？) | 權限控管 (你能操作這個按鈕嗎？) |
| **顆粒度** | 粗粒度 (Coarse-grained) | 細粒度 (Fine-grained) |
| **範例** | `[Authorize]` | `[Permission("Product_Delete")]` |
| **靈活性** | 低 (修改角色需重新編譯程式碼) | 高 (修改資料庫即可即時生效) |

### 3. 為什麼我們需要 [Permission]？
如果只使用 `[Authorize(Roles = "Admin")]`，當系統需求變動（例如要把「刪除商品」權限開放給「店長」角色）時，開發者必須手動修改每一支 Controller 的程式碼。

使用 `[Permission]` 後，程式碼只會檢查是否有「`Product_Delete`」這把鑰匙。至於誰擁有這把鑰匙，**完全由資料庫後台動態決定**，這就是系統架構中所謂的「解耦合 (Decoupling)」。

## 八、 Functions 資料表中 api_path 欄位的用途與防護實作

在 `Functions` 資料表中設計 `api_path` (或稱為 `UrlPath`) 是高階權限管理的特徵，它能實現「配置化管理」。

### 1. api_path 的核心用途
*   **動態路由映射**：將「權限代碼 (FunctionCode)」與「實際實體路徑 (Request Path)」掛鉤。
*   **動態選單生成**：後台側邊欄的連結不再硬編碼 (Hard-coded)，而是從資料庫讀取 `api_path` 生成連結。
*   **自動化權限查核**：系統可以自動比對當前 URL 是否在使用者擁有的合法路徑清單中，減少手動標註 `[Permission]` 的工作量。

### 2. 如何阻擋「直接輸入網址」的非法存取？
即便使用者知道 API 路徑，只要在伺服器端實作 **全域路徑攔截器 (Global Route Filter)**，就能有效阻擋。

#### 實作範例 (DynamicRouteFilter.cs)
```csharp
public class DynamicRouteFilter : IAsyncActionFilter
{
    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        var user = context.HttpContext.User;
        if (!user.Identity.IsAuthenticated) { await next(); return; }

        // 1. 取得當前請求的路徑 (例如: /Products/Edit/5)
        var currentPath = context.HttpContext.Request.Path.Value?.ToLower();

        // 2. 從 Claims 中取得使用者擁有的合法 api_path 清單
        // (建議在登入時將該使用者所有合法的 api_path 塞入 Claims)
        var allowedPaths = user.Claims
            .Where(c => c.Type == "AllowedPath")
            .Select(c => c.Value.ToLower())
            .ToList();

        // 3. 進行路徑比對 (支援前綴匹配，以處理 /Edit/5 這種帶 ID 的路徑)
        bool isAuthorized = allowedPaths.Any(path => 
            currentPath == path || 
            currentPath.StartsWith(path + "/")
        );

        if (!isAuthorized)
        {
            // 若不在允許清單內，直接回傳 403 Forbidden
            context.Result = new ForbidResult();
            return;
        }

        await next();
    }
}
```

## 九、 動態選單設計：整合 asp-controller 與 asp-action

雖然目前 `_Layout` 使用 `asp-controller` 和 `asp-action` 進行硬編碼，但為了達到真正的「配置化管理」，建議將選單改為由資料庫驅動。

### 1. 資料表欄位擴充
在 `Functions` 表中增加以下欄位：
*   `ControllerName`: 對應 ASP.NET Core 的 Controller 名稱。
*   `ActionName`: 對應 Action 名稱。
*   `IsMenu`: 布林值，標記此權限是否要顯示在側邊選單中。
*   `SortOrder`: 排序編號，決定選單的前後順序。

### 2. 實作思維：從靜態到動態
*   **現狀 (靜態)**：在 `_Layout.cshtml` 手寫 `<li><a asp-controller="Products" ...></a></li>`。優點是路由變更會自動反應，但增減選單仍須修改程式碼。
*   **目標 (動態)**：將選單邏輯封裝進 `ViewComponent`，在後台迴圈渲染。

### 3. 動態渲染範例 (SidebarViewComponent)
```html
<!-- 在 DynamicSidebar 的 View 中 -->
<ul class="navbar-nav">
    @foreach (var menu in Model)
    {
        <li class="nav-item">
            <a class="nav-link" 
               asp-controller="@menu.ControllerName" 
               asp-action="@menu.ActionName">
                <span>@menu.FunctionName</span>
            </a>
        </li>
    }
</ul>
```

## 十、 ViewComponent 權限過濾實作

為了確保側邊欄 (Sidebar) 只顯示使用者擁有權限的功能，我們建議在 `ViewComponent` 的後端程式碼中直接進行過濾，而非在前端 HTML 處理。

### 1. ViewComponent 後端邏輯 (DynamicSidebarViewComponent.cs)
在組件被呼叫時，利用當前的 `User.Claims` 進行篩選：

```csharp
public async Task<IViewComponentResult> InvokeAsync()
{
    // 從資料庫取得所有標記為選單的功能清單
    var allMenuItems = await _functionRepo.GetMenuItemsAsync();

    // 取得當前使用者擁有的權限代碼清單
    var permissions = UserClaimsPrincipal.Claims
        .Where(c => c.Type == "Permission")
        .Select(c => c.Value);

    // 【核心邏輯】比對資料庫的 FunctionCode 是否在使用者的權限 Claims 中
    var filteredModel = allMenuItems
        .Where(m => permissions.Contains(m.FunctionCode))
        .OrderBy(m => m.SortOrder);

    return View(filteredModel);
}
```

### 2. 優點分析
1.  **邏輯封裝**：`_Layout.cshtml` 完全不需要知道權限邏輯，只需負責呼叫組件。
2.  **效能優化**：在 C# 集合運算中完成過濾，比在 Razor 視圖中反覆使用 `@if` 效能更好且更易於單元測試。
3.  **高度維護性**：若未來權限邏輯變動 (例如加入「暫時停用功能」的檢查)，僅需修改 `ViewComponent` 一處即可。

---
*本文件由資深系統設計師撰寫，旨在提供 MyFitnessCoach 系統在 UI 安全過濾上的標準實作方式。*
