# ReviewController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

---

## 一、全局架構概覽

```
┌─────────────┐
│   Browser   │
│ (HTTP Request)│
└──────┬──────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│                  Middleware Pipeline                       │
│  UseHttpsRedirection → UseStaticFiles → UseRouting       │
│  → UseAuthentication → UseAuthorization → Endpoint       │
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────┐
│              ReviewController  [Authorize]                │
│  DI 注入:                                                 │
│    └── ReviewService                                      │
│         ├── IReviewRepository (ReviewRepository)          │
│         ├── NotificationService                           │
│         │    └── INotificationRepository                  │
│         └── MyFitnessCoachDbContext                       │
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────┐
│           ReviewRepository / DbContext                    │
│           (EF Core → SQL Server)                         │
└──────────────────────────────────────────────────────────┘
```

### 該 Controller 的 DI 注入對象
| 注入對象 | 類型 | 說明 |
|---------|------|------|
| `ReviewService` | 具象類別（直接注入） | 評論業務邏輯服務 |

`ReviewService` 內部再注入：
- `IReviewRepository` → `ReviewRepository`（資料存取層）
- `NotificationService` → 通知服務（檢舉時通知管理員）
- `MyFitnessCoachDbContext` → EF Core DbContext（直接查詢 KeyWords、Notifications 等）

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊

```csharp
// Program.cs L77-78
builder.Services.AddScoped<IReviewRepository, ReviewRepository>();  // L77
builder.Services.AddScoped<ReviewService>();                         // L78

// 相依的 Notification 模組 (L81-82)
builder.Services.AddScoped<INotificationRepository, NotificationRepository>();  // L81
builder.Services.AddScoped<NotificationService>();                               // L82

// DbContext (L24-25)
builder.Services.AddDbContext<MyFitnessCoachDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Cookie 認證 (L119-129)
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options => { ... });
```

### 2.2 生命週期範圍

| 服務 | 生命週期 | 說明 |
|------|---------|------|
| `ReviewService` | **Scoped** | 每個 HTTP Request 建立一個實例 |
| `IReviewRepository` / `ReviewRepository` | **Scoped** | 每個 HTTP Request 建立一個實例 |
| `NotificationService` | **Scoped** | 每個 HTTP Request 建立一個實例 |
| `INotificationRepository` / `NotificationRepository` | **Scoped** | 每個 HTTP Request 建立一個實例 |
| `MyFitnessCoachDbContext` | **Scoped** | `AddDbContext` 預設為 Scoped |

### 2.3 DI 注入鏈（由下往上）

```
SQL Server (資料庫)
    ↑
MyFitnessCoachDbContext (EF Core DbContext) ──── Scoped
    ↑                    ↑
ReviewRepository         NotificationRepository ── Scoped
(實作 IReviewRepository)  (實作 INotificationRepository)
    ↑                    ↑
    │              NotificationService ──────────── Scoped
    │                    ↑
    └────────────────────┤
                         │
                   ReviewService ────────────────── Scoped
                         ↑
                  ReviewController
```

### 2.4 建構子程式碼

**ReviewController（L15-18）：**
```csharp
// Controllers/ReviewController.cs L15-18
public ReviewController(ReviewService service)
{
    _service = service;
}
```

**ReviewService（L19-24）：**
```csharp
// Services/ReviewService.cs L19-24
public ReviewService(IReviewRepository repo, NotificationService notificationService, MyFitnessCoachDbContext db)
{
    _repo = repo;
    _notificationService = notificationService;
    _db = db;
}
```

**ReviewRepository（L25-28）：**
```csharp
// Repositories/ReviewRepository.cs L25-28
public ReviewRepository(MyFitnessCoachDbContext db)
{
    _db = db;
}
```

### 2.5 介面與實作對照表

| 介面 | 實作類別 | 檔案位置 |
|------|---------|---------|
| `IReviewRepository` | `ReviewRepository` | `Repositories/ReviewRepository.cs` |
| `INotificationRepository` | `NotificationRepository` | `Repositories/NotificationRepository.cs` |
| （無介面，直接注入） | `ReviewService` | `Services/ReviewService.cs` |
| （無介面，直接注入） | `NotificationService` | `Services/NotificationService.cs` |

