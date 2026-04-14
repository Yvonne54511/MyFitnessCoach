# NotificationController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

## 一、全局架構概覽

```
┌─────────────────────────────────────────────────────────────────────┐
│                       Browser / JavaScript (Client)                │
│              GET  /api/Notification                (取得所有通知)    │
│              GET  /api/Notification/unread-count   (取得未讀數量)    │
│              POST /api/Notification/mark-as-read/5 (標記已讀)       │
│              ※ 全部為 AJAX/Fetch API 呼叫，非傳統頁面導覽           │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ HTTP Request (JSON API)
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     ASP.NET Core Middleware Pipeline                │
│  ┌──────────────┐  ┌────────────────┐  ┌────────────────────────┐  │
│  │ ExceptionHandler│→│ StaticFiles    │→│ Routing                │  │
│  └──────────────┘  └────────────────┘  └────────────────────────┘  │
│  ┌──────────────┐  ┌────────────────┐  ┌────────────────────────┐  │
│  │ HTTPS Redirect │→│ Authentication │→│ Authorization          │  │
│  └──────────────┘  └────────────────┘  └────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ [Authorize] → Cookie 驗證 (透過 AJAX 請求帶 Cookie)          │  │
│  └──────────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ 路由匹配 (Attribute Routing)
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│               NotificationController (API Controller 層)            │
│               繼承: ControllerBase（非 Controller）                  │
│               DI 注入: NotificationService（具體類別，非介面）        │
│               [ApiController] + [Route("api/[controller]")]        │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ 呼叫 Service
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│               NotificationService (Service 層)                      │
│               DI 注入: INotificationRepository                      │
│               ※ 無介面，直接以具體類別註冊                            │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ 呼叫 Repository
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│               NotificationRepository (Repository 層)                │
│               DI 注入: MyFitnessCoachDbContext                      │
│               實作: INotificationRepository 介面                     │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ 操作 DbContext (全部使用 async)
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│               EF Core (MyFitnessCoachDbContext)                     │
│               DbSet<Notification>                                   │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ SQL 查詢
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        SQL Server                                   │
│               Table: Notifications, Users                           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊

```csharp
// Program.cs L80-82
// 註冊 Notification 模組
builder.Services.AddScoped<INotificationRepository, NotificationRepository>();  // L81
builder.Services.AddScoped<NotificationService>();                              // L82
```

另外，DbContext 的註冊：
```csharp
// Program.cs L24-25
builder.Services.AddDbContext<MyFitnessCoachDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
```

### 2.2 生命週期範圍

| 服務 | 生命週期 | 說明 |
|------|----------|------|
| `INotificationRepository` → `NotificationRepository` | **Scoped** | 每個 HTTP Request 建立一個實例 |
| `NotificationService`（具體類別） | **Scoped** | 每個 HTTP Request 建立一個實例 |
| `MyFitnessCoachDbContext` | **Scoped** | `AddDbContext` 預設為 Scoped |

> **重要差異：** `NotificationService` 是以**具體類別**註冊（`AddScoped<NotificationService>()`），而非透過介面。這意味著 Controller 直接依賴具體類別，而非介面抽象。

### 2.3 DI 注入鏈（由下往上）

```
SQL Server
    ↑
MyFitnessCoachDbContext              (Scoped, Program.cs L24-25)
    ↑
NotificationRepository               (Scoped, Program.cs L81)
    ↑ 實作 INotificationRepository
NotificationService                   (Scoped, Program.cs L82) ← 具體類別註冊
    ↑
NotificationController                (由 MVC 框架建立, 每個 Request 一個)
```

### 2.4 建構子程式碼

**Controller 建構子：**
```csharp
// NotificationController.cs L14-19
private readonly NotificationService _service;    // L14 ← 注意：依賴具體類別

public NotificationController(NotificationService service)  // L16
{
    _service = service;  // L18
}
```

**Service 建構子：**
```csharp
// NotificationService.cs L12-17
private readonly INotificationRepository _repo;

public NotificationService(INotificationRepository repo)  // L14
{
    _repo = repo;  // L16
}
```

**Repository 建構子：**
```csharp
// NotificationRepository.cs L19-24
private readonly MyFitnessCoachDbContext _db;

