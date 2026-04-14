# AccountController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

## 一、全局架構概覽

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Browser (用戶端)                                    │
│   POST /Account/Login  |  POST /Account/ForgetPassword  |  POST /Account/Logout │
└──────────────────────────────────┬──────────────────────────────────────────────┘
                                   │ HTTP Request
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         ASP.NET Core Middleware Pipeline                         │
│  UseHttpsRedirection → UseStaticFiles → UseRouting                              │
│  → UseAuthentication (Cookie) → UseAuthorization → Endpoint Routing             │
└──────────────────────────────────┬──────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          AccountController                                       │
│  DI 注入: IMemberAccountService, IWebHostEnvironment                             │
│  Actions: Login, Logout, ForgetPassword, ResetPassword,                          │
│           ChangePassword, InstructorDetails                                      │
└──────────────────────────────────┬──────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                      MemberAccountService (Service 層)                           │
│  DI 注入: IAccountRepository, IEmailService,                                     │
│           IPasswordHasher<User>, ILogger<MemberAccountService>                   │
└────────────┬───────────────────────────────┬────────────────────────────────────┘
             │                               │
             ▼                               ▼
┌──────────────────────────┐   ┌──────────────────────────────┐
│   AccountRepository      │   │     EmailService              │
│   (Repository 層)        │   │   (SMTP via MailKit)          │
│   DI: DbContext           │   │   DI: IConfiguration, ILogger │
└────────────┬─────────────┘   └──────────────────────────────┘
             │
             ▼
┌──────────────────────────┐
│   EF Core DbContext      │
│  MyFitnessCoachDbContext │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│      SQL Server          │
│  Users, Instructors,     │
│  Employees, UserRoles    │
└──────────────────────────┘
```

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊

| 行號 | 註冊程式碼 | 生命週期 |
|------|-----------|---------|
| L24-25 | `AddDbContext<MyFitnessCoachDbContext>` | **Scoped** |
| L44 | `AddScoped<IAccountRepository, AccountRepository>()` | **Scoped** |
| L45 | `AddScoped<BCryptPasswordHasher>()` | **Scoped** |
| L47 | `AddScoped<IPasswordHasher<User>, PasswordHasher<User>>()` | **Scoped** |
| L48 | `AddScoped<IMemberAccountService, MemberAccountService>()` | **Scoped** |
| L49 | `AddScoped<IEmailService, EmailService>()` | **Scoped** |
| L119-129 | Cookie Authentication 服務配置 | **Singleton**（驗證方案） |

> **注意：** L45 註冊了 `BCryptPasswordHasher`（具體類別），但 L47 將 `IPasswordHasher<User>` 綁定到 `PasswordHasher<User>`（ASP.NET Core Identity 預設），而非 `BCryptPasswordHasher`。這意味著 `MemberAccountService` 透過 `IPasswordHasher<User>` 注入的是 Identity 預設的 Hasher，而 `BCryptPasswordHasher` 需要透過具體類別才能解析。

### 2.2 生命週期範圍說明

所有 Account 相關服務皆為 **Scoped**，表示：
- 每個 HTTP Request 會建立一組獨立的物件實例
- 同一 Request 中多次注入同一介面，取得的是同一實例
- Request 結束後，所有 Scoped 物件自動 Dispose

### 2.3 DI 注入鏈（由下往上）

```
SQL Server
  ↑
MyFitnessCoachDbContext (Scoped)
  ↑
AccountRepository : IAccountRepository (Scoped)
  ↑
MemberAccountService : IMemberAccountService (Scoped)
  ├── IAccountRepository ← AccountRepository
  ├── IEmailService ← EmailService
  ├── IPasswordHasher<User> ← PasswordHasher<User>
  └── ILogger<MemberAccountService> ← 框架自動提供
  ↑
AccountController
  ├── IMemberAccountService ← MemberAccountService
  └── IWebHostEnvironment ← 框架自動提供 (Singleton)