---

## 三、完整 Request 生命週期（以 `AdminIndex` Action 為例）

### 步驟 1：HTTP Request

```
GET /Review/AdminIndex HTTP/1.1
Host: localhost
Cookie: MyFitnessCoach.Auth=<加密的認證 Cookie>
```

使用者（管理員）透過瀏覽器發送 GET 請求至 `/Review/AdminIndex`，Cookie 中攜帶認證資訊。

### 步驟 2：Middleware Pipeline

```
HTTP Request
    │
    ▼
UseHttpsRedirection()     ← 將 HTTP 重導向至 HTTPS
    │
    ▼
UseStaticFiles()          ← 檢查是否為靜態檔案（非靜態檔案繼續往下）
    │
    ▼
UseRouting()              ← 路由比對（確定 endpoint）
    │
    ▼
UseAuthentication()       ← 從 Cookie 解析 ClaimsPrincipal
    │                        Cookie Name: "MyFitnessCoach.Auth"
    ▼
UseAuthorization()        ← 執行 [Authorize] 與 [Function] 過濾器
    │
    ▼
Endpoint Execution        ← 進入 Controller Action
```

**認證細節（Program.cs L119-129）：**
- Cookie 名稱：`MyFitnessCoach.Auth`
- 登入路徑：`/Account/Login`
- 拒絕存取路徑：`/Home/Error/403`
- HttpOnly：`true`
- SameSite：`Lax`
- SecurePolicy：`Always`

### 步驟 3：路由匹配

```csharp
// Program.cs L185-187
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Account}/{action=Login}/{id?}");
```

路由解析結果：
- `controller` = `Review`
- `action` = `AdminIndex`
- `id` = null

### 步驟 4：DI 容器建立物件鏈

當路由確定後，MVC Framework 需要實例化 `ReviewController`，DI 容器按照以下順序建立物件：

```
1. MyFitnessCoachDbContext     ← 已存在於 Scope 中則重用
2. ReviewRepository            ← new ReviewRepository(dbContext)
3. NotificationRepository      ← new NotificationRepository(dbContext)
4. NotificationService         ← new NotificationService(notificationRepo)
5. ReviewService               ← new ReviewService(reviewRepo, notificationService, dbContext)
6. ReviewController            ← new ReviewController(reviewService)
```

所有 Scoped 物件共用同一個 `MyFitnessCoachDbContext` 實例。

### 步驟 5：Controller Action 執行

在進入 Action 之前，先執行授權過濾器：

**1. `[Authorize]`（類別層級，L10）：** 確認使用者已登入
**2. `[Function("edit_Comments_admin")]`（L28）：** 自訂授權過濾器

```csharp
// Infra/FunctionAttribute.cs L20-38
public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
{
    // 檢查使用者是否有 "edit_Comments_admin" 的 Function Claim
    var userFunctions = context.HttpContext.User.FindAll("Function")
                             .Select(c => c.Value);
    if (!userFunctions.Contains(FunctionName))
    {
        context.Result = new ForbidResult(); // 無權限 → 403
    }
}
```

**通過授權後，執行 Action（L29-33）：**
```csharp
// Controllers/ReviewController.cs L29-33
[Authorize]
[Function("edit_Comments_admin")]
public async Task<IActionResult> AdminIndex()
{
    var dtos = await _service.GetAdminReviewsAsync();
    return View(dtos);
}
```

### 步驟 6：Service 層商業邏輯