public NotificationRepository(MyFitnessCoachDbContext db)  // L21
{
    _db = db;  // L23
}
```

### 2.5 介面與實作對照表

| 介面 | 實作類別 | 檔案位置 |
|------|----------|----------|
| **無介面** | `NotificationService` | `Services/NotificationService.cs` |
| `INotificationRepository` | `NotificationRepository` | `Repositories/NotificationRepository.cs` |
| (無介面，直接注入) | `MyFitnessCoachDbContext` | `Models/EfModels/MyFitnessCoachDbContext.cs` |

---

## 三、完整 Request 生命週期（以 GetNotifications Action 為例）

### 步驟 1：HTTP Request

```
前端 JavaScript 透過 Fetch API 或 AJAX 發出請求：
GET https://localhost/api/Notification

Request Headers:
  - Cookie: MyFitnessCoach.Auth=<加密Token>  ← Cookie 認證（自動帶入）
  - Accept: application/json
  - X-Requested-With: XMLHttpRequest  (若使用 jQuery AJAX)
```

### 步驟 2：Middleware Pipeline

請求依序經過以下 Middleware（Program.cs L131-187）：

```
1. ExceptionHandler        (L136/L142) → 捕捉未處理例外
2. StatusCodePages         (L145)      → HTTP 狀態碼頁面
3. HttpsRedirection        (L147)      → 確保 HTTPS
4. StaticFiles             (L149-176)  → 非靜態檔案，跳過
5. Routing                 (L178)      → 使用 Attribute Routing 匹配
6. Authentication          (L180)      → 解析 Cookie，建立 ClaimsPrincipal
7. Authorization           (L181)      → 檢查 [Authorize]
```

### 步驟 3：路由匹配

此 Controller 使用 **Attribute Routing**（非傳統路由）：
```csharp
// NotificationController.cs L10-11
[Route("api/[controller]")]    // → api/Notification
[ApiController]
```

URL `/api/Notification` 匹配：
- **Controller**: `NotificationController`
- **Action**: `GetNotifications` (因為是 `[HttpGet]` 且無額外路由模板)

### 步驟 4：DI 容器建立物件鏈

```
1. 建立 MyFitnessCoachDbContext       (若此 Request 尚未建立)
2. 建立 NotificationRepository        (注入 DbContext)
3. 建立 NotificationService           (注入 Repository)
4. 建立 NotificationController        (注入 Service)
```

在進入 Controller 之前，`[Authorize]` 確認使用者已登入（Cookie 驗證通過），否則回傳 401 Unauthorized。

### 步驟 5：Controller Action 執行

```csharp
// NotificationController.cs L22-33
[HttpGet]
public async Task<IActionResult> GetNotifications()
{
    var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;  // L25
    if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))  // L26
    {
        return Unauthorized();  // L28 → 若無法取得 UserId，回傳 401
    }

    var notifications = await _service.GetUserNotificationsAsync(userId);  // L31
    return Ok(notifications);  // L32 → 回傳 JSON
}
```

關鍵步驟：
1. 從 `User.Claims` 中取得 `ClaimTypes.NameIdentifier`（UserId）
2. 解析為 `int` 型別
3. 呼叫 Service 取得通知列表
4. 以 `Ok()` 回傳 JSON

### 步驟 6：Service 層商業邏輯

```csharp
// NotificationService.cs L66-69
public async Task<List<Notification>> GetUserNotificationsAsync(int userId)
{
    return await _repo.GetByUserIdAsync(userId);  // L68 → 委派給 Repository
}
```

> `NotificationService` 也有 `SendAsync()` 方法（L19-64），提供了通知類型判斷、標題自動設定、URL 附加等商業邏輯。此方法由其他 Controller/Service 呼叫以發送通知。

### 步驟 7：Repository 層資料存取

```csharp
// NotificationRepository.cs L32-38
public async Task<List<Notification>> GetByUserIdAsync(int userId)
{
    return await _db.Notifications
        .Where(n => n.UserId == userId)             // L35 → 篩選該使用者的通知
        .OrderByDescending(n => n.CreatedAt)         // L36 → 依建立時間降序排列
        .ToListAsync();                              // L37 → 非同步執行查詢
}
```

### 步驟 8：EF Core → SQL Server

EF Core 產生的 SQL 大致如下：

```sql
SELECT n.[Id], n.[UserId], n.[SenderId], n.[NotifyType], n.[Title],
       n.[Content], n.[IsRead], n.[ReferenceId], n.[CreatedAt]