```

### 2.4 建構子程式碼

**AccountController** (`Controllers/AccountController.cs` L21-25)：
```csharp
public AccountController(IMemberAccountService accountService, IWebHostEnvironment environment)
{
    _accountService = accountService;
    _environment = environment;
}
```

**MemberAccountService** (`Services/AccountService.cs` L28-38)：
```csharp
public MemberAccountService(
    IAccountRepository accountRepository,
    IEmailService emailService,
    ILogger<MemberAccountService> logger,
    IPasswordHasher<User> passwordHasher)
{
    _accountRepository = accountRepository;
    _emailService = emailService;
    _logger = logger;
    _passwordHasher = passwordHasher;
}
```

**AccountRepository** (`Repositories/AccountRepository.cs` L24-28)：
```csharp
public AccountRepository(MyFitnessCoachDbContext db)
{
    _db = db;
}
```

**EmailService** (`Services/EmailService.cs` L15-19)：
```csharp
public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
{
    _configuration = configuration;
    _logger = logger;
}
```

### 2.5 介面與實作對照表

| 介面 | 實作類別 | 檔案路徑 |
|------|---------|---------|
| `IMemberAccountService` | `MemberAccountService` | `Services/AccountService.cs` |
| `IAccountRepository` | `AccountRepository` | `Repositories/AccountRepository.cs` |
| `IEmailService` | `EmailService` | `Services/EmailService.cs` |
| `IPasswordHasher<User>` | `PasswordHasher<User>` | Microsoft.AspNetCore.Identity（框架內建） |
| `IWebHostEnvironment` | （框架提供） | ASP.NET Core 內建 |
| `IConfiguration` | （框架提供） | ASP.NET Core 內建 |

---

## 三、完整 Request 生命週期（以 Login POST 為例）

### 步驟 1：HTTP Request

```
POST /Account/Login HTTP/1.1
Content-Type: application/x-www-form-urlencoded

Account=admin&Password=123456&__RequestVerificationToken=CfDJ8...
```

用戶在 Login.cshtml 頁面填入帳號密碼後，表單以 POST 方式提交至 `/Account/Login`。

### 步驟 2：Middleware Pipeline

請求依序經過以下中介軟體（`Program.cs` L147-181）：

```
HttpsRedirection (L147)
  → StaticFiles (L149-176)   ← 非靜態檔案，略過
  → Routing (L178)            ← 解析路由模板
  → Authentication (L180)     ← 嘗試從 Cookie 還原身份（此時尚未登入，無 Cookie）
  → Authorization (L181)      ← Login 未標 [Authorize]，通過
  → Endpoint Execution        ← 執行 Controller Action