```csharp
// Services/ReviewService.cs L26-82
public async Task<IEnumerable<ReviewDto>> GetAdminReviewsAsync()
{
    // 1. 取得所有評論（透過 Repository）
    var entities = (await _repo.GetAllReviewsAsync()).ToList();                    // L28

    // 2. 取得敏感詞清單（直接查 DbContext）
    var sensitiveWords = await _db.KeyWords                                        // L29
        .Where(k => k.Category == -1).Select(s => s.Word).ToListAsync();

    // 3. 取得檢舉通知（直接查 DbContext）
    var reports = await _db.Notifications                                          // L32-36
        .Where(n => n.NotifyType == "Report1")
        .Select(n => new { n.NotifyType, n.Content, n.CreatedAt })
        .OrderBy(n => n.CreatedAt)
        .ToListAsync();

    // 4. 組裝 DTO：敏感詞遮罩、檢舉訊息解析
    return entities.Select(e => {                                                  // L38-81
        // 解析檢舉訊息（移除 URL 部分）
        // 敏感詞替換為 <span> 標籤（可點擊顯示/隱藏）
        // 組裝 ReviewDto
        return new ReviewDto { ... };
    });
}
```

**關鍵商業邏輯：**
- 敏感詞遮罩：將 `KeyWords` 表中 `Category == -1` 的敏感詞替換為 `***` 的 HTML span
- 檢舉訊息：從 `Notifications` 表中 `NotifyType == "Report1"` 的記錄中提取檢舉原因
- 停權狀態：從 `MemberViolation` 關聯取得 `IsSuspended` 和 `WarningCount`

### 步驟 7：Repository 層資料存取

```csharp
// Repositories/ReviewRepository.cs L30-38
public async Task<IEnumerable<Review>> GetAllReviewsAsync()
{
    return await _db.Reviews
        .Include(r => r.Instructor).ThenInclude(i => i.User)       // 載入教練→使用者
        .Include(r => r.Member).ThenInclude(m => m.User)           // 載入會員→使用者
        .Include(r => r.Member).ThenInclude(m => m.MemberViolation) // 載入會員→違規紀錄
        .OrderByDescending(r => r.CreatedAt)                        // 依建立時間倒序
        .ToListAsync();
}
```

### 步驟 8：EF Core → SQL Server

EF Core 將 LINQ 查詢轉譯為 SQL，大致如下：

```sql
SELECT r.*, i.*, u1.*, m.*, u2.*, mv.*
FROM Reviews r
LEFT JOIN Instructors i ON r.InstructorId = i.Id
LEFT JOIN Users u1 ON i.UserId = u1.Id
LEFT JOIN Members m ON r.MemberId = m.Id
LEFT JOIN Users u2 ON m.UserId = u2.Id
LEFT JOIN MemberViolations mv ON m.Id = mv.MemberId
ORDER BY r.CreatedAt DESC
```

另外還有兩個額外查詢：
- `SELECT Word FROM KeyWords WHERE Category = -1`（敏感詞）
- `SELECT NotifyType, Content, CreatedAt FROM Notifications WHERE NotifyType = 'Report1' ORDER BY CreatedAt`（檢舉通知）

### 步驟 9：View 渲染

```
Controller 回傳: View(dtos)
    │
    ▼
Razor 引擎載入: Views/Review/AdminIndex.cshtml
    │
    ▼
@model IEnumerable<ReviewDto>
    │
    ▼
渲染 HTML：
  - DataTables 表格（評論列表）
  - 敏感詞遮罩（可點擊切換顯示）
  - 封鎖按鈕、停權按鈕
  - MicroModal 彈窗（停權原因輸入）
  - Notyf 通知（操作成功/警告）
    │
    ▼
完整 HTML Response
```

### 步驟 10：HTTP Response

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Set-Cookie: MyFitnessCoach.Auth=<...>; path=/; secure; httponly; samesite=lax

<!DOCTYPE html>
<html>... 渲染後的完整 HTML ...</html>
```

### 步驟 11：Scoped 物件 Dispose

```
Response 發送完畢後，DI Scope 結束：
    │
    ▼
ReviewController.Dispose()
    │
    ▼
ReviewService (Scoped, 生命週期結束)
    │
    ▼
ReviewRepository (Scoped, 生命週期結束)
    │
    ▼
NotificationService (Scoped, 生命週期結束)
    │
    ▼
