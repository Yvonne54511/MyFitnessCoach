# StaffController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

## 一、全局架構概覽

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              Browser (前端)                                 │
│  員工管理 (Index)  │  營養師管理 (InstructorList)  │  權限管理 (RoleFunctions) │
│  帳號啟用 (Activate)                                                         │
└─────────────────┬────────────────────────────────────────────────────────────┘
                  │ HTTP Request (GET/POST, AJAX + FormData)
                  ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                          Middleware Pipeline                                 │
│  UseHttpsRedirection → UseStaticFiles → UseRouting                          │
│  → UseAuthentication (Cookie) → UseAuthorization                            │
│  → [Authorize] + [Function("edit_UserAccounts")] (類別層級)                   │
│  → [AllowAnonymous] (Activate Action 例外)                                   │
└─────────────────┬────────────────────────────────────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│              StaffController [Authorize][Function("edit_UserAccounts")]       │
│  DI 注入:                                                                    │
│    ├── IUserService           (使用者/員工 CRUD + 角色/功能管理)                │
│    ├── PermissionService      (角色權限矩陣管理)                               │
│    ├── IInstructorService     (營養師 CRUD)                                   │
│    └── IWebHostEnvironment    (檔案上傳路徑)                                   │
└──┬──────────────┬───────────────────┬──────────────────┬─────────────────────┘
   │              │                   │                  │
   ▼              ▼                   ▼                  ▼
┌────────┐ ┌──────────────┐ ┌──────────────────┐ ┌──────────────────┐
│UserSvc │ │PermissionSvc │ │InstructorService │ │IWebHostEnvironment│
│        │ │              │ │                  │ │  (框架內建)        │
└───┬────┘ └──┬───────────┘ └────────┬─────────┘ └──────────────────┘
    │         │                      │
    ▼         ▼                      ▼
┌────────┐ ┌──────────────────┐ ┌──────────────────┐
│UserRepo│ │RoleRepo          │ │InstructorRepo    │
│        │ │FunctionRepo      │ │                  │
│        │ │RoleFunctionRepo  │ │                  │
│        │ │UserRepo          │ │                  │
│        │ │DbContext (直接)   │ │                  │
└───┬────┘ └────────┬─────────┘ └────────┬─────────┘
    │               │                     │
    ▼               ▼                     ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                     EF Core (MyFitnessCoachDbContext)                        │
│  DbSet: Users, UserRoles, Roles, Functions, RoleFunctions, Instructors      │
└──────────────────────────────────────────────────────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                             SQL Server                                       │
│  Tables: Users, UserRoles, Roles, Functions, RoleFunctions, Instructors      │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊

| 行號 | 程式碼 | 說明 |
|------|--------|------|
| L24-25 | `AddDbContext<MyFitnessCoachDbContext>` | 註冊 EF Core DbContext |
| L38 | `AddScoped<IRoleRepository, RoleRepository>()` | 角色 Repository |
| L39 | `AddScoped<IFunctionRepository, FunctionRepository>()` | 功能 Repository |
| L40 | `AddScoped<IRoleFunctionRepository, RoleFunctionRepository>()` | 角色-功能關聯 Repository |
| L42 | `AddScoped<PermissionService>()` | 權限管理 Service |
| L52 | `AddScoped<IUserRepository, UserRepository>()` | 使用者 Repository |
| L53 | `AddScoped<IUserService, UserService>()` | 使用者 Service |
| L54 | `AddScoped<IInstructorRepository, InstructorRepository>()` | 營養師 Repository |
| L55 | `AddScoped<IInstructorService, InstructorService>()` | 營養師 Service |
| L49 | `AddScoped<IEmailService, EmailService>()` | 郵件服務（邀請員工用） |
| L119-129 | `AddAuthentication(Cookie)` | Cookie 驗證機制 |

### 2.2 生命週期範圍

| 服務 | 生命週期 | 說明 |
|------|---------|------|
| `MyFitnessCoachDbContext` | **Scoped** | 每次 HTTP Request 建立一個實例 |
| `IUserRepository` / `UserRepository` | **Scoped** | 使用者資料存取 |
| `IUserService` / `UserService` | **Scoped** | 使用者商業邏輯 |
| `IRoleRepository` / `RoleRepository` | **Scoped** | 角色資料存取 |
| `IFunctionRepository` / `FunctionRepository` | **Scoped** | 功能資料存取 |
| `IRoleFunctionRepository` / `RoleFunctionRepository` | **Scoped** | 角色-功能映射資料存取 |
| `PermissionService` | **Scoped** | 權限管理商業邏輯 |
| `IInstructorRepository` / `InstructorRepository` | **Scoped** | 營養師資料存取 |
| `IInstructorService` / `InstructorService` | **Scoped** | 營養師商業邏輯 |
| `IEmailService` / `EmailService` | **Scoped** | 郵件發送服務 |
| `IWebHostEnvironment` | **Singleton** | 由框架內建提供 |

### 2.3 DI 注入鏈（由下往上）

```
SQL Server
  ↑
MyFitnessCoachDbContext (Scoped)
  ↑              ↑              ↑              ↑
UserRepository  RoleRepository  FunctionRepo   InstructorRepository
  ↑              ↑              ↑              ↑
  │         RoleFunctionRepo    │              InstructorService
  │              ↑              │              ↑
  │         PermissionService ←─┘              │
  │         (也注入 UserRepo + DbContext)       │
  ↑                                            │
UserService (+ EmailService)                   │
  ↑                                            │
  └──────────┬─────────────────────────────────┘
             ↑
      StaffController
             ↑
      IWebHostEnvironment (Singleton)
```

### 2.4 建構子程式碼

**StaffController**（`Controllers/StaffController.cs` L18-29）：
```csharp
// L18-21: 私有欄位
private readonly IUserService _userService;
private readonly PermissionService _permissionService;
private readonly IInstructorService _instructorService;
private readonly IWebHostEnvironment _environment;

// L23-29: 建構子
public StaffController(IUserService userService, PermissionService permissionService,
    IInstructorService instructorService, IWebHostEnvironment environment)
{
    _userService = userService;
    _permissionService = permissionService;
    _instructorService = instructorService;
    _environment = environment;
}
```

**UserService**（`Services/UserService.cs` L45-54）：
```csharp
private readonly IUserRepository _userRepository;
private readonly IEmailService _emailService;
private readonly PasswordHasher<User> _passwordHasher;

public UserService(IUserRepository userRepository, IEmailService emailService)
{
    _userRepository = userRepository;
    _emailService = emailService;
    _passwordHasher = new PasswordHasher<User>();
}
```

**PermissionService**（`Models/Services/PermissionService.cs` L11-29）：
```csharp
private readonly IRoleRepository _roleRepo;
private readonly IFunctionRepository _funcRepo;
private readonly IRoleFunctionRepository _rfRepo;
private readonly IUserRepository _userRepo;
private readonly MyFitnessCoachDbContext _context;

public PermissionService(IRoleRepository roleRepo, IFunctionRepository funcRepo,
    IRoleFunctionRepository rfRepo, IUserRepository userRepo, MyFitnessCoachDbContext context)
{
    _roleRepo = roleRepo;
    _funcRepo = funcRepo;
    _rfRepo = rfRepo;
    _userRepo = userRepo;
    _context = context;
}
```