```

**ValidateAntiForgeryToken** 在 Action 進入前，由 MVC Filter Pipeline 驗證 `__RequestVerificationToken`，防止 CSRF 攻擊。

### 步驟 3：路由匹配

`Program.cs` L185-187 定義的預設路由模板：
```csharp
pattern: "{controller=Account}/{action=Login}/{id?}"
```

- `POST /Account/Login` → Controller = `Account`, Action = `Login`
- 因為有兩個 `Login` 方法，MVC 根據 `[HttpPost]` 屬性選擇 POST 版本

### 步驟 4：DI 容器建立物件鏈

MVC 框架透過 DI 容器建立 `AccountController`，連鎖觸發以下建構：

```
1. MyFitnessCoachDbContext  (Scoped - 新建)
2. AccountRepository        (Scoped - 注入 DbContext)
3. EmailService             (Scoped - 注入 IConfiguration, ILogger)
4. PasswordHasher<User>     (Scoped - 框架 Identity 內建)
5. MemberAccountService     (Scoped - 注入上述 1,2,3,4 + ILogger)
6. AccountController        (注入 MemberAccountService + IWebHostEnvironment)
```

### 步驟 5：Controller Action 執行

`Controllers/AccountController.cs` L136-209：

```csharp
[HttpPost]
[ValidateAntiForgeryToken]
public async Task<IActionResult> Login(LoginViewModel model, string? returnUrl = null)
{
    // L140-143: ModelState 驗證
    if (!ModelState.IsValid) return View(model);

    // L145-149: 轉換 ViewModel → DTO
    var dto = new LoginDto { Account = model.Account, Password = model.Password };

    // L151: 呼叫 Service 層
    var result = await _accountService.LoginAsync(dto);

    // L152-156: 驗證失敗
    if (!result.IsSuccess || result.User == null)
    {
        ModelState.AddModelError(string.Empty, result.Message);
        return View(model);
    }

    // L158-189: 建立 Claims 身份
    var claims = new List<Claim> { ... };
    // 加入 NameIdentifier, Name, Email, Account, InstructorId, EmployeeId, DepartmentId, Roles, Functions

    // L191-192: 建立 ClaimsIdentity / ClaimsPrincipal
    var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme, ...);
    var principal = new ClaimsPrincipal(identity);

    // L194-201: 寫入 Authentication Cookie
    await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, principal,
        new AuthenticationProperties { IsPersistent = true, ExpiresUtc = DateTimeOffset.UtcNow.AddHours(8) });

    // L203-208: 重導向
    if (!string.IsNullOrWhiteSpace(returnUrl) && Url.IsLocalUrl(returnUrl))
        return Redirect(returnUrl);
    return RedirectToAction("Index", "Dashboard");
}
```

### 步驟 6：Service 層商業邏輯

`Services/AccountService.cs` L104-154（`LoginAsync` 方法）：

```csharp
public async Task<LoginResultDto> LoginAsync(LoginDto dto)
{
    // L106: 查詢用戶
    var user = await _accountRepository.GetByAccountAsync(dto.Account);

    // L108-111: 帳號不存在檢查
    if (user == null || string.IsNullOrWhiteSpace(user.HashedPassword))
        return new LoginResultDto { IsSuccess = false, Message = "帳號或密碼錯誤" };

    // L113-117: 密碼驗證（使用 IPasswordHasher<User>）
    var result = _passwordHasher.VerifyHashedPassword(user, user.HashedPassword, dto.Password);
    if (result == PasswordVerificationResult.Failed)
        return new LoginResultDto { IsSuccess = false, Message = "帳號或密碼錯誤" };

    // L119-127: 帳號狀態檢查（IsConfirmed, IsActive）

    // L129-130: 查詢關聯的 Instructor / Employee
    var instructor = await _accountRepository.GetInstructorByUserIdAsync(user.Id);
    var employee = await _accountRepository.GetEmployeeByUserIdAsync(user.Id);

    // L132-153: 組合 LoginResultDto（含 UserDto，內含 Roles, Functions）
}
```

### 步驟 7：Repository 層資料存取

`Repositories/AccountRepository.cs` L36-45（`GetByAccountAsync`）：

```csharp
public async Task<User?> GetByAccountAsync(string account)
{
    return await _db.Users
        .Include(u => u.UserRoles)
            .ThenInclude(ur => ur.Role)
                .ThenInclude(r => r.RoleFunctions)
                    .ThenInclude(rf => rf.Function)
        .AsNoTracking()
        .FirstOrDefaultAsync(u => u.Account == account);
}
```

`Repositories/AccountRepository.cs` L67-72（`GetInstructorByUserIdAsync`）：
```csharp
public async Task<Instructor?> GetInstructorByUserIdAsync(int userId)
{
    return await _db.Instructors
        .Include(i => i.User)
        .FirstOrDefaultAsync(i => i.UserId == userId);
}
```

`Repositories/AccountRepository.cs` L84-89（`GetEmployeeByUserIdAsync`）：
```csharp
public async Task<Employee?> GetEmployeeByUserIdAsync(int userId)
{
    return await _db.Employees
        .AsNoTracking()
        .FirstOrDefaultAsync(e => e.UserId == userId);
}
```

### 步驟 8：EF Core → SQL Server

EF Core 將 LINQ 查詢轉譯為 SQL。Login 流程產生的核心查詢包含：

```sql
-- 查詢用戶及其角色與功能（四層 Include）
SELECT TOP(1) u.*, ur.*, r.*, rf.*, f.*
FROM [Users] u
LEFT JOIN [UserRoles] ur ON u.Id = ur.UserId
LEFT JOIN [Roles] r ON ur.RoleId = r.Id
LEFT JOIN [RoleFunctions] rf ON r.Id = rf.RoleId
LEFT JOIN [Functions] f ON rf.FunctionId = f.Id
WHERE u.Account = @account

-- 查詢 Instructor
SELECT TOP(1) i.*, iu.*
FROM [Instructors] i
LEFT JOIN [Users] iu ON i.UserId = iu.Id
WHERE i.UserId = @userId