MyFitnessCoachDbContext.Dispose()
  → 關閉 SQL Server 連線（歸還至連線池）
  → 釋放 Change Tracker 中的所有追蹤物件
```

---

## 四、其他 Action 生命週期

### 4.1 `Index()` (L20-25)
```csharp
public IActionResult Index()
{
    if (User.IsInRole("Admin")) return RedirectToAction(nameof(AdminIndex));
    if (User.IsInRole("Instructor")) return RedirectToAction(nameof(InstructorIndex));
    return Forbid();
}
```
- **差異點：** 不呼叫 Service，根據角色做 302 重導向；同步方法（非 async）
- **授權：** 僅需 `[Authorize]`（類別層級），無額外 `[Function]` 過濾器
- **回傳類型：** `RedirectToActionResult` 或 `ForbidResult`（非 ViewResult）

### 4.2 `InstructorIndex()` (L37-47)
```csharp
[Function("edit_Comments_instructor")]
public async Task<IActionResult> InstructorIndex()
{
    var instructorIdClaim = User.FindFirst("InstructorId")?.Value;
    if (string.IsNullOrEmpty(instructorIdClaim) || !int.TryParse(instructorIdClaim, out int instructorId))
        return Forbid();

    var dtos = await _service.GetInstructorReviewsAsync(instructorId);
    return View(dtos);
}
```
- **差異點：** 使用 `[Function("edit_Comments_instructor")]` 而非 `edit_Comments_admin`
- **額外邏輯：** 從 `ClaimsPrincipal` 中讀取 `InstructorId` Claim
- **Service 方法：** 呼叫 `GetInstructorReviewsAsync(instructorId)` — 僅查詢該教練的評論
- **View：** `Views/Review/InstructorIndex.cshtml`（與 AdminIndex 不同的 View）
- **Repository 查詢差異：** 使用 `GetReviewsByInstructorIdAsync(instructorId)` 加上 `Where(r => r.InstructorId == instructorId)`

### 4.3 `BanReview(int id)` (L53-64) — POST
```csharp
[HttpPost]
[Function("edit_Comments_admin")]
[ValidateAntiForgeryToken]
public async Task<IActionResult> BanReview(int id)
{
    var (newCount, isSuspended) = await _service.BanReviewAsync(id);
    TempData["SuccessMessage"] = "評論已成功封鎖。";
    if (newCount >= 5 && !isSuspended)
        TempData["StrongWarning"] = $"該學員違規次數已達 {newCount} 次，建議立即進行停權處理！";
    return RedirectToAction(nameof(AdminIndex));
}
```
- **差異點：** HTTP POST + `[ValidateAntiForgeryToken]`（防 CSRF）
- **Service 方法：** `BanReviewAsync(id)` — 封鎖評論 + 增加違規計數
- **回傳類型：** `RedirectToActionResult`（PRG 模式）
- **連鎖效果：** `ReviewRepository.BanReviewAsync` → 設定 `IsBanned = true`；`IncrementMemberWarningCountAsync` → 增加 `WarningCount`

### 4.4 `SuspendMember(int memberId, string reason)` (L69-74) — POST
```csharp
[HttpPost]
[Function("edit_Comments_admin")]
[ValidateAntiForgeryToken]
public async Task<IActionResult> SuspendMember(int memberId, string reason)
{
    await _service.SuspendMemberAsync(memberId, reason);
    TempData["SuccessMessage"] = "學員帳號已停權。";
    return RedirectToAction(nameof(AdminIndex));
}
```
- **差異點：** 接收 `memberId` 和 `reason` 兩個參數
- **Repository 邏輯：** 更新 `MemberViolation` 表的 `IsSuspended`、`SuspendedAt`、`Reason`
- **無檢查回傳值：** 不判斷停權是否成功

### 4.5 `ReportReview(int id, string reason)` (L80-91) — POST
```csharp
[HttpPost]
[Function("edit_Comments_instructor")]
[ValidateAntiForgeryToken]
public async Task<IActionResult> ReportReview(int id, string reason)
{
    var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int instructorUserId))
        return Forbid();

    await _service.ReportReviewAsync(id, instructorUserId, reason);
    TempData["SuccessMessage"] = "評論已舉報，管理員將會收到通知。";
    return RedirectToAction(nameof(InstructorIndex));
}
```
- **差異點：** 使用 `[Function("edit_Comments_instructor")]`，限教練使用
- **額外邏輯：** 從 `ClaimTypes.NameIdentifier` 取得使用者 ID（非 InstructorId）
- **Service 邏輯：** `ReportReviewAsync` → 查詢所有管理員 userId → 對每個管理員發送 `NotifyType.Report1` 通知
- **跨服務呼叫：** `ReviewService` → `NotificationService.SendAsync()`

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── ReviewController.cs
├── Services/
│   ├── ReviewService.cs
│   └── NotificationService.cs
├── Repositories/
│   ├── ReviewRepository.cs          (含 IReviewRepository 介面)
│   └── NotificationRepository.cs    (含 INotificationRepository 介面)
├── Models/
│   ├── EfModels/
│   │   ├── Review.cs                (Entity)
│   │   ├── Member.cs
│   │   ├── Instructor.cs
│   │   ├── User.cs
│   │   ├── MemberViolation.cs
│   │   ├── KeyWord.cs
│   │   ├── Notification.cs
│   │   └── MyFitnessCoachDbContext.cs
│   ├── DTOs/
│   │   └── ReviewDto.cs
│   └── Enums/
│       └── NotifyType.cs
├── Infra/
│   └── FunctionAttribute.cs
└── Views/
    └── Review/
        ├── AdminIndex.cshtml
        └── InstructorIndex.cshtml
```