**InstructorService**（`Services/InstructorService.cs` L23-29）：
```csharp
private readonly IInstructorRepository _repository;

public InstructorService(IInstructorRepository repository)
{
    _repository = repository;
}
```

### 2.5 介面與實作對照表

| 介面 | 實作類別 | 檔案位置 |
|------|---------|---------|
| `IUserService` | `UserService` | `Services/UserService.cs` |
| `IUserRepository` | `UserRepository` | `Repositories/UserRepository.cs` |
| `IInstructorService` | `InstructorService` | `Services/InstructorService.cs` |
| `IInstructorRepository` | `InstructorRepository` | `Repositories/InstructorRepository.cs` |
| `IRoleRepository` | `RoleRepository` | `Repositories/RoleRepository.cs` |
| `IFunctionRepository` | `FunctionRepository` | （對應 Repository 檔案） |
| `IRoleFunctionRepository` | `RoleFunctionRepository` | （對應 Repository 檔案） |
| `IEmailService` | `EmailService` | （對應 Service 檔案） |
| （無介面，直接注入） | `PermissionService` | `Models/Services/PermissionService.cs` |

---

## 三、完整 Request 生命週期（以 Index Action 為例）

以管理員進入員工管理主頁為主要範例：`GET /Staff/Index`

### 步驟 1：HTTP Request

```
GET /Staff/Index?name=&role=&id= HTTP/1.1
Host: localhost
Cookie: MyFitnessCoach.Auth=<encrypted_token>
```

管理員在側邊欄點擊「員工管理」連結，瀏覽器發送 GET 請求。

### 步驟 2：Middleware Pipeline

```
HttpsRedirection → StaticFiles → Routing
→ Authentication (解析 Cookie: MyFitnessCoach.Auth)
  → 取得 ClaimsPrincipal（含角色、Function Claims）
→ Authorization
  → [Authorize] (類別層級) → 確認已登入
  → [Function("edit_UserAccounts")] (類別層級) → 檢查 Function Claim
```

注意：`[Function("edit_UserAccounts")]` 標記在**類別層級**（`StaffController.cs` L15），表示此 Controller 的所有 Action 預設都需要此權限，除非個別 Action 標記了 `[AllowAnonymous]`（如 `Activate`）。

### 步驟 3：路由匹配

```
模板: {controller=Account}/{action=Login}/{id?}
匹配: controller = "Staff", action = "Index"
Query String Model Binding:
  name = null, role = null, id = null
```

### 步驟 4：DI 容器建立物件鏈

```
1. MyFitnessCoachDbContext (Scoped)
2. UserRepository(DbContext)
3. EmailService(...)
4. UserService(UserRepository, EmailService)
5. RoleRepository(DbContext)
6. FunctionRepository(DbContext)
7. RoleFunctionRepository(DbContext)
8. PermissionService(RoleRepo, FuncRepo, RfRepo, UserRepo, DbContext)
9. InstructorRepository(DbContext)
10. InstructorService(InstructorRepository)
11. IWebHostEnvironment (Singleton，已存在)
12. StaffController(UserService, PermissionService, InstructorService, Environment)
```

所有 Scoped 物件共用同一個 `DbContext` 實例。

### 步驟 5：Controller Action 執行

**`Index` Action**（`Controllers/StaffController.cs` L166-202）：

```csharp
// L166: 方法簽名，接收可選的搜尋參數
public async Task<IActionResult> Index(string? name = null, string? role = null, int? id = null)
{
    // L168: 透過 UserService 取得所有員工列表
    var staffDtos = await _userService.GetStaffListAsync(name, role, id);

    // L169-178: DTO → ViewModel 轉換
    var allStaff = staffDtos.Select(s => new StaffListItemViewModel
    {
        Id = s.Id, UserName = s.UserName, Email = s.Email,
        Account = s.Account, IsConfirmed = s.IsConfirmed,
        IsActive = s.IsActive, Roles = s.Roles
    }).ToList();

    // L181-183: 篩選員工列表（排除純 member 和 instructor 角色的使用者）
    var staffList = allStaff
        .Where(s => s.Roles.Any(r => r != "member" && r != "instructor"))
        .ToList();

    // L185-187: 營養師列表（ViewBag）
    ViewBag.InstructorList = allStaff
        .Where(s => s.Roles.Any(r => r == "instructor"))
        .ToList();

    // L189-190: 營養師詳細資料
    var instructors = await _instructorService.GetAllInstructorsAsync();
    ViewBag.InstructorDetails = instructors.ToList();

    // L192-194: 會員列表
    ViewBag.MemberList = allStaff
        .Where(s => s.Roles.Any(r => r == "member"))
        .ToList();

    // L196-199: 可用角色清單與當前搜尋條件
    ViewBag.Roles = await _userService.GetActiveRolesAsync();
    ViewBag.CurrentName = name;
    ViewBag.CurrentRole = role;
    ViewBag.CurrentId = id;

    // L201: 回傳 View（主模型為 staffList）
    return View(staffList);
}
```

### 步驟 6：Service 層商業邏輯

**`UserService.GetStaffListAsync`**（`Services/UserService.cs` L57-88）：

```csharp
public async Task<IEnumerable<StaffDto>> GetStaffListAsync(
    string? name = null, string? role = null, int? id = null)
{
    // L59: 取得所有使用者（含 UserRoles 和 Role）
    var users = await _userRepository.GetAllUsersAsync();
    var query = users.AsQueryable();

    // L63-76: 動態篩選
    if (!string.IsNullOrWhiteSpace(name))
        query = query.Where(u => u.UserName.Contains(name, StringComparison.OrdinalIgnoreCase));
    if (!string.IsNullOrWhiteSpace(role))
        query = query.Where(u => u.UserRoles.Any(ur => ur.Role.RoleName == role));
    if (id.HasValue)
        query = query.Where(u => u.Id == id.Value);

    // L78-87: 投影為 StaffDto
    return query.Select(u => new StaffDto
    {
        Id = u.Id, UserName = u.UserName, Email = u.Email,
        Account = u.Account, IsConfirmed = u.IsConfirmed,
        IsActive = u.IsActive,
        Roles = u.UserRoles.Select(ur => ur.Role.RoleName).ToList()
    });
}
```

### 步驟 7：Repository 層資料存取

**`UserRepository.GetAllUsersAsync`**（`Repositories/UserRepository.cs` L46-52）：

```csharp
public async Task<IEnumerable<User>> GetAllUsersAsync()
{
    return await _context.Users
        .Include(u => u.UserRoles)
            .ThenInclude(ur => ur.Role)
        .ToListAsync();
}
```

### 步驟 8：EF Core → SQL Server

```sql
SELECT u.*, ur.*, r.*
FROM Users u
LEFT JOIN UserRoles ur ON u.Id = ur.UserId
LEFT JOIN Roles r ON ur.RoleId = r.Id
```

### 步驟 9：View 渲染

回傳 `Views/Staff/Index.cshtml`，渲染內容包含：
- 員工列表表格（主模型 `List<StaffListItemViewModel>`）
- 營養師列表（`ViewBag.InstructorList`）
- 會員列表（`ViewBag.MemberList`）
- 營養師詳細資料（`ViewBag.InstructorDetails`）
- 邀請 Modal（靜態表單）
- 編輯 Modal（動態載入 `_EditStaffPartial`）
- 搜尋篩選表單