-- 查詢 Employee
SELECT TOP(1) e.*
FROM [Employees] e
WHERE e.UserId = @userId
```

### 步驟 9：View 渲染 / JSON 回傳

Login POST 成功時：
- 不渲染 View，而是回傳 `302 Redirect` 至 `/Dashboard/Index`
- 回應標頭中包含 `Set-Cookie: MyFitnessCoach.Auth=...`

Login POST 失敗時：
- 回傳 `Login.cshtml` View，搭配 ModelState 錯誤訊息
- Razor 引擎將 `LoginViewModel` 繫結至 View，渲染 HTML

### 步驟 10：HTTP Response

```
HTTP/1.1 302 Found
Location: /Dashboard/Index
Set-Cookie: MyFitnessCoach.Auth=CfDJ8...; path=/; secure; httponly; samesite=lax; expires=...
```

瀏覽器收到 302 後自動跳轉至 Dashboard 頁面，後續請求都會攜帶此 Cookie。

### 步驟 11：Scoped 物件 Dispose

Request 結束後，ASP.NET Core DI 容器自動 Dispose 所有 Scoped 物件：

```
AccountController.Dispose()
MemberAccountService（無 IDisposable）
AccountRepository（無 IDisposable）
EmailService（無 IDisposable）
MyFitnessCoachDbContext.Dispose()  ← 釋放資料庫連線回連線池
```

---

## 四、其他 Action 生命週期

### 4.1 Login GET (`L122-132`)

| 項目 | 與 Login POST 的差異 |
|------|---------------------|
| HTTP Method | GET（非 POST） |
| Filter | 無 `[ValidateAntiForgeryToken]` |
| 前置檢查 | 若已登入（`User.Identity.IsAuthenticated`），直接 302 → Dashboard |
| Service 呼叫 | **無**，不呼叫任何 Service |
| 回傳 | `View()` 渲染 Login.cshtml |

### 4.2 ChangePassword GET (`L27-32`)

| 項目 | 差異 |
|------|------|
| 授權 | `[Authorize]` — 必須已登入 |
| Service 呼叫 | 無 |
| 回傳 | `View()` 渲染空白的 ChangePassword.cshtml |

### 4.3 ChangePassword POST (`L34-59`)

| 項目 | 差異 |
|------|------|
| 授權 | `[Authorize]` |
| Claims 提取 | 從 `User.FindFirst(ClaimTypes.NameIdentifier)` 取得 userId |
| Service 呼叫 | `_accountService.ChangePasswordAsync(userId, model.OldPassword, model.NewPassword)` |
| Service 邏輯 | 驗證舊密碼 → 雜湊新密碼 → 更新 DB（`AccountService.cs` L83-102） |
| 回傳 | 成功：`TempData` + `View()`；失敗：ModelState 錯誤 + `View(model)` |

### 4.4 InstructorDetails GET (`L61-79`)

| 項目 | 差異 |
|------|------|
| 授權 | `[Authorize]` + `[Function("edit_InstructorDetails")]` 功能權限檢查 |
| Service 呼叫 | `_accountService.GetInstructorDetailsAsync(userId)` |
| Service 邏輯 | 查詢 User + Instructor 資料，組合成 `InstructorDto`（`AccountService.cs` L40-54） |
| 回傳 | `View(dto)` 渲染 InstructorDetails.cshtml |

### 4.5 InstructorDetails POST (`L81-120`)

| 項目 | 差異 |
|------|------|
| 額外參數 | `IFormFile? imageFile` — 處理教練頭像上傳 |
| 檔案上傳 | 使用 `IWebHostEnvironment.WebRootPath` 將圖片儲存至 `wwwroot/img/instructors/`（L96-107） |
| Service 呼叫 | `_accountService.UpdateInstructorDetailsAsync(dto)` |
| Service 邏輯 | 若 Instructor 不存在則新增，存在則更新（`AccountService.cs` L56-81） |
| 回傳 | `RedirectToAction(nameof(InstructorDetails))` — PRG 模式 |

### 4.6 ForgetPassword GET (`L211-215`)

| 項目 | 差異 |
|------|------|
| 授權 | 無（匿名可存取） |
| Service 呼叫 | 無 |
| 回傳 | `View()` |

### 4.7 ForgetPassword POST (`L217-241`)

| 項目 | 差異 |
|------|------|
| Service 呼叫 | `_accountService.CreateResetPasswordRequestAsync(email, urlFactory)` |
| Service 邏輯 | 產生 GUID 重設碼 → 儲存至 User → 透過 `IEmailService` 寄出重設信（`AccountService.cs` L156-195） |
| 外部依賴 | **EmailService** 透過 MailKit 連接 Gmail SMTP 伺服器 |
| 回傳 | 同一 View，透過 `ViewBag` 顯示寄送結果 |

### 4.8 ResetPassword GET (`L243-257`)

| 項目 | 差異 |
|------|------|
| 授權 | `[AllowAnonymous]` |
| Service 呼叫 | `_accountService.IsResetPasswordCodeValidAsync(code)` — 驗證重設碼是否有效且未過期 |
| 回傳 | 有效：`View(ResetPasswordViewModel)`；無效：重導向回 ForgetPassword |

### 4.9 ResetPassword POST (`L259-285`)

| 項目 | 差異 |
|------|------|
| 授權 | `[AllowAnonymous]` |
| Service 呼叫 | `_accountService.ResetPasswordAsync(dto)` |
| Service 邏輯 | 驗證碼有效性 → 雜湊新密碼 → 清除重設碼 → 儲存（`AccountService.cs` L205-226） |
| 回傳 | 成功：`TempData["LoginMessage"]` + 重導向至 Login |

### 4.10 Logout POST (`L287-293`)

| 項目 | 差異 |
|------|------|
| Service 呼叫 | **無 Service 呼叫** |
| 核心操作 | `HttpContext.SignOutAsync()` — 清除 Authentication Cookie |
| 回傳 | 重導向至 Login |

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── AccountController.cs
├── Services/
│   ├── AccountService.cs          (含 IMemberAccountService + MemberAccountService)
│   ├── IEmailService.cs
│   └── EmailService.cs
├── Repositories/
│   └── AccountRepository.cs       (含 IAccountRepository + AccountRepository)
├── Models/
│   ├── EfModels/
│   │   ├── User.cs
│   │   ├── Employee.cs
│   │   ├── Instructor.cs
│   │   ├── UserRole.cs
│   │   ├── Role.cs
│   │   ├── RoleFunction.cs
│   │   └── Function.cs
│   ├── DTOs/
│   │   ├── AccountResultDto.cs    (LoginDto, AccountResultDto, LoginResultDto, ResetPasswordRequestDto, ResetPasswordDto)
│   │   ├── UserDto.cs
│   │   └── InstructorDto.cs
│   ├── ViewModel/
│   │   ├── LoginViewModel.cs      (含 ChangePasswordViewModel)
│   │   ├── ForgetPasswordViewModel.cs
│   │   └── ResetPasswordViewModel.cs
│   └── Infra/
│       └── BCryptPasswordHasher.cs
├── Infra/
│   ├── FunctionAttribute.cs
│   └── ClaimExtensions.cs
└── Views/
    └── Account/
        ├── Login.cshtml
        ├── ChangePassword.cshtml
        ├── InstructorDetails.cshtml
        ├── ForgetPassword.cshtml
        └── ResetPassword.cshtml
```