FROM [Notifications] AS n
WHERE n.[UserId] = @userId
ORDER BY n.[CreatedAt] DESC
```

### 步驟 9：JSON 回傳

因為此 Controller 繼承 `ControllerBase`（API Controller），不渲染 View，而是回傳 JSON：

```csharp
return Ok(notifications);  // 自動序列化為 JSON
```

回傳範例：
```json
[
  {
    "id": 1,
    "userId": 5,
    "senderId": null,
    "notifyType": "System",
    "title": "系統通知",
    "content": "歡迎使用 MyFitnessCoach",
    "isRead": false,
    "referenceId": null,
    "createdAt": "2025-03-15T10:30:00"
  }
]
```

### 步驟 10：HTTP Response

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

[{"id":1,"userId":5,...}]
```

### 步驟 11：Scoped 物件 Dispose

```
Request 處理完畢後，DI 容器依序 Dispose Scoped 物件：
1. NotificationController       → Dispose
2. NotificationService          → Dispose
3. NotificationRepository       → Dispose
4. MyFitnessCoachDbContext      → Dispose（關閉資料庫連線，歸還至連線池）
```

---

## 四、其他 Action 生命週期

### 4.1 GetUnreadCount - 取得未讀通知數量

```csharp
// NotificationController.cs L36-47
[HttpGet("unread-count")]
public async Task<IActionResult> GetUnreadCount()
```

| 差異點 | 說明 |
|--------|------|
| 路由 | `GET /api/Notification/unread-count`（附加路由段 `"unread-count"`） |
| Claim 解析 | 同 `GetNotifications`，從 Claims 取得 UserId (L39-43) |
| Service 方法 | 呼叫 `_service.GetUnreadCountAsync(userId)` (L45) |
| Repository 方法 | `GetUnreadCountAsync()` 使用 `CountAsync(n => n.UserId == userId && !n.IsRead)` (Repository L50-54) |
| 回傳格式 | `Ok(new { count })` → JSON `{ "count": 3 }` (L46) |
| SQL 差異 | `SELECT COUNT(*) FROM Notifications WHERE UserId = @p AND IsRead = 0` |
| 效能 | 僅回傳一個整數，比 `GetNotifications` 更輕量 |

### 4.2 MarkAsRead - 標記通知為已讀

```csharp
// NotificationController.cs L49-55
[HttpPost("mark-as-read/{id}")]
public async Task<IActionResult> MarkAsRead(int id)
```

| 差異點 | 說明 |
|--------|------|
| HTTP 方法 | **POST**（寫入操作） |
| 路由 | `POST /api/Notification/mark-as-read/{id}` |
| 路由參數 | 接收 `id` — 通知的 ID |
| 無 UserId 檢查 | **未驗證** 該通知是否屬於當前使用者（安全問題） |
| Service 方法 | 呼叫 `_service.MarkAsReadAsync(id)` (L53) |
| Repository 方法 | `MarkAsReadAsync()` 使用 `FindAsync(id)` 找到通知後設定 `IsRead = true`，再 `SaveChangesAsync()` (Repository L40-48) |
| 回傳格式 | `Ok()` → HTTP 200（無 Body） |
| SQL 差異 | 先 `SELECT` 後 `UPDATE SET IsRead = 1 WHERE Id = @id` |

### 4.3 SendAsync - 發送通知（由其他模組呼叫）

```csharp
// NotificationService.cs L19-64
public async Task SendAsync(int receiverId, int? senderId, NotifyType type, string message, string url = null)
```

| 差異點 | 說明 |
|--------|------|
| 呼叫方式 | 不透過 Controller，由其他 Service 直接呼叫 |
| 商業邏輯 | 根據 `NotifyType` 列舉自動設定 Title（L24-44） |
| URL 處理 | 若有 URL，附加至 Content 末尾 `[Url:xxx]` (L47-49) |
| Entity 建立 | 直接建立 `Notification` Entity（L52-61） |
| Repository 方法 | 呼叫 `_repo.CreateAsync()` → `Add()` + `SaveChangesAsync()` (Repository L26-30) |

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── NotificationController.cs             ← API Controller 層
├── Services/
│   └── NotificationService.cs                ← Service 層（無介面）
├── Repositories/
│   └── NotificationRepository.cs             ← Repository 層（含 INotificationRepository 介面）
├── Models/
│   ├── EfModels/
│   │   ├── Notification.cs                   ← Entity 實體
│   │   ├── User.cs                           ← 關聯 Entity（接收者與發送者）
│   │   └── MyFitnessCoachDbContext.cs        ← EF Core DbContext
│   └── Enums/
│       └── NotifyType.cs                     ← 通知類型列舉
└── (無 Views 目錄，因為是純 API Controller)
```

### 5.2 Entity 關聯鏈

```
User (使用者 - 接收者)
  │ PK: Id
  │ Properties: UserName, Email, ...
  │
  └──── Notification (通知，N:1 with User)
          │ PK: Id
          │ FK: UserId → User.Id          ← 接收者
          │ FK: SenderId → User.Id (可 null) ← 發送者
          │ Properties: NotifyType, Title, Content, IsRead, ReferenceId, CreatedAt
          │
          └──── User (使用者 - 發送者, 可 null)
                  透過 Sender 導覽屬性