### 5.2 Entity 關聯鏈

```
Review (評論)
├── InstructorId → Instructor (教練)
│                    └── UserId → User (使用者帳號)
├── MemberId → Member (會員)
│                ├── UserId → User (使用者帳號)
│                └── MemberViolation (違規紀錄, 1:1)
│                     ├── WarningCount
│                     ├── IsSuspended
│                     └── Reason
└── ReserveOrderId → ReserveOrder (預約訂單)

KeyWord (敏感詞)
└── Category = -1 → 用於評論遮罩

Notification (通知)
└── NotifyType = "Report1" → 教練檢舉評論的通知
```

---

## 六、重要概念總整理

### 6.1 自訂授權過濾器 `[Function]`
- 實作 `IAsyncAuthorizationFilter`，在 Action 執行前檢查 Cookie Claims 中是否包含指定的 Function 名稱
- `edit_Comments_admin`：管理員專用的評論管理權限
- `edit_Comments_instructor`：教練專用的評論檢視/舉報權限
- 若無權限，直接回傳 `ForbidResult`（HTTP 403）

### 6.2 敏感詞遮罩機制
- 從 `KeyWords` 表讀取 `Category == -1` 的敏感詞
- 使用 `String.Replace()` 將敏感詞替換為可互動的 HTML `<span>` 標籤
- 前端可點擊切換顯示/隱藏原始內容

### 6.3 PRG（Post-Redirect-Get）模式
- 所有 POST Action（`BanReview`、`SuspendMember`、`ReportReview`）都使用 `RedirectToAction` 回傳
- 搭配 `TempData` 傳遞成功/警告訊息至重導向後的頁面
- 防止使用者重新整理瀏覽器時重複提交表單

### 6.4 違規計數與停權連動
- `BanReview` 封鎖評論時，自動增加該會員的 `WarningCount`
- 當 `WarningCount >= 5` 且尚未停權時，透過 `TempData["StrongWarning"]` 提醒管理員
- `SuspendMember` 則為管理員手動停權的操作

### 6.5 跨模組通知（檢舉機制）
- 教練呼叫 `ReportReview` → `ReviewService.ReportReviewAsync`
- 查詢所有 `admin` 角色的 `UserId`
- 對每個管理員發送 `NotifyType.Report1` 類型的通知
- 通知內容包含檢舉原因和連結 URL