### 5.2 Entity 關聯鏈

```
User (1) ──────── (0..1) Employee
  │                        │
  │                        ├── DepartmentId → Department
  │                        ├── ManagerId → Employee (self-ref)
  │                        └── WorkDelegateId → Employee (self-ref)
  │
  ├── (1) ──── (*) UserRole ──── (*) Role
  │                                    │
  │                                    └── (*) RoleFunction ──── (*) Function
  │
  └── (1) ──── (*) Instructor
```

---

## 六、重要概念總整理

### 6.1 Cookie Authentication 機制

- **Program.cs L119-129** 配置 Cookie 驗證
- Cookie 名稱：`MyFitnessCoach.Auth`
- 登入路徑：`/Account/Login`
- Cookie 安全性：`HttpOnly = true`、`SameSite = Lax`、`SecurePolicy = Always`
- 登入時（`AccountController.cs` L194-201）透過 `HttpContext.SignInAsync()` 寫入 Cookie
- Cookie 有效期：8 小時（`ExpiresUtc = DateTimeOffset.UtcNow.AddHours(8)`）
- `IsPersistent = true`：關閉瀏覽器後 Cookie 仍然有效

### 6.2 Claims-Based 身份模型

Login 成功後建立的 Claims 包含（`AccountController.cs` L158-189）：