NotifyType 列舉值：
  ├── Report1  → "評論檢舉通知"
  ├── Booking  → "預約成功通知"
  ├── System   → "系統通知"
  ├── Alert    → "緊急提醒"
  └── Salary   → "薪資入帳通知"
```

關聯說明：
- `User` ↔ `Notification`：一對多（一個 User 可以有多筆通知）
- `Notification.UserId`：接收者（必填）
- `Notification.SenderId`：發送者（可 null，系統通知時為 null）
- `Notification` 有兩個 `User` 導覽屬性：`User`（接收者）和 `Sender`（發送者）

---

## 六、重要概念總整理

### 6.1 API Controller vs MVC Controller

`NotificationController` 繼承自 **`ControllerBase`**（而非 `Controller`），並標記了 `[ApiController]`：

```csharp
// NotificationController.cs L11-12
[ApiController]
public class NotificationController : ControllerBase
```

與傳統 MVC Controller 的差異：
| 特性 | API Controller (ControllerBase) | MVC Controller (Controller) |
|------|-------------------------------|---------------------------|
| View 支援 | 無 | 有 |
| 回傳格式 | JSON（自動序列化） | HTML（Razor View） |
| Model Binding | 自動 `[FromBody]` 推斷 | 自動 `[FromForm]` 推斷 |
| ModelState 驗證 | 自動回傳 400 BadRequest | 需手動檢查 `ModelState.IsValid` |
| 路由方式 | Attribute Routing（必須） | 可用傳統路由 |

### 6.2 Attribute Routing

```csharp
[Route("api/[controller]")]  // 基礎路由: /api/Notification
```

各 Action 的路由：
| Action | HTTP 方法 | 路由模板 | 完整路徑 |
|--------|----------|---------|---------|
| `GetNotifications` | GET | (無) | `/api/Notification` |
| `GetUnreadCount` | GET | `"unread-count"` | `/api/Notification/unread-count` |
| `MarkAsRead` | POST | `"mark-as-read/{id}"` | `/api/Notification/mark-as-read/5` |

### 6.3 非同步 (async/await) 程式設計模式

此模組全面使用 `async/await` 非同步模式：
- Controller Action：`async Task<IActionResult>`
- Service 方法：`async Task<T>` 或 `async Task`
- Repository 方法：使用 `ToListAsync()`、`FindAsync()`、`CountAsync()`、`SaveChangesAsync()`

好處：
- 不阻塞執行緒，提高伺服器吞吐量
- 適合 I/O 密集操作（資料庫查詢）
- ASP.NET Core 執行緒池可更有效率地處理併發請求

### 6.4 Claims-Based Identity

```csharp
var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
```

此模組從 Cookie Authentication 建立的 `ClaimsPrincipal` 中取得使用者 ID：
- `ClaimTypes.NameIdentifier` 儲存使用者的數字 ID
- 在登入時由 `AccountController` 寫入 Claims
- Cookie Authentication 設定於 Program.cs L119-129

### 6.5 NotifyType 列舉與字串儲存

`NotifyType` 定義為 C# 列舉（`Models/Enums/NotifyType.cs`），但在資料庫中以**字串**儲存：

```csharp
// NotificationService.cs L22
string typeName = type.ToString();  // 列舉轉字串