### 6.6 `[ValidateAntiForgeryToken]`
- 所有 POST Action 都使用此屬性防止 CSRF 攻擊
- View 中的表單需包含 `@Html.AntiForgeryToken()` 或使用 `asp-antiforgery="true"`

---

## 七、完整資料流圖

### 7.1 AdminIndex 資料流

```
[Browser]
    │ GET /Review/AdminIndex
    ▼
[Middleware] ── Cookie 認證 → ClaimsPrincipal
    │
    ▼
[FunctionAttribute] ── 檢查 "edit_Comments_admin" Claim
    │ (通過)
    ▼
[ReviewController.AdminIndex()]
    │
    ▼
[ReviewService.GetAdminReviewsAsync()]
    │
    ├──→ [ReviewRepository.GetAllReviewsAsync()]
    │         │
    │         ▼
    │    [DbContext] ──→ SELECT Reviews + JOINs ──→ [SQL Server]
    │         │
    │         ▼
    │    List<Review> (含 Instructor.User, Member.User, MemberViolation)
    │
    ├──→ [DbContext.KeyWords] ──→ SELECT Word WHERE Category=-1 ──→ [SQL Server]
    │         │
    │         ▼
    │    List<string> sensitiveWords
    │
    ├──→ [DbContext.Notifications] ──→ SELECT WHERE NotifyType='Report1' ──→ [SQL Server]
    │         │
    │         ▼
    │    List<{NotifyType, Content, CreatedAt}> reports
    │
    ▼
[組裝 IEnumerable<ReviewDto>]
    ├── 敏感詞遮罩 (String.Replace)
    ├── 檢舉訊息解析 (移除 URL)
    └── 組裝完整 DTO
    │
    ▼
[View: AdminIndex.cshtml]
    │ @model IEnumerable<ReviewDto>
    ▼
[HTML Response] → Browser 渲染 DataTables 表格
```

### 7.2 BanReview 資料流

```
[Browser]
    │ POST /Review/BanReview  (id=5, __RequestVerificationToken=...)
    ▼
[Middleware] ── Cookie 認證 + CSRF Token 驗證
    │
    ▼
[ReviewController.BanReview(5)]
    │
    ▼
[ReviewService.BanReviewAsync(5)]
    │
    ├──→ [ReviewRepository.GetReviewByIdAsync(5)]
    │         ▼
    │    Review entity (取得 MemberId)
    │
    ├──→ [ReviewRepository.BanReviewAsync(5)]
    │         ▼
    │    UPDATE Reviews SET IsBanned=1 WHERE Id=5
    │
    └──→ [ReviewRepository.IncrementMemberWarningCountAsync(memberId, "惡意評論被管理員封鎖")]
              ▼
         INSERT/UPDATE MemberViolations (WarningCount++)
    │
    ▼
[回傳 (newCount, isSuspended)]
    │
    ▼
[TempData 設定訊息] → RedirectToAction("AdminIndex")
    │
    ▼
[HTTP 302] → Browser 重新 GET /Review/AdminIndex
```

---

## 八、涉及的關鍵檔案清單

| 檔案 | 路徑 | 說明 |
|------|------|------|
| ReviewController.cs | `Controllers/ReviewController.cs` | 控制器，5 個 Action |
| ReviewService.cs | `Services/ReviewService.cs` | 業務邏輯層 |
| ReviewRepository.cs | `Repositories/ReviewRepository.cs` | 資料存取層（含 IReviewRepository 介面） |
| NotificationService.cs | `Services/NotificationService.cs` | 通知服務 |
| NotificationRepository.cs | `Repositories/NotificationRepository.cs` | 通知資料存取層 |
| Review.cs | `Models/EfModels/Review.cs` | EF Core Entity |
| MemberViolation.cs | `Models/EfModels/MemberViolation.cs` | EF Core Entity（違規紀錄） |
| ReviewDto.cs | `Models/DTOs/ReviewDto.cs` | 資料傳輸物件 |
| NotifyType.cs | `Models/Enums/NotifyType.cs` | 通知類型列舉 |
| FunctionAttribute.cs | `Infra/FunctionAttribute.cs` | 自訂功能授權過濾器 |
| AdminIndex.cshtml | `Views/Review/AdminIndex.cshtml` | 管理員評論管理頁面 |
| InstructorIndex.cshtml | `Views/Review/InstructorIndex.cshtml` | 教練評論檢視頁面 |
| Program.cs | `Program.cs` | DI 註冊與 Middleware 設定 |
| MyFitnessCoachDbContext.cs | `Models/EfModels/MyFitnessCoachDbContext.cs` | EF Core DbContext |