| Claim Type | 來源 | 用途 |
|-----------|------|------|
| `ClaimTypes.NameIdentifier` | `User.Id` | 唯一用戶識別碼 |
| `ClaimTypes.Name` | `User.UserName` | 顯示名稱 |
| `ClaimTypes.Email` | `User.Email` | 電子郵件 |
| `"Account"` | `User.Account` | 帳號 |
| `"InstructorId"` | `Instructor.Id` | 教練身份識別（可能無） |
| `"EmployeeId"` | `Employee.Id` | 員工身份識別（可能無） |
| `"DepartmentId"` | `Employee.DepartmentId` | 部門識別（可能無） |
| `ClaimTypes.Role` | `UserRoles → Role.RoleName` | 角色（可多個） |
| `"Function"` | `RoleFunctions → Function.FunctionName` | 功能權限（可多個） |

### 6.3 自訂 FunctionAttribute 權限過濾器

`Infra/FunctionAttribute.cs`：
- 繼承自 `AuthorizeAttribute`，同時實作 `IAsyncAuthorizationFilter`
- 在 Action 執行前檢查使用者 Claims 中是否包含指定的 `"Function"` Claim
- 若無權限，回傳 `ForbidResult`（導向 `/Home/Error/403`）
- 範例：`[Function("edit_InstructorDetails")]` 在 `InstructorDetails` Action 上

### 6.4 密碼雜湊策略

- **BCryptPasswordHasher** (`Models/Infra/BCryptPasswordHasher.cs`)：自訂 Hasher，支援 BCrypt 格式及舊版 Identity Hash 的向下相容
- **實際注入的是** `PasswordHasher<User>`（ASP.NET Core Identity 預設），因為 `Program.cs` L47 註冊的是 `IPasswordHasher<User> → PasswordHasher<User>`
- `BCryptPasswordHasher` 只能透過直接注入 `BCryptPasswordHasher` 類別使用（L45 的註冊）

### 6.5 ValidateAntiForgeryToken (CSRF 防護)

- 所有 POST Action 都標記了 `[ValidateAntiForgeryToken]`
- View 中使用 `@Html.AntiForgeryToken()` 或 `<form asp-action>` 自動產生 Token
- 確保表單提交來自同一網站，防止跨站請求偽造攻擊

### 6.6 PRG 模式（Post/Redirect/Get）

- `InstructorDetails POST` 和 `Logout` 使用 `RedirectToAction` 避免重複提交
- 使用 `TempData` 在重導向後傳遞一次性訊息

### 6.7 重設密碼流程

```
用戶輸入 Email → 產生 GUID 重設碼（30 分鐘有效）
  → 存入 User.ResetPasswordConfirmCode / Expiry
  → EmailService 透過 Gmail SMTP 寄出重設連結
  → 用戶點擊連結 → 驗證碼有效性
  → 輸入新密碼 → 雜湊並更新 → 清除重設碼
```

---

## 七、完整資料流圖

### 7.1 Login 資料流

```
[Browser]
    │  POST { Account, Password, AntiForgeryToken }
    ▼
[Middleware Pipeline]
    │  HTTPS → Routing → Auth (無Cookie) → AntiForgerValidation
    ▼
[AccountController.Login POST]
    │  LoginViewModel → ModelState 驗證
    │  LoginViewModel → LoginDto 轉換
    ▼
[MemberAccountService.LoginAsync]
    │  1. GetByAccountAsync(account)
    │     └→ [AccountRepository] → EF Core → SQL: SELECT Users + Roles + Functions
    │  2. VerifyHashedPassword(user, hash, password)
    │     └→ [PasswordHasher<User>] 比對密碼雜湊
    │  3. 檢查 IsConfirmed, IsActive
    │  4. GetInstructorByUserIdAsync / GetEmployeeByUserIdAsync
    │     └→ [AccountRepository] → EF Core → SQL
    │  5. 組裝 LoginResultDto (含 UserDto, Roles, Functions)
    ▼
[AccountController]
    │  建立 Claims → ClaimsIdentity → ClaimsPrincipal
    │  HttpContext.SignInAsync() → 寫入 Cookie
    ▼
[HTTP Response]
    302 Redirect → /Dashboard/Index
    Set-Cookie: MyFitnessCoach.Auth=...
```

### 7.2 ForgetPassword / ResetPassword 資料流