### 步驟 10：HTTP Response

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

<html>... (完整頁面含多個列表、Modal、JavaScript) ...</html>
```

### 步驟 11：Scoped 物件 Dispose

```
Request 結束 → DI 容器 Dispose Scoped 物件：
  1. StaffController.Dispose()
  2. UserService, PermissionService, InstructorService (非 IDisposable)
  3. UserRepository, RoleRepository, FunctionRepository,
     RoleFunctionRepository, InstructorRepository (非 IDisposable)
  4. EmailService.Dispose()（若實作 IDisposable）
  5. MyFitnessCoachDbContext.Dispose()
     → 關閉 SQL Server 連線（歸還 Connection Pool）
     → 釋放 ChangeTracker
```

---

## 四、其他 Action 生命週期

StaffController 共有 **29 個 Action**，分為四大功能區塊。以下逐一列出每個 Action 與主要 Action（Index）的差異。

### A. 員工管理區塊（7 個 Action）

#### 4.1 Index（已詳述於第三章）
主頁面，載入所有員工/營養師/會員列表。

#### 4.2 GetStaffList

| 項目 | 說明 |
|------|------|
| **路由** | `GET /Staff/GetStaffList?name=&role=&id=` |
| **差異** | 回傳 **PartialView**（`_StaffListPartial`），僅含員工表格 HTML。用於 AJAX 刷新列表。 |
| **Service** | `_userService.GetStaffListAsync(name, role, id)` |

```csharp
// Controllers/StaffController.cs L204-221
[HttpGet]
public async Task<IActionResult> GetStaffList(string? name = null, string? role = null, int? id = null)
{
    var staffDtos = await _userService.GetStaffListAsync(name, role, id);
    var staffList = staffDtos.Select(s => new StaffListItemViewModel { ... })
        .Where(s => s.Roles.Any(r => r != "member" && r != "instructor"))
        .ToList();
    return PartialView("_StaffListPartial", staffList);
}
```

#### 4.3 Invite [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/Invite` |
| **權限** | `[ValidateAntiForgeryToken]` |
| **差異** | 接收 `StaffInviteViewModel`；呼叫 `_userService.InviteStaffAsync`；**發送邀請郵件**；回傳 JSON |
| **特殊邏輯** | 使用 `Url.Action` 產生啟用連結，透過 `Func<string, string>` 回呼傳遞 |

```csharp
// Controllers/StaffController.cs L223-243
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> Invite(StaffInviteViewModel model)
{
    if (!ModelState.IsValid)
        return Json(new { success = false, message = "資料格式錯誤" });

    var dto = new StaffInviteDto { UserName = model.UserName, Email = model.Email, RoleIds = model.RoleIds };
    var result = await _userService.InviteStaffAsync(dto,
        code => Url.Action("Activate", "Staff", new { code }, Request.Scheme));
    return Json(new { success = result.IsSuccess, message = result.Message });
}
```

**Service 層**（`UserService.InviteStaffAsync` L105-134）：
1. 檢查 Email 是否已存在
2. 建立 User（未確認狀態，設定 `NewMemberConfirmCode` 和過期時間）
3. 透過 `_userRepository.CreateUserAsync` 建立使用者並分配角色
4. 透過 `_emailService.SendStaffInvitationEmail` 發送邀請郵件

#### 4.4 Edit [GET]

| 項目 | 說明 |
|------|------|
| **路由** | `GET /Staff/Edit/{id}` |
| **差異** | 回傳 **PartialView**（`_EditStaffPartial`），用於動態載入至 Modal。同時載入角色清單（`ViewBag.Roles`）。 |

```csharp
// Controllers/StaffController.cs L245-262
[HttpGet]
public async Task<IActionResult> Edit(int id)
{
    var dto = await _userService.GetStaffByIdAsync(id);
    if (dto == null) return NotFound();

    var model = new StaffEditViewModel
    {
        Id = dto.Id, UserName = dto.UserName, Email = dto.Email,
        IsActive = dto.IsActive, RoleIds = dto.RoleIds
    };
    ViewBag.Roles = await _userService.GetActiveRolesAsync();
    return PartialView("_EditStaffPartial", model);
}
```

#### 4.5 Edit [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/Edit` |
| **差異** | 接收 `StaffEditViewModel`；轉換為 `StaffUpdateDto`；更新使用者資料與角色；回傳 JSON |

```csharp
// Controllers/StaffController.cs L264-284
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> Edit(StaffEditViewModel model)
{
    if (!ModelState.IsValid)
        return Json(new { success = false, message = "資料格式錯誤" });

    var dto = new StaffUpdateDto
    {
        Id = model.Id, UserName = model.UserName,
        Email = model.Email, IsActive = model.IsActive, RoleIds = model.RoleIds
    };
    var result = await _userService.UpdateStaffAsync(dto);
    return Json(new { success = result.IsSuccess, message = result.Message });
}
```

**Repository 層**（`UserRepository.UpdateUserAsync` L87-119）：先刪除所有既有 UserRoles，再重新建立新的角色關聯。

#### 4.6 Delete [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/Delete` |
| **差異** | **硬刪除**使用者：先刪除 UserRoles 關聯，再刪除 User 實體。回傳 JSON。 |

```csharp
// Controllers/StaffController.cs L286-292
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> Delete(int id)
{
    var result = await _userService.DeleteStaffAsync(id);
    return Json(new { success = result.IsSuccess, message = result.Message });
}
```

**Repository 層**（`UserRepository.DeleteUserAsync` L122-132）：
```csharp
public async Task DeleteUserAsync(int id)
{
    var user = await _context.Users.FindAsync(id);
    if (user != null)
    {
        var roles = _context.UserRoles.Where(ur => ur.UserId == id);
        _context.UserRoles.RemoveRange(roles);
        _context.Users.Remove(user);
        await _context.SaveChangesAsync();
    }
}
```

### B. 帳號啟用區塊（2 個 Action）

#### 4.7 Activate [GET]

| 項目 | 說明 |
|------|------|
| **路由** | `GET /Staff/Activate?code=<guid>` |
| **權限** | **`[AllowAnonymous]`** — 不需登入 |
| **差異** | 驗證啟用碼是否有效；有效則回傳 `Activate.cshtml`（設定帳號密碼表單）；無效則回傳 `ActivateError.cshtml` |

```csharp
// Controllers/StaffController.cs L294-305
[AllowAnonymous][HttpGet]
public async Task<IActionResult> Activate(string code)
{
    if (string.IsNullOrEmpty(code) || !await _userService.IsConfirmCodeValidAsync(code))
    {
        ViewBag.Error = "啟動連結無效或已過期";
        return View("ActivateError");
    }
    return View(new StaffActivateViewModel { Code = code });
}
```

#### 4.8 Activate [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/Activate` |
| **權限** | **`[AllowAnonymous]`** + `[ValidateAntiForgeryToken]` |
| **差異** | 接收帳號/密碼；檢查帳號唯一性；密碼雜湊（`PasswordHasher`）；啟用帳號後導向登入頁 |