---

## 九、程式碼優化建議

### 9.1 ReviewService 中直接使用 DbContext 查詢

**問題：** `ReviewService` 同時注入了 `IReviewRepository` 和 `MyFitnessCoachDbContext`，在 `GetAdminReviewsAsync()` 中直接查詢 `_db.KeyWords` 和 `_db.Notifications`（L29, L32-36），繞過了 Repository 層。

**原因：** 這破壞了三層式架構的一致性。Service 層應只透過 Repository 存取資料，否則當需要更換資料來源或進行單元測試時，無法透過 Mock Repository 來隔離這些查詢。

**建議改法：**
- 將敏感詞查詢移至 `IKeyWordRepository`（已有 `IKeyWordRepository` 註冊於 L89）
- 將檢舉通知查詢移至 `INotificationRepository` 新增方法

### 9.2 敏感詞遮罩產生 HTML 於 Service 層

**問題：** `ReviewService` 的 `GetAdminReviewsAsync()` 和 `GetInstructorReviewsAsync()` 中，直接在 Service 層組裝 HTML `<span>` 標籤（L59, L96）。

**原因：** Service 層不應包含 HTML 呈現邏輯，這違反了關注點分離原則。若未來需要支援 API（JSON 回傳），這些 HTML 標籤將造成困擾。

**建議改法：**
- Service 層僅回傳原始評論和敏感詞清單
- 在 View 層或前端 JavaScript 中處理敏感詞遮罩的 HTML 組裝

### 9.3 BanReview 缺少操作結果驗證

**問題：** `ReviewController.BanReview()` (L53-64) 呼叫 `_service.BanReviewAsync(id)` 後，不論回傳的 `newCount` 是否為 0（代表找不到該評論），都設定 `TempData["SuccessMessage"]`。

**原因：** 如果傳入不存在的 `id`，`BanReviewAsync` 回傳 `(0, false)` 但 Controller 仍顯示「評論已成功封鎖」的訊息，造成使用者誤解。

**建議改法：**
```csharp
var (newCount, isSuspended) = await _service.BanReviewAsync(id);
if (newCount == 0)
{
    TempData["ErrorMessage"] = "找不到該評論，封鎖操作未執行。";
}
else
{
    TempData["SuccessMessage"] = "評論已成功封鎖。";
    // ... 警告邏輯
}
```

### 9.4 SuspendMember 缺少結果檢查

**問題：** `SuspendMember()` (L69-74) 呼叫 `_service.SuspendMemberAsync(memberId, reason)` 為 `void` 方法，無法得知操作是否成功。

**原因：** 如果 `memberId` 不存在，`ReviewRepository.SuspendMemberAsync` 會靜默失敗（L79-109），但 Controller 仍顯示「學員帳號已停權」。

**建議改法：**
- `SuspendMemberAsync` 改為回傳 `bool` 或 `Result`
- Controller 根據結果設定不同的 TempData 訊息

### 9.5 敏感詞遮罩邏輯重複

**問題：** `GetAdminReviewsAsync()` (L54-62) 和 `GetInstructorReviewsAsync()` (L91-99) 中的敏感詞遮罩邏輯完全相同，存在程式碼重複。

**原因：** 若需修改遮罩邏輯（例如改變 HTML 結構），需要同時修改兩處。

**建議改法：** 抽取為私有方法：
```csharp
private string MaskSensitiveWords(string comment, List<string> sensitiveWords)
{
    // 共用遮罩邏輯
}
```