```
[ForgetPassword POST]
    │  Email
    ▼
[MemberAccountService.CreateResetPasswordRequestAsync]
    │  GetByEmailAsync → 產生 GUID → Update User → SaveChanges
    │  EmailService.SendPasswordResetEmail → SMTP → Gmail
    ▼
[用戶信箱] ─── 點擊連結 ───→ [ResetPassword GET]
    │  驗證 code 有效性
    ▼
[ResetPassword POST]
    │  { Code, Password, ConfirmPassword }
    ▼
[MemberAccountService.ResetPasswordAsync]
    │  GetByResetPasswordCodeAsync → 驗證過期 → 雜湊新密碼
    │  清除 ResetPasswordConfirmCode → SaveChanges
    ▼
[302 Redirect → Login]
    TempData["LoginMessage"] = "密碼已重設完成"
```

---

## 八、涉及的關鍵檔案清單

| 層級 | 檔案 | 說明 |
|------|------|------|
| 啟動配置 | `Program.cs` | DI 註冊、中介軟體、路由設定 |
| Controller | `Controllers/AccountController.cs` | 10 個 Action（5 GET + 4 POST + 1 POST Logout） |
| Service (介面+實作) | `Services/AccountService.cs` | `IMemberAccountService` + `MemberAccountService` |
| Service (Email) | `Services/IEmailService.cs` | Email 服務介面 |
| Service (Email) | `Services/EmailService.cs` | MailKit SMTP 實作 |
| Repository | `Repositories/AccountRepository.cs` | `IAccountRepository` + `AccountRepository` |
| Entity | `Models/EfModels/User.cs` | 用戶實體 |
| Entity | `Models/EfModels/Employee.cs` | 員工實體 |
| Entity | `Models/EfModels/Instructor.cs` | 教練實體 |
| DTO | `Models/DTOs/AccountResultDto.cs` | 含 LoginDto, LoginResultDto, ResetPasswordDto 等 |
| DTO | `Models/DTOs/UserDto.cs` | 用戶資料傳輸物件 |
| DTO | `Models/DTOs/InstructorDto.cs` | 教練資料傳輸物件 |
| ViewModel | `Models/ViewModel/LoginViewModel.cs` | 含 ChangePasswordViewModel |
| ViewModel | `Models/ViewModel/ForgetPasswordViewModel.cs` | 忘記密碼表單 |
| ViewModel | `Models/ViewModel/ResetPasswordViewModel.cs` | 重設密碼表單 |
| Infra | `Models/Infra/BCryptPasswordHasher.cs` | BCrypt 密碼雜湊（目前未被主流程使用） |
| Infra | `Infra/FunctionAttribute.cs` | 自訂功能權限過濾器 |
| Infra | `Infra/ClaimExtensions.cs` | ClaimsPrincipal 擴充方法 |
| View | `Views/Account/Login.cshtml` | 登入頁面 |
| View | `Views/Account/ChangePassword.cshtml` | 修改密碼頁面 |
| View | `Views/Account/InstructorDetails.cshtml` | 教練資料編輯頁面 |
| View | `Views/Account/ForgetPassword.cshtml` | 忘記密碼頁面 |
| View | `Views/Account/ResetPassword.cshtml` | 重設密碼頁面 |

---

## 九、程式碼優化建議

### 9.1 `SendPasswordResetEmail` 同步封裝非同步方法 — 可能導致死鎖

**問題位置：** `Services/EmailService.cs` L138-141

```csharp
public bool SendPasswordResetEmail(string email, string userName, string resetUrl)
{
    return Task.Run(() => SendResetPwdEmailAsync(email, userName, resetUrl)).Result;
}
```

**問題原因：** 使用 `.Result` 阻塞等待非同步方法完成。在 ASP.NET Core 雖然不像傳統 ASP.NET 有 SynchronizationContext 死鎖問題，但仍會佔用 ThreadPool 執行緒，降低伺服器吞吐量。

**建議改法：** 在 `MemberAccountService.CreateResetPasswordRequestAsync`（L181）中直接呼叫非同步版本：

```csharp
// 原本
emailSent = _emailService.SendPasswordResetEmail(user.Email, user.UserName, resetUrl);
// 建議改為
emailSent = await _emailService.SendResetPwdEmailAsync(user.Email, user.UserName, resetUrl);
```