// Notification Entity
public string NotifyType { get; set; }  // 資料庫欄位為 string
```

### 6.6 Service 層以具體類別註冊

```csharp
builder.Services.AddScoped<NotificationService>();  // L82
```

與其他模組（如 MemberViolation）使用介面註冊不同，`NotificationService` 直接以具體類別註冊。Controller 也直接依賴具體類別而非介面。

---

## 七、完整資料流圖

### 7.1 GetNotifications（取得使用者所有通知）

```
Browser (JS)            Controller              Service               Repository            EF Core / DB
  │                        │                       │                      │                     │
  │── GET /api/Notification→│                       │                      │                     │
  │   Cookie: Auth=xxx     │                       │                      │                     │
  │                        │── User.FindFirst() ──→│ ClaimsPrincipal      │                     │
  │                        │   (取得 UserId)        │                      │                     │
  │                        │                       │                      │                     │
  │                        │── GetUserNotifications │                      │                     │
  │                        │   Async(userId) ─────→│                      │                     │
  │                        │                       │── GetByUserIdAsync ──→│                     │
  │                        │                       │   (userId)            │── LINQ Query ──────→│
  │                        │                       │                      │                     │── SELECT *
  │                        │                       │                      │                     │   FROM Notifications
  │                        │                       │                      │                     │   WHERE UserId=@p
  │                        │                       │                      │                     │   ORDER BY CreatedAt DESC
  │                        │                       │                      │←── List<Entity> ────│
  │                        │                       │←── List<Notification>─│                     │
  │                        │←── List<Notification> │                      │                     │
  │                        │── Ok(notifications) ──→│ JSON 序列化          │                     │
  │←── JSON Response ──────│                       │                      │                     │
```

### 7.2 MarkAsRead（標記通知為已讀）

```
Browser (JS)            Controller              Service               Repository            EF Core / DB
  │                        │                       │                      │                     │
  │── POST mark-as-read/5 →│                       │                      │                     │
  │                        │── MarkAsReadAsync(5) ─→│                      │                     │
  │                        │                       │── MarkAsReadAsync(5)→│                     │
  │                        │                       │                      │── FindAsync(5) ────→│
  │                        │                       │                      │                     │── SELECT ... WHERE Id=5
  │                        │                       │                      │←── Notification ────│
  │                        │                       │                      │── IsRead = true ───→│
  │                        │                       │                      │── SaveChangesAsync →│
  │                        │                       │                      │                     │── UPDATE SET IsRead=1
  │                        │                       │←── void ─────────────│                     │
  │                        │←── void ──────────────│                      │                     │
  │←── 200 OK ─────────────│                       │                      │                     │
```

### 7.3 SendAsync（其他模組呼叫發送通知）

```
其他 Service             NotificationService     Repository            EF Core / DB
  │                        │                      │                     │
  │── SendAsync(           │                      │                     │
  │     receiverId,        │                      │                     │
  │     senderId,          │                      │                     │
  │     NotifyType.Booking,│                      │                     │
  │     "預約成功",         │                      │                     │
  │     "/Reservation/5")  │                      │                     │
  │                        │── switch(type) ─────→│ 決定 Title           │
  │                        │── 組合 Content ─────→│ message + [Url:xxx]  │
  │                        │── new Notification ──→│                     │
  │                        │── CreateAsync() ─────→│                     │
  │                        │                      │── Add() ────────────→│
  │                        │                      │── SaveChangesAsync →│
  │                        │                      │                     │── INSERT INTO ...
  │                        │←── void ─────────────│                     │
  │←── void ───────────────│                      │                     │