```csharp
// Controllers/StaffController.cs L307-339
[AllowAnonymous][HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> Activate(StaffActivateViewModel model)
{
    if (!ModelState.IsValid) return View(model);

    if (await _userService.AccountExistsAsync(model.Account))
    {
        ModelState.AddModelError("Account", "此帳號已被使用");
        return View(model);
    }

    var dto = new StaffActivateDto
    {
        Code = model.Code, Account = model.Account, Password = model.Password
    };
    var result = await _userService.ActivateAccountAsync(dto);
    if (result.IsSuccess)
    {
        TempData["LoginMessage"] = "帳號啟用成功，請登入";
        return RedirectToAction("Login", "Account");
    }
    ViewBag.Error = result.Message;
    return View("ActivateError");
}
```

**Service 層**（`UserService.ActivateAccountAsync` L161-176）：
- 透過 `NewMemberConfirmCode` 查找使用者
- 檢查啟用碼是否過期
- 設定 Account、HashedPassword、IsConfirmed = true
- 清除 ConfirmCode

### C. 營養師管理區塊（7 個 Action）

#### 4.9 InstructorList

| 項目 | 說明 |
|------|------|
| **路由** | `GET /Staff/InstructorList` |
| **差異** | 回傳完整 View（`InstructorList.cshtml`），顯示營養師列表 |
| **Service** | `_instructorService.GetAllInstructorsAsync()` |

```csharp
// Controllers/StaffController.cs L31-35
public async Task<IActionResult> InstructorList()
{
    var instructors = await _instructorService.GetAllInstructorsAsync();
    return View(instructors);
}
```

#### 4.10 GetInstructorList

| 項目 | 說明 |
|------|------|
| **路由** | `GET /Staff/GetInstructorList` |
| **差異** | 回傳 **PartialView**（`_InstructorListPartial`），供 AJAX 刷新。 |

```csharp
// Controllers/StaffController.cs L37-42
[HttpGet]
public async Task<IActionResult> GetInstructorList()
{
    var instructors = await _instructorService.GetAllInstructorsAsync();
    return PartialView("_InstructorListPartial", instructors);
}
```

#### 4.11 CreateInstructor [GET]

| 項目 | 說明 |
|------|------|
| **路由** | `GET /Staff/CreateInstructor?userId=` |
| **差異** | 回傳 **PartialView**（`_CreateInstructorPartial`）。若指定 `userId` 則鎖定該使用者；否則提供可選使用者清單（`ViewBag.Users`）。 |
| **Service** | `_instructorService.GetAvailableUsersAsync()` + `_userService.GetStaffListAsync()` |

```csharp
// Controllers/StaffController.cs L44-67
[HttpGet]
public async Task<IActionResult> CreateInstructor(int? userId = null)
{
    var availableUsers = await _instructorService.GetAvailableUsersAsync();
    if (userId.HasValue)
    {
        var allStaff = await _userService.GetStaffListAsync();
        var targetUser = allStaff.FirstOrDefault(u => u.Id == userId.Value);
        if (targetUser != null)
        {
            ViewBag.Users = new List<UserDto> { new UserDto { ... } };
            ViewBag.FixedUserId = userId.Value;
            return PartialView("_CreateInstructorPartial", new InstructorDto { UserId = userId.Value });
        }
    }
    ViewBag.Users = availableUsers;
    return PartialView("_CreateInstructorPartial", new InstructorDto());
}
```

#### 4.12 CreateInstructor [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/CreateInstructor` |
| **差異** | 接收 `InstructorDto` + `IFormFile? imageFile`（圖片上傳）；處理檔案存儲；回傳 JSON |
| **特殊邏輯** | 使用 `_environment.WebRootPath` 存儲圖片至 `wwwroot/img/instructors/` |

```csharp
// Controllers/StaffController.cs L69-103
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> CreateInstructor(InstructorDto dto, IFormFile? imageFile)
{
    try
    {
        if (ModelState.IsValid)
        {
            if (imageFile != null && imageFile.Length > 0)
            {
                var fileName = Guid.NewGuid().ToString() + Path.GetExtension(imageFile.FileName);
                var filePath = Path.Combine(_environment.WebRootPath, "img", "instructors", fileName);
                // ... 建立目錄、複製檔案 ...
                dto.ImageUrl = "/img/instructors/" + fileName;
            }
            await _instructorService.CreateInstructorAsync(dto);
            return Json(new { success = true, message = "新增成功" });
        }
        // ... 驗證錯誤處理 ...
    }
    catch (Exception ex)
    {
        return Json(new { success = false, message = "伺服器發生錯誤: " + ex.Message });
    }
}
```

#### 4.13 EditInstructor [GET]

| 項目 | 說明 |
|------|------|
| **路由** | `GET /Staff/EditInstructor/{id}` |
| **差異** | 回傳 **PartialView**（`_EditInstructorPartial`），載入營養師資料至 Modal。 |

```csharp
// Controllers/StaffController.cs L105-112
[HttpGet]
public async Task<IActionResult> EditInstructor(int id)
{
    var dto = await _instructorService.GetInstructorByIdAsync(id);
    if (dto == null) return NotFound();
    return PartialView("_EditInstructorPartial", dto);
}
```

#### 4.14 EditInstructor [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/EditInstructor` |
| **差異** | 接收 `InstructorDto` + `IFormFile?`；處理圖片上傳；呼叫 `_instructorService.UpdateInstructorAsync` |
| **邏輯** | 與 `CreateInstructor [POST]` 相似，但呼叫 `UpdateInstructorAsync` |

```csharp
// Controllers/StaffController.cs L114-148
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> EditInstructor(InstructorDto dto, IFormFile? imageFile)
{
    // ... 圖片處理邏輯同 Create ...
    await _instructorService.UpdateInstructorAsync(dto);
    return Json(new { success = true, message = "更新成功" });
}
```

#### 4.15 DeleteInstructor [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/DeleteInstructor` |
| **差異** | **硬刪除**營養師紀錄。回傳 JSON。 |

```csharp
// Controllers/StaffController.cs L150-156
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> DeleteInstructor(int id)
{
    await _instructorService.DeleteInstructorAsync(id);
    return Json(new { success = true, message = "刪除成功" });
}
```

#### 4.16 ToggleInstructorActive [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/ToggleInstructorActive` |
| **差異** | 切換營養師 `IsActive` 狀態（啟用/停用）。回傳 JSON。 |

```csharp
// Controllers/StaffController.cs L158-164
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> ToggleInstructorActive(int id)
{
    await _instructorService.ToggleIsActiveAsync(id);
    return Json(new { success = true, message = "狀態已變更" });
}
```

### D. 角色與權限管理區塊（13 個 Action）

#### 4.17 RoleFunctions

| 項目 | 說明 |
|------|------|
| **路由** | `GET /Staff/RoleFunctions` |
| **權限** | 額外標記 `[Function("edit_RoleFunctions")]` |
| **差異** | 載入角色、功能、角色-功能映射、權限矩陣；回傳 `RoleFunctions.cshtml` |
| **Service** | `_permissionService` 的四個方法 |