### 9.2 BCryptPasswordHasher 註冊但未被 Login 流程使用

**問題位置：** `Program.cs` L45 vs L47

```csharp
L45: builder.Services.AddScoped<BCryptPasswordHasher>();                        // 註冊具體類別
L47: builder.Services.AddScoped<IPasswordHasher<User>, PasswordHasher<User>>(); // 介面綁定到 Identity 預設
```

**問題原因：** `MemberAccountService` 注入的是 `IPasswordHasher<User>`，解析到的是 `PasswordHasher<User>`（Identity 預設），而非 `BCryptPasswordHasher`。若資料庫中存在 BCrypt 格式的密碼雜湊（`$2a$`、`$2b$` 開頭），`PasswordHasher<User>` 無法驗證。

**建議改法：** 若確定要使用 BCrypt，將 L47 改為：

```csharp
builder.Services.AddScoped<IPasswordHasher<User>>(sp => sp.GetRequiredService<BCryptPasswordHasher>());
```

或若已確認全部使用 Identity 格式，移除 L45 的 `BCryptPasswordHasher` 註冊以避免混淆。

### 9.3 ChangePassword 成功後未登出重新驗證

**問題位置：** `Controllers/AccountController.cs` L50-58

**問題原因：** 密碼修改成功後只顯示 `TempData` 訊息，但 Cookie 中的 Claims 並未更新。雖然當前 Claims 不包含密碼資訊所以功能上無問題，但最佳實踐是在密碼變更後強制重新簽發 Cookie 或登出，以確保安全性（例如防止舊 Session 被利用）。

**建議改法：** 修改密碼成功後重新簽入或登出：

```csharp
// 成功後強制登出，要求重新登入
await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
TempData["LoginMessage"] = "密碼修改成功，請重新登入";
return RedirectToAction(nameof(Login));
```

### 9.4 InstructorDetails POST 缺少檔案類型與大小驗證

**問題位置：** `Controllers/AccountController.cs` L95-107

**問題原因：** 上傳檔案時只檢查 `imageFile != null && imageFile.Length > 0`，未驗證：
- 檔案類型（可能上傳 `.exe`、`.js` 等危險檔案）
- 檔案大小上限

**建議改法：**

```csharp
var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
var extension = Path.GetExtension(imageFile.FileName).ToLowerInvariant();
if (!allowedExtensions.Contains(extension))
{
    TempData["ErrorMessage"] = "僅支援 jpg, png, gif, webp 格式";
    return RedirectToAction(nameof(InstructorDetails));
}
if (imageFile.Length > 5 * 1024 * 1024) // 5MB
{
    TempData["ErrorMessage"] = "圖片大小不可超過 5MB";
    return RedirectToAction(nameof(InstructorDetails));
}
```

### 9.5 EmailService 中硬編碼的密碼預設值

**問題位置：** `Services/EmailService.cs` L100-104

```csharp
var emailAccount = _configuration["EmailSettings:Account"] ?? "myfitnesscoach2026";
var emailPassword = _configuration["EmailSettings:Password"] ?? "xzkttflwhbdqssej";
```

**問題原因：** 應用程式密碼以明文形式寫在程式碼中作為 fallback。即使正式環境會從 User Secrets 或環境變數讀取，此程式碼仍存在安全風險（會被版本控制記錄）。

**建議改法：** 移除硬編碼的預設值，改為在缺少設定時拋出明確錯誤：

```csharp
var emailAccount = _configuration["EmailSettings:Account"]
    ?? throw new InvalidOperationException("EmailSettings:Account is not configured");
var emailPassword = _configuration["EmailSettings:Password"]
    ?? throw new InvalidOperationException("EmailSettings:Password is not configured");
```

### 9.6 GetByAccountAsync 使用 AsNoTracking 但 Login 後需要追蹤 Update

**問題位置：** `Repositories/AccountRepository.cs` L36-45

**問題原因：** 查詢使用 `AsNoTracking()`，但 Login 流程中不需要更新 User 實體，所以此處使用 `AsNoTracking` 是正確且效能較好的做法。然而，`ForgetPassword` 流程先呼叫 `GetByEmailAsync`（L47-49，無 AsNoTracking）查詢後再 `Update`，這部分是正確的。此處不需要修改，設計合理。