```

---

## 八、涉及的關鍵檔案清單

| 檔案 | 類型 | 說明 |
|------|------|------|
| `Controllers/NotificationController.cs` | API Controller | 處理 HTTP API 請求，回傳 JSON |
| `Services/NotificationService.cs` | Service | 通知商業邏輯（發送、查詢、標記已讀） |
| `Repositories/NotificationRepository.cs` | Repository + Interface | 資料存取層（含 `INotificationRepository` 介面定義） |
| `Models/EfModels/Notification.cs` | Entity | EF Core 實體模型，對應 `Notifications` 資料表 |
| `Models/EfModels/User.cs` | Entity | 使用者實體（接收者與發送者） |
| `Models/Enums/NotifyType.cs` | Enum | 通知類型列舉（Report1, Booking, System, Alert, Salary） |
| `Program.cs` | 啟動設定 | DI 註冊（L81-82）與 Cookie Authentication 設定（L119-129） |
| (無 Views) | — | 此為 API Controller，不使用 Razor View |
| (無 DTO) | — | 直接回傳 Entity，未使用 DTO 層 |
| (無 ViewModel) | — | API Controller 不使用 ViewModel |

---

## 九、程式碼優化建議

### 9.1 MarkAsRead 缺少使用者權限驗證

**問題：**
```csharp
// NotificationController.cs L50-55
[HttpPost("mark-as-read/{id}")]
public async Task<IActionResult> MarkAsRead(int id)
{
    await _service.MarkAsReadAsync(id);  // 直接標記，未檢查通知歸屬
    return Ok();
}
```

**原因：** 任何已登入使用者只要知道通知 ID，就可以將其他使用者的通知標記為已讀。這是一個**水平越權 (IDOR)** 漏洞。

**建議改法：**
```csharp
[HttpPost("mark-as-read/{id}")]
public async Task<IActionResult> MarkAsRead(int id)
{
    var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
        return Unauthorized();

    var success = await _service.MarkAsReadAsync(id, userId);  // 加入 userId 參數
    if (!success) return NotFound();
    return Ok();
}
```
同時修改 Service 和 Repository，在 `MarkAsReadAsync` 中加入 `UserId` 條件驗證。

### 9.2 API Controller 直接回傳 Entity

**問題：**
```csharp
// NotificationController.cs L31-32
var notifications = await _service.GetUserNotificationsAsync(userId);
return Ok(notifications);  // 直接回傳 Notification Entity
```

**原因：** 直接回傳 EF Core Entity 會暴露所有欄位（包括 `SenderId`、`ReferenceId` 等可能不需要前端看到的欄位），且若 Entity 有循環參照的導覽屬性（如 `User` → `Notifications` → `User`），JSON 序列化可能發生循環引用錯誤。

**建議改法：** 建立 `NotificationDto` 回傳前端需要的欄位：
```csharp
public class NotificationDto
{
    public int Id { get; set; }
    public string Title { get; set; }
    public string Content { get; set; }
    public string NotifyType { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
}
```

### 9.3 NotificationService 未透過介面註冊

**問題：**
```csharp
// Program.cs L82
builder.Services.AddScoped<NotificationService>();  // 具體類別註冊
```

```csharp
// NotificationController.cs L14
private readonly NotificationService _service;  // 依賴具體類別
```

**原因：** 違反**依賴反轉原則 (DIP)**。Controller 直接依賴具體類別，不利於單元測試（無法 Mock），也不符合專案中其他模組的一致風格。

**建議改法：** 新增 `INotificationService` 介面：
```csharp
// Program.cs
builder.Services.AddScoped<INotificationService, NotificationService>();

// Controller
private readonly INotificationService _service;
```

### 9.4 SendAsync 中 URL 的附加方式不夠結構化

**問題：**
```csharp
// NotificationService.cs L47-49
if (!string.IsNullOrEmpty(url))
{
    finalContent += $" [Url:{url}]";
}
```

**原因：** 將 URL 直接拼接在 Content 字串末尾，前端需要用正規表達式解析才能取出 URL。既不直觀也容易出錯。

**建議改法：** `Notification` Entity 已有 `ReferenceId` 欄位，可考慮新增一個 `Url` 欄位，或直接利用現有欄位儲存 URL，讓資料結構更清晰：
```csharp
var notification = new Notification
{
    UserId = receiverId,
    SenderId = senderId,
    Title = title,
    Content = message,        // 純文字訊息
    NotifyType = typeName,
    IsRead = false,
    CreatedAt = DateTime.Now
    // 未來可新增: Url = url
};
```

### 9.5 NotifyType 列舉與字串不匹配的潛在問題

**問題：**
```csharp
// NotifyType.cs
public enum NotifyType { Report1, Booking, System, Alert, Salary }

// NotificationService.cs L22
string typeName = type.ToString();  // → "Report1", "Booking" 等

// Notification.cs
public string NotifyType { get; set; }  // 資料庫儲存字串
```

**原因：** Entity 中 `NotifyType` 是 `string` 類型，但 Service 中使用 C# 列舉的 `ToString()` 產生字串。若未來列舉名稱變更（如重新命名 `Report1`），已存在資料庫中的舊字串將無法對應。

**建議改法：** 考慮在列舉上使用 `[Description]` 屬性或自訂映射字典來定義資料庫中的穩定字串值，而非直接使用列舉名稱。