```csharp
// Controllers/StaffController.cs L342-353
[Function("edit_RoleFunctions")]
public async Task<IActionResult> RoleFunctions()
{
    var model = new PermissionViewModel
    {
        Roles = await _permissionService.GetAllRolesAsync(),
        Functions = await _permissionService.GetAllFunctionsAsync(),
        RoleFunctions = await _permissionService.GetAllRoleFunctionsAsync(),
        RolePermissionRows = await _permissionService.GetRolePermissionRowsAsync()
    };
    return View(model);
}
```

#### 4.18 EditRolePermission [GET]

| 項目 | 說明 |
|------|------|
| **路由** | `GET /Staff/EditRolePermission?roleId=` |
| **差異** | 回傳 PartialView（`_EditRolePermissionPartial`），顯示指定角色的功能和人員勾選清單。 |

```csharp
// Controllers/StaffController.cs L355-375
[HttpGet]
public async Task<IActionResult> EditRolePermission(int roleId)
{
    var rows = await _permissionService.GetRolePermissionRowsAsync();
    var row = rows.FirstOrDefault(r => r.RoleId == roleId);
    if (row == null) return NotFound();

    var staffList = await _userService.GetStaffListAsync();
    var model = new EditRolePermissionViewModel
    {
        RoleId = row.RoleId, RoleName = row.RoleName,
        SelectedFunctionIds = row.FunctionIds, SelectedUserIds = row.UserIds,
        AllFunctions = await _permissionService.GetAllFunctionsAsync(),
        AllStaff = staffList.ToList()
    };
    return PartialView("_EditRolePermissionPartial", model);
}
```

#### 4.19 UpdateRolePermissions [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/UpdateRolePermissions` |
| **差異** | 接收 `roleId`, `List<int> functionIds`, `List<int> userIds`；批次更新角色的功能權限與使用者分配。回傳 JSON。 |
| **特殊邏輯** | PermissionService 先刪除既有 RoleFunctions 和 UserRoles，再重新建立（全量替換策略）。 |

```csharp
// Controllers/StaffController.cs L377-383
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> UpdateRolePermissions(int roleId, List<int> functionIds, List<int> userIds)
{
    await _permissionService.UpdateRolePermissionsAsync(roleId, functionIds, userIds);
    return Json(new { success = true, message = "權限更新成功" });
}
```

#### 4.20 CreateRole [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/CreateRole` |
| **差異** | 接收 `RoleDto`；建立新角色；**RedirectToAction** 回到 RoleFunctions 頁面（非 JSON）。 |

```csharp
// Controllers/StaffController.cs L385-394
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> CreateRole(RoleDto dto)
{
    if (ModelState.IsValid) await _permissionService.CreateRoleAsync(dto);
    return RedirectToAction(nameof(RoleFunctions));
}
```

#### 4.21 EditRole [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/EditRole` |
| **差異** | 接收 `RoleDto`；更新角色資訊；RedirectToAction。 |

```csharp
// Controllers/StaffController.cs L396-405
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> EditRole(RoleDto dto)
{
    if (ModelState.IsValid) await _permissionService.UpdateRoleAsync(dto);
    return RedirectToAction(nameof(RoleFunctions));
}
```

#### 4.22 DeleteRole [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/DeleteRole` |
| **差異** | **硬刪除**角色。RedirectToAction。 |

```csharp
// Controllers/StaffController.cs L407-413
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> DeleteRole(int id)
{
    await _permissionService.DeleteRoleAsync(id);
    return RedirectToAction(nameof(RoleFunctions));
}
```

#### 4.23 CreateFunction [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/CreateFunction` |
| **差異** | 接收 `FunctionDto`；建立新功能。ModelState 驗證有額外的 `FunctionName` 非空檢查。RedirectToAction。 |

```csharp
// Controllers/StaffController.cs L415-424
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> CreateFunction(FunctionDto dto)
{
    if (ModelState.IsValid || !string.IsNullOrEmpty(dto.FunctionName))
    {
        await _permissionService.CreateFunctionAsync(dto);
    }
    return RedirectToAction(nameof(RoleFunctions));
}
```

#### 4.24 EditFunction [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/EditFunction` |
| **差異** | 接收 `FunctionDto`；更新功能資訊。RedirectToAction。 |

```csharp
// Controllers/StaffController.cs L426-435
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> EditFunction(FunctionDto dto)
{
    if (ModelState.IsValid) await _permissionService.UpdateFunctionAsync(dto);
    return RedirectToAction(nameof(RoleFunctions));
}
```

#### 4.25 DeleteFunction [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/DeleteFunction` |
| **差異** | **硬刪除**功能。RedirectToAction。 |

```csharp
// Controllers/StaffController.cs L437-443
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> DeleteFunction(int id)
{
    await _permissionService.DeleteFunctionAsync(id);
    return RedirectToAction(nameof(RoleFunctions));
}
```

#### 4.26 CreateRoleFunction [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/CreateRoleFunction` |
| **差異** | 接收 `RoleFunctionDto`；建立角色-功能映射。包含 `RoleId > 0 && FunctionId > 0` 前置檢查。RedirectToAction。 |

```csharp
// Controllers/StaffController.cs L445-454
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> CreateRoleFunction(RoleFunctionDto dto)
{
    if (dto.RoleId > 0 && dto.FunctionId > 0)
        await _permissionService.CreateRoleFunctionAsync(dto);
    return RedirectToAction(nameof(RoleFunctions));
}
```

#### 4.27 DeleteRoleFunction [POST]

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Staff/DeleteRoleFunction` |
| **差異** | **硬刪除**角色-功能映射。RedirectToAction。 |

```csharp
// Controllers/StaffController.cs L456-462
[HttpPost][ValidateAntiForgeryToken]
public async Task<IActionResult> DeleteRoleFunction(int id)
{
    await _permissionService.DeleteRoleFunctionAsync(id);
    return RedirectToAction(nameof(RoleFunctions));
}
```

### Action 總覽表

| # | Action 名稱 | HTTP 方法 | 回傳類型 | 使用 Service | 權限 |
|---|-----------|-----------|---------|-------------|------|
| 1 | Index | GET | View | UserService, InstructorService | [Authorize]+[Function] |
| 2 | GetStaffList | GET | PartialView | UserService | [Authorize]+[Function] |
| 3 | Invite | POST | JSON | UserService | [Authorize]+[Function]+AntiForgery |
| 4 | Edit [GET] | GET | PartialView | UserService | [Authorize]+[Function] |
| 5 | Edit [POST] | POST | JSON | UserService | [Authorize]+[Function]+AntiForgery |
| 6 | Delete | POST | JSON | UserService | [Authorize]+[Function]+AntiForgery |
| 7 | Activate [GET] | GET | View | UserService | **AllowAnonymous** |
| 8 | Activate [POST] | POST | View/Redirect | UserService | **AllowAnonymous**+AntiForgery |
| 9 | InstructorList | GET | View | InstructorService | [Authorize]+[Function] |
| 10 | GetInstructorList | GET | PartialView | InstructorService | [Authorize]+[Function] |
| 11 | CreateInstructor [GET] | GET | PartialView | InstructorService, UserService | [Authorize]+[Function] |
| 12 | CreateInstructor [POST] | POST | JSON | InstructorService | [Authorize]+[Function]+AntiForgery |
| 13 | EditInstructor [GET] | GET | PartialView | InstructorService | [Authorize]+[Function] |
| 14 | EditInstructor [POST] | POST | JSON | InstructorService | [Authorize]+[Function]+AntiForgery |
| 15 | DeleteInstructor | POST | JSON | InstructorService | [Authorize]+[Function]+AntiForgery |
| 16 | ToggleInstructorActive | POST | JSON | InstructorService | [Authorize]+[Function]+AntiForgery |
| 17 | RoleFunctions | GET | View | PermissionService | [Function("edit_RoleFunctions")] |
| 18 | EditRolePermission | GET | PartialView | PermissionService, UserService | [Authorize]+[Function] |
| 19 | UpdateRolePermissions | POST | JSON | PermissionService | [Authorize]+[Function]+AntiForgery |
| 20 | CreateRole | POST | Redirect | PermissionService | [Authorize]+[Function]+AntiForgery |
| 21 | EditRole | POST | Redirect | PermissionService | [Authorize]+[Function]+AntiForgery |
| 22 | DeleteRole | POST | Redirect | PermissionService | [Authorize]+[Function]+AntiForgery |
| 23 | CreateFunction | POST | Redirect | PermissionService | [Authorize]+[Function]+AntiForgery |
| 24 | EditFunction | POST | Redirect | PermissionService | [Authorize]+[Function]+AntiForgery |
| 25 | DeleteFunction | POST | Redirect | PermissionService | [Authorize]+[Function]+AntiForgery |
| 26 | CreateRoleFunction | POST | Redirect | PermissionService | [Authorize]+[Function]+AntiForgery |
| 27 | DeleteRoleFunction | POST | Redirect | PermissionService | [Authorize]+[Function]+AntiForgery |

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── StaffController.cs          (29 個 Action)
├── Services/
│   ├── UserService.cs              (含 IUserService 介面)
│   └── InstructorService.cs        (含 IInstructorService 介面)
├── Models/
│   ├── Services/
│   │   └── PermissionService.cs    (權限管理服務)
│   ├── EfModels/
│   │   ├── User.cs
│   │   ├── Role.cs
│   │   ├── UserRole.cs
│   │   ├── Function.cs
│   │   ├── RoleFunction.cs
│   │   ├── Instructor.cs
│   │   └── MyFitnessCoachDbContext.cs
│   ├── DTOs/
│   │   ├── StaffDto.cs             (StaffDto, StaffInviteDto, StaffUpdateDto, StaffActivateDto, StaffResultDto)
│   │   ├── InstructorDto.cs
│   │   ├── UserDto.cs
│   │   ├── RoleDto.cs
│   │   ├── FunctionDto.cs
│   │   ├── PermissionDtoExtensions.cs (RoleFunctionDto + 擴充方法)
│   │   └── Result.cs
│   ├── ViewModel/
│   │   └── StaffViewModels.cs      (StaffListItemViewModel, StaffInviteViewModel,
│   │                                StaffEditViewModel, StaffActivateViewModel,
│   │                                RolesFunctionViewModel, RoleFunctionMatrixRow,
│   │                                AddRoleFunctionViewModel)
│   ├── ViewModels/
│   │   └── PermissionViewModel.cs  (PermissionViewModel, RolePermissionRowViewModel,
│   │                                EditRolePermissionViewModel)
│   └── Infra/
│       └── FunctionAttribute.cs    (自訂權限過濾器)
├── Repositories/
│   ├── UserRepository.cs           (含 IUserRepository 介面)
│   ├── InstructorRepository.cs     (含 IInstructorRepository 介面)
│   ├── RoleRepository.cs           (含 IRoleRepository 介面)
│   ├── FunctionRepository.cs       (含 IFunctionRepository 介面)
│   └── RoleFunctionRepository.cs   (含 IRoleFunctionRepository 介面)
├── Views/
│   └── Staff/
│       ├── Index.cshtml                    (員工管理主頁)
│       ├── InstructorList.cshtml           (營養師列表主頁)
│       ├── RoleFunctions.cshtml            (權限管理主頁)
│       ├── Activate.cshtml                 (帳號啟用頁)
│       ├── ActivateError.cshtml            (啟用錯誤頁)
│       ├── _StaffListPartial.cshtml        (員工列表 Partial)
│       ├── _StaffListNoRolePartial.cshtml  (無角色員工列表 Partial)
│       ├── _EditStaffPartial.cshtml        (編輯員工 Partial)
│       ├── _InstructorListPartial.cshtml   (營養師列表 Partial)
│       ├── _InstructorCollapsiblePartial.cshtml (可摺疊營養師 Partial)
│       ├── _CreateInstructorPartial.cshtml  (新增營養師 Partial)
│       ├── _EditInstructorPartial.cshtml    (編輯營養師 Partial)
│       └── _EditRolePermissionPartial.cshtml (編輯角色權限 Partial)
└── Infra/
    └── FunctionAttribute.cs
```

### 5.2 Entity 關聯鏈

```
                    User (1)
                   / │ \
                  /  │  \
                 /   │   \
    (1:N)       /    │(1:1)\     (1:N)
               /     │      \
              ▼      │       ▼
        UserRole (N) │   Instructor (0..1)
            │        │       │
            │(N:1)   │       │ (1:N)
            ▼        │       ▼
         Role (1)    │    Shift (N)
            │        │    Review (N)
            │(1:N)   │    InstructorWallet (N)
            ▼        │
    RoleFunction (N) │
            │(N:1)   │
            ▼        │
       Function (1)  │
```

- **User → UserRole → Role**：使用者透過 UserRole 關聯表擁有多個角色（多對多）
- **Role → RoleFunction → Function**：角色透過 RoleFunction 關聯表擁有多個功能權限（多對多）
- **User → Instructor**：使用者可對應一個營養師身份（一對零或一）
- **Instructor → Shift/Review/InstructorWallet**：營養師擁有排班、評價、錢包等資料

---

## 六、重要概念總整理

### 6.1 類別層級的權限控制

`[Function("edit_UserAccounts")]` 標記在 **Controller 類別**（而非個別 Action），代表此 Controller 的所有 Action 預設都需要此權限。例外情況：
- `Activate` Action 標記了 `[AllowAnonymous]`，可不登入存取
- `RoleFunctions` Action 額外標記 `[Function("edit_RoleFunctions")]`，需要不同的功能權限

### 6.2 AJAX + Modal + PartialView 模式

StaffController 大量使用此設計模式（參考 `codeExplain/Staff.md`）：

1. **靜態 Modal**：邀請功能的表單預寫在 `Index.cshtml` 中
2. **動態 Modal**：編輯功能透過 AJAX `$.get('/Staff/Edit/' + id)` 載入 PartialView 至 Modal
3. **列表刷新**：操作完成後呼叫 `$.get('/Staff/GetStaffList')` 重新載入表格，不需整頁重載

### 6.3 邀請-啟用流程（Invitation-Activation Pattern）

新增員工不直接建立帳號密碼，而是：
1. 管理員填寫姓名、Email、角色 → 呼叫 `Invite`
2. 系統建立未確認的 User 紀錄（`IsConfirmed = false`），產生 GUID 啟用碼
3. 系統發送邀請郵件（含啟用連結 `/Staff/Activate?code=<guid>`）
4. 受邀者點擊連結 → 設定帳號密碼 → 呼叫 `Activate [POST]`
5. 系統雜湊密碼、確認帳號、導向登入頁

### 6.4 硬刪除策略

依據 `codeExplain/HardDelete.md` 的設計理念：
- **員工 Delete**：執行硬刪除（`_context.Users.Remove`），同步清除 UserRoles
- **營養師 DeleteInstructor**：執行硬刪除（`_context.Instructors.Remove`）
- **角色/功能 Delete**：執行硬刪除

注意：目前的硬刪除未設定 `DeleteBehavior.Cascade`，而是在 Repository 中手動刪除關聯資料。

### 6.5 全量替換策略（UpdateRolePermissions）

`PermissionService.UpdateRolePermissionsAsync` 更新角色權限時：
1. 刪除該角色的所有 RoleFunctions
2. 重新建立勾選的 RoleFunctions
3. 刪除該角色的所有 UserRoles
4. 重新建立勾選的 UserRoles

這是簡潔但可能有效能影響的策略（見優化建議）。

### 6.6 圖片上傳處理

營養師的圖片上傳邏輯（`CreateInstructor [POST]` / `EditInstructor [POST]`）：
- 使用 `Guid.NewGuid()` 產生唯一檔名，避免衝突
- 儲存至 `wwwroot/img/instructors/` 目錄
- `InstructorService.NormalizeImageUrl` 處理新舊路徑格式的相容性

### 6.7 RBAC（角色型存取控制）架構

系統實現了完整的 RBAC：
- **User** 擁有多個 **Role**（透過 UserRole）
- **Role** 擁有多個 **Function**（透過 RoleFunction）
- 登入時將 Function 寫入 Claims
- `FunctionAttribute` 在 Action 執行前檢查 Claims

### 6.8 兩套回傳策略並存

StaffController 中同時存在兩種回傳策略：
- **JSON 回傳**：員工管理和營養師管理的 CRUD 操作（用於 AJAX）
- **RedirectToAction 回傳**：角色和功能管理的 CRUD 操作（傳統表單提交）

---

## 七、完整資料流圖

### 7.1 員工邀請 → 帳號啟用流程

```
[管理員瀏覽器]
    │
    │ 1. 填寫邀請表單 → POST /Staff/Invite
    ▼
[StaffController.Invite]
    │ ModelState 驗證
    │ StaffInviteViewModel → StaffInviteDto
    ▼
[UserService.InviteStaffAsync]
    │ ① 檢查 Email 唯一性
    │ ② 建立 User (IsConfirmed=false, NewMemberConfirmCode=GUID)
    │ ③ 分配角色 (UserRoles)
    │ ④ 產生啟用連結
    │ ⑤ 發送邀請郵件
    ▼
[UserRepository.CreateUserAsync] + [EmailService.SendStaffInvitationEmail]
    │ INSERT INTO Users (...) / INSERT INTO UserRoles (...)
    ▼
JSON: { success: true, message: "邀請已送出" }
    │
    │ ─── 受邀者收到郵件 ───
    │
    │ 2. 點擊啟用連結 → GET /Staff/Activate?code=<guid>
    ▼
[StaffController.Activate GET] [AllowAnonymous]
    │ 驗證 code 有效性
    ▼
[Activate.cshtml] (設定帳號密碼表單)
    │
    │ 3. 填寫帳號密碼 → POST /Staff/Activate
    ▼
[StaffController.Activate POST] [AllowAnonymous]
    │ ① ModelState 驗證
    │ ② 帳號唯一性檢查
    │ ③ StaffActivateDto → UserService.ActivateAccountAsync
    ▼
[UserService.ActivateAccountAsync]
    │ ① 查找 User (by NewMemberConfirmCode)
    │ ② 檢查過期時間
    │ ③ 設定 Account, HashedPassword (PasswordHasher)
    │ ④ IsConfirmed = true, 清除 ConfirmCode
    ▼
[UserRepository.UpdateUserAsync] → SQL Server
    │
    ▼
RedirectToAction("Login", "Account") + TempData["LoginMessage"]
```

### 7.2 權限管理流程

```
[管理員瀏覽器]
    │
    │ 1. GET /Staff/RoleFunctions
    ▼
[Function("edit_RoleFunctions") 權限檢查]
    ▼
[StaffController.RoleFunctions]
    │ ① GetAllRolesAsync → RoleRepository → Roles 表
    │ ② GetAllFunctionsAsync → FunctionRepository → Functions 表
    │ ③ GetAllRoleFunctionsAsync → RoleFunctionRepository → RoleFunctions 表
    │ ④ GetRolePermissionRowsAsync → DbContext (Include 多層) → 權限矩陣
    ▼
[RoleFunctions.cshtml] (角色-功能矩陣頁面)
    │
    │ 2. 點擊編輯角色 → GET /Staff/EditRolePermission?roleId=1
    ▼
[StaffController.EditRolePermission]
    │ 載入角色資料 + 所有功能 + 所有員工
    ▼
[_EditRolePermissionPartial.cshtml] → 載入至 Modal
    │
    │ 3. 勾選功能/人員 → POST /Staff/UpdateRolePermissions
    ▼
[StaffController.UpdateRolePermissions]
    ▼
[PermissionService.UpdateRolePermissionsAsync]
    │ ① 清除既有 RoleFunctions
    │ ② 建立新 RoleFunctions
    │ ③ 清除既有 UserRoles (該角色的)
    │ ④ 建立新 UserRoles
    ▼
SQL Server (DELETE + INSERT)
    │
    ▼
JSON: { success: true, message: "權限更新成功" }
```

---

## 八、涉及的關鍵檔案清單

| 檔案路徑 | 類型 | 說明 |
|----------|------|------|
| `Controllers/StaffController.cs` | Controller | 員工管理控制器（29 個 Action） |
| `Services/UserService.cs` | Service | 使用者/員工 CRUD、角色/功能管理 |
| `Services/InstructorService.cs` | Service | 營養師 CRUD |
| `Models/Services/PermissionService.cs` | Service | 角色權限矩陣管理 |
| `Repositories/UserRepository.cs` | Repository | 使用者資料存取 |
| `Repositories/InstructorRepository.cs` | Repository | 營養師資料存取 |
| `Repositories/RoleRepository.cs` | Repository | 角色資料存取 |
| `Models/DTOs/StaffDto.cs` | DTO | 員工相關 DTO（5 個類別） |
| `Models/DTOs/InstructorDto.cs` | DTO | 營養師 DTO |
| `Models/DTOs/UserDto.cs` | DTO | 使用者 DTO |
| `Models/DTOs/RoleDto.cs` | DTO | 角色 DTO |
| `Models/DTOs/FunctionDto.cs` | DTO | 功能 DTO |
| `Models/DTOs/PermissionDtoExtensions.cs` | DTO + Extensions | RoleFunctionDto + 擴充方法 |
| `Models/ViewModel/StaffViewModels.cs` | ViewModel | 員工相關 ViewModel（7 個類別） |
| `Models/ViewModels/PermissionViewModel.cs` | ViewModel | 權限相關 ViewModel（3 個類別） |
| `Infra/FunctionAttribute.cs` | Filter | 自訂功能權限過濾器 |
| `Views/Staff/Index.cshtml` | View | 員工管理主頁 |
| `Views/Staff/InstructorList.cshtml` | View | 營養師列表主頁 |
| `Views/Staff/RoleFunctions.cshtml` | View | 權限管理主頁 |
| `Views/Staff/Activate.cshtml` | View | 帳號啟用頁 |
| `Views/Staff/ActivateError.cshtml` | View | 啟用錯誤頁 |
| `Views/Staff/_StaffListPartial.cshtml` | Partial View | 員工列表 |
| `Views/Staff/_EditStaffPartial.cshtml` | Partial View | 編輯員工表單 |
| `Views/Staff/_InstructorListPartial.cshtml` | Partial View | 營養師列表 |
| `Views/Staff/_CreateInstructorPartial.cshtml` | Partial View | 新增營養師表單 |
| `Views/Staff/_EditInstructorPartial.cshtml` | Partial View | 編輯營養師表單 |
| `Views/Staff/_EditRolePermissionPartial.cshtml` | Partial View | 編輯角色權限表單 |
| `Views/Staff/_StaffListNoRolePartial.cshtml` | Partial View | 無角色員工列表 |
| `Views/Staff/_InstructorCollapsiblePartial.cshtml` | Partial View | 可摺疊營養師 |
| `Program.cs` | 啟動設定 | DI 註冊與 Middleware 配置 |
| `codeExplain/Staff.md` | 參考文件 | AJAX + Modal 設計說明 |
| `codeExplain/HardDelete.md` | 參考文件 | 硬刪除與 Cascade Delete 說明 |

---

## 九、程式碼優化建議

### 9.1 Index Action 一次載入所有使用者效能問題

**問題**：`Index`（`Controllers/StaffController.cs` L166-202）呼叫 `_userService.GetStaffListAsync()` 載入所有使用者，然後在記憶體中進行角色分類（員工/營養師/會員），最後同一個 Action 還要再呼叫 `_instructorService.GetAllInstructorsAsync()` 取得營養師詳細資料。
**原因**：當使用者數量增長，一次載入所有使用者（含 Include UserRoles + Role）到記憶體，再做 LINQ 分類，會產生效能問題。
**建議**：將不同類型的使用者查詢拆分到 Repository 層，使用伺服器端篩選（SQL WHERE）而非記憶體篩選。例如建立 `GetStaffUsersAsync()`、`GetInstructorUsersAsync()`、`GetMemberUsersAsync()` 等專用查詢方法。

### 9.2 UserService.GetStaffListAsync 記憶體篩選

**問題**：`Services/UserService.cs` L57-88 中，先將所有使用者載入記憶體（`await _userRepository.GetAllUsersAsync()`），再用 `users.AsQueryable()` 做記憶體 LINQ 查詢。
**原因**：`GetAllUsersAsync` 回傳 `IEnumerable<User>`，後續的 `.Where()` 是在記憶體中執行（LINQ to Objects），而非在 SQL Server 端執行。
**建議**：將篩選條件傳入 Repository 層，在 `IQueryable` 階段（SQL 端）完成篩選：
```csharp
public async Task<IEnumerable<User>> GetFilteredUsersAsync(string? name, string? role, int? id)
{
    var query = _context.Users.Include(...).AsQueryable();
    if (!string.IsNullOrWhiteSpace(name))
        query = query.Where(u => u.UserName.Contains(name));
    // ... 其他篩選 ...
    return await query.ToListAsync();
}
```

### 9.3 PermissionService 直接注入 DbContext

**問題**：`PermissionService`（`Models/Services/PermissionService.cs` L15）直接注入了 `MyFitnessCoachDbContext`，同時又注入了多個 Repository。
**原因**：`GetRolePermissionRowsAsync`（L106-123）和 `UpdateRolePermissionsAsync`（L125-149）直接操作 `_context`，繞過了 Repository 層，違反了三層式架構的一致性。
**建議**：將這些操作封裝到對應的 Repository 中，移除 Service 對 DbContext 的直接依賴。

### 9.4 UpdateRolePermissionsAsync 全量替換策略

**問題**：`PermissionService.UpdateRolePermissionsAsync`（L125-149）使用「先全部刪除再全部新增」的策略更新 RoleFunctions 和 UserRoles。
**原因**：即使只變更了一筆資料，也會執行全量刪除+全量新增，產生不必要的 SQL 操作。當角色關聯大量使用者時，效能會顯著下降。
**建議**：改用差異比對策略，只新增/刪除實際變更的項目：
```csharp
var existingFuncIds = role.RoleFunctions.Select(rf => rf.FunctionId).ToHashSet();
var toAdd = functionIds.Where(id => !existingFuncIds.Contains(id));
var toRemove = role.RoleFunctions.Where(rf => !functionIds.Contains(rf.FunctionId));
```

### 9.5 CreateInstructor/EditInstructor 圖片處理重複程式碼

**問題**：`CreateInstructor [POST]`（L69-103）和 `EditInstructor [POST]`（L114-148）中的圖片上傳程式碼幾乎完全相同（產生檔名、建立目錄、複製檔案）。
**原因**：違反 DRY 原則，修改圖片處理邏輯時需同步修改兩處。
**建議**：將圖片上傳邏輯提取為 Controller 的私有方法：
```csharp
private async Task<string?> SaveInstructorImageAsync(IFormFile? imageFile)
{
    if (imageFile == null || imageFile.Length == 0) return null;
    var fileName = Guid.NewGuid().ToString() + Path.GetExtension(imageFile.FileName);
    var filePath = Path.Combine(_environment.WebRootPath, "img", "instructors", fileName);
    // ... 建立目錄、複製檔案 ...
    return "/img/instructors/" + fileName;
}
```

### 9.6 PermissionService 未使用介面注入

**問題**：`PermissionService` 在 `Program.cs` L42 以 `AddScoped<PermissionService>()` 註冊，Controller 直接注入具體類別。
**原因**：與 `ShiftService` 相同的問題，無法在單元測試中 Mock。
**建議**：建立 `IPermissionService` 介面。

### 9.7 CreateFunction 的 ModelState 驗證邏輯不一致

**問題**：`CreateFunction`（`Controllers/StaffController.cs` L417-424）使用 `if (ModelState.IsValid || !string.IsNullOrEmpty(dto.FunctionName))` 的條件判斷。
**原因**：`ModelState.IsValid` 與 `dto.FunctionName` 非空的 OR 條件，意味著即使 ModelState 無效，只要 FunctionName 有值就會建立功能。這可能允許其他必填欄位為空的資料進入系統。
**建議**：統一使用 `ModelState.IsValid` 作為唯一判斷條件，若 `FunctionName` 需要特殊處理，應在 DTO 上設定正確的驗證 Attribute。

### 9.8 硬刪除角色可能導致資料不一致

**問題**：`DeleteRole`（L407-413）直接硬刪除角色，但 `RoleRepository.DeleteAsync` 只刪除 Role 本身，未處理關聯的 UserRoles 和 RoleFunctions。
**原因**：若資料庫未設定 Cascade Delete，刪除角色時可能因外鍵約束而失敗，或留下孤兒紀錄。
**建議**：在刪除角色前，先清除關聯的 UserRoles 和 RoleFunctions，或確保資料庫層已設定 `ON DELETE CASCADE`。
