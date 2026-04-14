# MemberViolationController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

## 一、全局架構概覽

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Browser (Client)                          │
│              GET /MemberViolation/Index                             │
│              POST /MemberViolation/Create                           │
│              POST /MemberViolation/Edit                             │
│              POST /MemberViolation/Delete                           │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ HTTP Request
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
│  │ [Authorize] + [Function("edit_MemberViolations")]            │  │
│  │ → Cookie 驗證 + FunctionAttribute 權限檢查                    │  │
│  └──────────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ 路由匹配
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│               MemberViolationController (Controller 層)             │
│               DI 注入: IMemberViolationService                      │
│               [Authorize] + [Function("edit_MemberViolations")]     │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ 呼叫 Service
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│               MemberViolationService (Service 層)                   │
│               DI 注入: IMemberViolationRepository                   │
│               實作: IMemberViolationService 介面                     │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ 呼叫 Repository
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│               MemberViolationRepository (Repository 層)             │
│               DI 注入: MyFitnessCoachDbContext                      │
│               實作: IMemberViolationRepository 介面                  │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ 操作 DbContext
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│               EF Core (MyFitnessCoachDbContext)                     │
│               DbSet<MemberViolation>                                │
│               DbSet<Member>                                         │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ SQL 查詢
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        SQL Server                                   │
│               Table: MemberViolations, Members, Users               │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊

```csharp
// Program.cs L92-94
// 註冊 MemberViolation 模組
builder.Services.AddScoped<IMemberViolationRepository, MemberViolationRepository>();  // L93
builder.Services.AddScoped<IMemberViolationService, MemberViolationService>();        // L94
```

另外，DbContext 也是透過 DI 註冊的：
```csharp
// Program.cs L24-25
builder.Services.AddDbContext<MyFitnessCoachDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
```

### 2.2 生命週期範圍

| 服務 | 生命週期 | 說明 |
|------|----------|------|
| `IMemberViolationRepository` → `MemberViolationRepository` | **Scoped** | 每個 HTTP Request 建立一個實例，Request 結束後 Dispose |
| `IMemberViolationService` → `MemberViolationService` | **Scoped** | 每個 HTTP Request 建立一個實例，Request 結束後 Dispose |
| `MyFitnessCoachDbContext` | **Scoped** | `AddDbContext` 預設為 Scoped，確保同一 Request 共用同一個 DbContext |

### 2.3 DI 注入鏈（由下往上）

```
SQL Server
    ↑
MyFitnessCoachDbContext          (Scoped, Program.cs L24-25)
    ↑
MemberViolationRepository       (Scoped, Program.cs L93)
    ↑ 實作 IMemberViolationRepository
MemberViolationService           (Scoped, Program.cs L94)
    ↑ 實作 IMemberViolationService
MemberViolationController        (由 MVC 框架建立, 每個 Request 一個)
```

### 2.4 建構子程式碼

**Controller 建構子：**
```csharp
// MemberViolationController.cs L16-21
private readonly IMemberViolationService _service;

public MemberViolationController(IMemberViolationService service)  // L18
{
    _service = service;  // L20
}
```

**Service 建構子：**
```csharp
// MemberViolationService.cs L20-25
private readonly IMemberViolationRepository _repository;

public MemberViolationService(IMemberViolationRepository repository)  // L22
{
    _repository = repository;  // L24
}
```

**Repository 建構子：**
```csharp
// MemberViolationRepository.cs L21-26
private readonly MyFitnessCoachDbContext _context;

public MemberViolationRepository(MyFitnessCoachDbContext context)  // L23
{
    _context = context;  // L25
}
```

### 2.5 介面與實作對照表

| 介面 | 實作類別 | 檔案位置 |
|------|----------|----------|
| `IMemberViolationService` | `MemberViolationService` | `Services/MemberViolationService.cs` |
| `IMemberViolationRepository` | `MemberViolationRepository` | `Repositories/MemberViolationRepository.cs` |
| (無介面，直接注入) | `MyFitnessCoachDbContext` | `Models/EfModels/MyFitnessCoachDbContext.cs` |

---

## 三、完整 Request 生命週期（以 Index Action 為例）

### 步驟 1：HTTP Request

```
使用者在瀏覽器輸入或點擊連結：
GET https://localhost/MemberViolation/Index

Request Headers:
  - Cookie: MyFitnessCoach.Auth=<加密Token>  ← Cookie 認證
  - Accept: text/html
```

### 步驟 2：Middleware Pipeline

請求依序經過以下 Middleware（Program.cs L131-187）：

```
1. ExceptionHandler        (L136/L142) → 捕捉未處理例外，導向 /Home/Error
2. StatusCodePages         (L145)      → 處理 HTTP 狀態碼頁面（如 403、404）
3. HttpsRedirection        (L147)      → 確保使用 HTTPS
4. StaticFiles             (L149-176)  → 檢查是否為靜態檔案（不是，繼續）
5. Routing                 (L178)      → 解析 URL，匹配路由規則
6. Authentication          (L180)      → 驗證 Cookie，建立 ClaimsPrincipal
7. Authorization           (L181)      → 檢查 [Authorize] 與 [Function] 授權
```

### 步驟 3：路由匹配

```csharp
// Program.cs L185-187
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Account}/{action=Login}/{id?}");
```

URL `/MemberViolation/Index` 匹配：
- **Controller**: `MemberViolation` → `MemberViolationController`
- **Action**: `Index`
- **id**: null

### 步驟 4：DI 容器建立物件鏈

MVC 框架偵測到 `MemberViolationController` 建構子需要 `IMemberViolationService`，啟動 DI 解析：

```
1. 建立 MyFitnessCoachDbContext      (若此 Request 尚未建立)
2. 建立 MemberViolationRepository    (注入 DbContext)
3. 建立 MemberViolationService       (注入 Repository)
4. 建立 MemberViolationController    (注入 Service)
```

同時，在進入 Controller 之前，`[Authorize]` 屬性確認使用者已登入，`[Function("edit_MemberViolations")]` 屬性（FunctionAttribute）檢查使用者的 Claims 中是否包含 `Function = "edit_MemberViolations"`，若無則回傳 403 Forbid。

### 步驟 5：Controller Action 執行

```csharp
// MemberViolationController.cs L23-38
public IActionResult Index()
{
    var dtos = _service.GetAll();                          // L25 → 呼叫 Service 層
    var viewModels = dtos.Select(d => new MemberViolationIndexViewModel
    {
        Id = d.Id,                                          // L28
        MemberName = d.MemberName,                          // L29
        MemberEmail = d.MemberEmail,                        // L30
        WarningCount = d.WarningCount,                      // L31
        IsSuspended = d.IsSuspended,                        // L32
        LastWarningAt = d.LastWarningAt,                     // L33
        SuspendedAt = d.SuspendedAt,                        // L34
        Reason = d.Reason                                   // L35
    }).ToList();

    return View(viewModels);                                // L38 → 回傳 View
}
```

### 步驟 6：Service 層商業邏輯

```csharp
// MemberViolationService.cs L27-30
public List<MemberViolationDto> GetAll()
{
    return _repository.GetAll();  // L29 → 直接委派給 Repository
}
```

> 注意：此 Service 層目前為「薄服務層」(Thin Service Layer)，僅進行委派，未包含額外商業邏輯。

### 步驟 7：Repository 層資料存取

```csharp
// MemberViolationRepository.cs L28-35
public List<MemberViolationDto> GetAll()
{
    return _context.MemberViolations                        // L30 → 查詢 MemberViolations 資料表
        .Include(mv => mv.Member)                           // L31 → Eager Loading: 載入 Member
        .ThenInclude(m => m.User)                           // L32 → Eager Loading: 載入 User
        .Select(mv => mv.ToDto())                           // L33 → 使用擴充方法轉換為 DTO
        .ToList();                                          // L34 → 執行查詢並轉為 List
}
```

其中 `ToDto()` 擴充方法定義於：
```csharp
// MemberViolationExtensions.cs L9-25
public static MemberViolationDto ToDto(this MemberViolation entity)
{
    if (entity == null) return null;
    return new MemberViolationDto
    {
        Id = entity.Id,                                       // L15
        MemberId = entity.MemberId,                           // L16
        MemberName = entity.Member?.User?.UserName ?? "Unknown",  // L17
        MemberEmail = entity.Member?.User?.Email ?? "Unknown",    // L18
        WarningCount = entity.WarningCount,                   // L19
        IsSuspended = entity.IsSuspended,                     // L20
        LastWarningAt = entity.LastWarningAt,                 // L21
        SuspendedAt = entity.SuspendedAt,                     // L22
        Reason = entity.Reason                                // L23
    };
}
```

### 步驟 8：EF Core → SQL Server

EF Core 產生的 SQL 大致如下：

```sql
SELECT mv.[Id], mv.[MemberId], mv.[WarningCount], mv.[IsSuspended],
       mv.[LastWarningAt], mv.[SuspendedAt], mv.[Reason],
       m.[Id], m.[UserId], u.[Id], u.[UserName], u.[Email]
FROM [MemberViolations] AS mv
INNER JOIN [Members] AS m ON mv.[MemberId] = m.[Id]
INNER JOIN [Users] AS u ON m.[UserId] = u.[Id]
```

### 步驟 9：View 渲染

Controller 回傳 `View(viewModels)` 後，Razor 引擎渲染 `Views/MemberViolation/Index.cshtml`：

```
View 檔案: Views/MemberViolation/Index.cshtml
Model 型別: IEnumerable<MemberViolationIndexViewModel>

渲染內容：
1. 頁面標題「會員違規管理」
2. 「新增違規紀錄」按鈕（連結到 Create Action）
3. 違規紀錄資料表（顯示會員姓名、帳號、警告次數、停權狀態等）
4. 每筆資料的「編輯」與「刪除」按鈕
5. 刪除確認 Modal 對話框（使用 jQuery + Bootstrap Modal）
```

### 步驟 10：HTTP Response

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

回傳完整渲染後的 HTML 頁面
```

### 步驟 11：Scoped 物件 Dispose

```
Request 處理完畢後，DI 容器依序 Dispose Scoped 物件：
1. MemberViolationController    → Dispose
2. MemberViolationService       → Dispose
3. MemberViolationRepository    → Dispose
4. MyFitnessCoachDbContext      → Dispose（關閉資料庫連線，歸還至連線池）
```

---

## 四、其他 Action 生命週期

### 4.1 Create (GET) - 新增違規頁面

```csharp
// MemberViolationController.cs L41-51
public IActionResult Create()
```

| 差異點 | 說明 |
|--------|------|
| Service 方法 | 呼叫 `_service.GetMembersAvailableForViolation()` (L43) 取得尚無違規紀錄的會員清單 |
| Repository 方法 | 呼叫 `GetMembersWithoutViolations()` (MemberViolationRepository.cs L82-90)，使用 `.Where(m => !violationMemberIds.Contains(m.Id))` 過濾 |
| ViewBag | 設定 `ViewBag.Members`（L44-48），提供下拉選單資料源 |
| View | 渲染 `Views/MemberViolation/Create.cshtml`，包含表單與下拉選單 |
| SQL 差異 | 需要額外查詢 `Members` 表，排除已有違規紀錄的會員 |

### 4.2 Create (POST) - 新增違規提交

```csharp
// MemberViolationController.cs L53-81
[HttpPost]
[ValidateAntiForgeryToken]
public IActionResult Create(MemberViolationCreateEditViewModel viewModel)
```

| 差異點 | 說明 |
|--------|------|
| HTTP 方法 | POST（非 GET） |
| 防偽驗證 | `[ValidateAntiForgeryToken]` 驗證 Anti-Forgery Token (L54) |
| Model Binding | ASP.NET Core 自動將表單資料綁定至 `MemberViolationCreateEditViewModel` |
| ModelState 驗證 | 檢查 `ModelState.IsValid` (L57)，驗證 `[Required]`、`[Range]`、`[StringLength]` 等 |
| DTO 轉換 | ViewModel → DTO 手動映射 (L59-67) |
| Service 方法 | 呼叫 `_service.Create(dto)` (L69) |
| Repository 方法 | `Create()` 方法使用 `dto.ToEntity()` 轉換後，`_context.MemberViolations.Add()` + `SaveChanges()` (Repository L46-51) |
| 成功回應 | `RedirectToAction(nameof(Index))` → HTTP 302 重導向 (L70) |
| 失敗回應 | 重新載入會員下拉選單，回傳 View 顯示驗證錯誤 (L73-80) |

### 4.3 Edit (GET) - 編輯違規頁面

```csharp
// MemberViolationController.cs L83-101
public IActionResult Edit(int id)
```

| 差異點 | 說明 |
|--------|------|
| 路由參數 | 接收 `id` 參數 |
| Service 方法 | 呼叫 `_service.GetById(id)` (L85) |
| Repository 方法 | `GetById()` 使用 `.FirstOrDefault(mv => mv.Id == id)` 搭配 Include (Repository L37-44) |
| 找不到處理 | 若 `dto == null` 回傳 `NotFound()` → HTTP 404 (L86) |
| DTO → ViewModel | 手動映射 DTO 至 `MemberViolationCreateEditViewModel` (L88-98) |
| View | 渲染 `Views/MemberViolation/Edit.cshtml`，會員姓名欄位為 disabled |

### 4.4 Edit (POST) - 編輯違規提交

```csharp
// MemberViolationController.cs L103-132
[HttpPost]
[ValidateAntiForgeryToken]
public IActionResult Edit(MemberViolationCreateEditViewModel viewModel)
```

| 差異點 | 說明 |
|--------|------|
| Repository 方法 | `Update()` 方法先 `FirstOrDefault` 找到 Entity，再手動更新欄位後 `SaveChanges()` (Repository L53-69) |
| 失敗處理 | 若驗證失敗，重新查詢 `GetById` 取得 `MemberName` 以供 View 顯示 (L125-129) |

### 4.5 Delete (POST) - 刪除違規紀錄

```csharp
// MemberViolationController.cs L134-139
[HttpPost]
public IActionResult Delete(int id)
```

| 差異點 | 說明 |
|--------|------|
| HTTP 方法 | POST（透過 Modal 表單提交） |
| 無 Anti-Forgery | 注意：此 Action 未加 `[ValidateAntiForgeryToken]` |
| Service 方法 | 呼叫 `_service.Delete(id)` (L137) |
| Repository 方法 | `Delete()` 使用 `_context.MemberViolations.Find(id)` + `Remove()` + `SaveChanges()` (Repository L72-80) |
| 回應 | 直接 `RedirectToAction(nameof(Index))` → HTTP 302 (L138) |

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── MemberViolationController.cs          ← Controller 層
├── Services/
│   └── MemberViolationService.cs             ← Service 層（含 IMemberViolationService 介面）
├── Repositories/
│   └── MemberViolationRepository.cs          ← Repository 層（含 IMemberViolationRepository 介面）
├── Models/
│   ├── EfModels/
│   │   ├── MemberViolation.cs                ← Entity 實體
│   │   ├── Member.cs                         ← 關聯 Entity
│   │   ├── User.cs                           ← 關聯 Entity
│   │   └── MyFitnessCoachDbContext.cs        ← EF Core DbContext
│   ├── DTOs/
│   │   ├── MemberViolationDto.cs             ← 資料傳輸物件
│   │   └── MemberViolationExtensions.cs      ← Entity ↔ DTO 轉換擴充方法
│   ├── ViewModels/
│   │   └── MemberViolationViewModel.cs       ← 包含 Index 與 CreateEdit 兩個 ViewModel
│   └── Infra/
│       └── FunctionAttribute.cs              ← 自訂授權過濾器
├── Views/
│   └── MemberViolation/
│       ├── Index.cshtml                      ← 列表頁面
│       ├── Create.cshtml                     ← 新增頁面
│       └── Edit.cshtml                       ← 編輯頁面
└── Infra/
    └── FunctionAttribute.cs                  ← 自訂權限 Attribute
```

### 5.2 Entity 關聯鏈

```
User (使用者)
  │ PK: Id
  │ Properties: UserName, Email, ...
  │
  └──── Member (會員，1:1 with User)
          │ PK: Id
          │ FK: UserId → User.Id
          │
          └──── MemberViolation (違規紀錄，1:1 with Member)
                  PK: Id
                  FK: MemberId → Member.Id
                  Properties: WarningCount, IsSuspended, LastWarningAt, SuspendedAt, Reason
```

關聯說明：
- `User` ↔ `Member`：一對一（一個 User 可以是一個 Member）
- `Member` ↔ `MemberViolation`：一對一（一個 Member 最多一筆違規紀錄，參見 `Member.cs` L38: `public virtual MemberViolation MemberViolation { get; set; }`）

---

## 六、重要概念總整理

### 6.1 FunctionAttribute 自訂權限授權

`MemberViolationController` 使用了 `[Function("edit_MemberViolations")]`（Controller L13），這是一個自訂的授權過濾器，定義於 `Infra/FunctionAttribute.cs`：

- 繼承自 `AuthorizeAttribute` 並實作 `IAsyncAuthorizationFilter`
- 在 `OnAuthorizationAsync` 中檢查使用者的 Claims 是否包含 `Function = "edit_MemberViolations"`
- 若無權限則回傳 `ForbidResult()`，導向 `/Home/Error/403`
- 此機制實現了**基於功能的存取控制 (Function-Based Access Control)**

### 6.2 Entity ↔ DTO 轉換使用擴充方法

本模組使用 `MemberViolationExtensions` 靜態擴充類別，提供 `ToDto()` 與 `ToEntity()` 方法：
- `ToDto()` 將 Entity 轉為 DTO，同時展平 `Member.User.UserName` 和 `Member.User.Email`
- `ToEntity()` 將 DTO 轉為 Entity（用於新增時）
- 這種模式避免了直接在 Repository 中手動映射的重複程式碼

### 6.3 Member 與 MemberViolation 的一對一關係

- `Member.cs` L38 定義了 `public virtual MemberViolation MemberViolation { get; set; }` — 導覽屬性（非集合）
- 這代表一個會員最多只能有一筆違規紀錄
- `Create` Action 中使用 `GetMembersAvailableForViolation()` 過濾已有違規紀錄的會員，確保不重複建立

### 6.4 Scoped 生命週期保證一致性

所有 DI 服務（Repository、Service、DbContext）均註冊為 Scoped，確保同一 HTTP Request 中：
- 共用同一個 `MyFitnessCoachDbContext` 實例
- 變更追蹤 (Change Tracking) 在整個 Request 中一致
- `SaveChanges()` 能正確保存所有變更

### 6.5 ValidateAntiForgeryToken 防 CSRF

`Create(POST)` 和 `Edit(POST)` 均標記了 `[ValidateAntiForgeryToken]`，搭配 View 中的 `<form asp-action="...">` Tag Helper 自動產生隱藏欄位，防止跨站請求偽造 (CSRF) 攻擊。

---

## 七、完整資料流圖

### 7.1 Index（查詢所有違規紀錄）

```
Browser                 Controller              Service               Repository            EF Core / DB
  │                        │                       │                      │                     │
  │── GET /Index ─────────→│                       │                      │                     │
  │                        │── GetAll() ──────────→│                      │                     │
  │                        │                       │── GetAll() ─────────→│                     │
  │                        │                       │                      │── LINQ Query ──────→│
  │                        │                       │                      │                     │── SELECT ...
  │                        │                       │                      │                     │   FROM MemberViolations
  │                        │                       │                      │                     │   JOIN Members
  │                        │                       │                      │                     │   JOIN Users
  │                        │                       │                      │←── List<Entity> ────│
  │                        │                       │                      │── .ToDto() ────────→│
  │                        │                       │←── List<DTO> ────────│                     │
  │                        │←── List<DTO> ─────────│                      │                     │
  │                        │── DTO → ViewModel ───→│                      │                     │
  │                        │── return View(vm) ───→│ Razor 引擎渲染       │                     │
  │←── HTML Response ──────│                       │                      │                     │
```

### 7.2 Create（新增違規紀錄）

```
Browser                 Controller              Service               Repository            EF Core / DB
  │                        │                       │                      │                     │
  │── GET /Create ────────→│                       │                      │                     │
  │                        │── GetMembersAvailable →│                      │                     │
  │                        │                       │── GetMembersWithout..│                     │
  │                        │                       │                      │── LINQ Query ──────→│
  │                        │                       │←── List<Member> ─────│                     │
  │                        │←── List<Member> ──────│                      │                     │
  │                        │── ViewBag.Members ───→│                      │                     │
  │←── HTML Form ──────────│                       │                      │                     │
  │                        │                       │                      │                     │
  │── POST /Create ───────→│                       │                      │                     │
  │   (form data)          │── ModelState.IsValid? │                      │                     │
  │                        │── VM → DTO ──────────→│                      │                     │
  │                        │                       │── Create(dto) ──────→│                     │
  │                        │                       │                      │── dto.ToEntity() ──→│
  │                        │                       │                      │── Add() ────────────→│
  │                        │                       │                      │── SaveChanges() ───→│── INSERT INTO ...
  │                        │                       │←── void ─────────────│                     │
  │                        │←── void ──────────────│                      │                     │
  │←── 302 Redirect /Index │                       │                      │                     │
```

---

## 八、涉及的關鍵檔案清單

| 檔案 | 類型 | 說明 |
|------|------|------|
| `Controllers/MemberViolationController.cs` | Controller | 處理 HTTP 請求，協調 Service 與 View |
| `Services/MemberViolationService.cs` | Service + Interface | 商業邏輯層（含 `IMemberViolationService` 介面定義） |
| `Repositories/MemberViolationRepository.cs` | Repository + Interface | 資料存取層（含 `IMemberViolationRepository` 介面定義） |
| `Models/EfModels/MemberViolation.cs` | Entity | EF Core 實體模型，對應 `MemberViolations` 資料表 |
| `Models/EfModels/Member.cs` | Entity | 會員實體，包含與 MemberViolation 的導覽屬性 |
| `Models/EfModels/User.cs` | Entity | 使用者實體，提供 UserName、Email 等資訊 |
| `Models/DTOs/MemberViolationDto.cs` | DTO | 資料傳輸物件，包含展平後的會員名稱與信箱 |
| `Models/DTOs/MemberViolationExtensions.cs` | Extension | Entity ↔ DTO 轉換擴充方法 |
| `Models/ViewModels/MemberViolationViewModel.cs` | ViewModel | 包含 `MemberViolationIndexViewModel` 與 `MemberViolationCreateEditViewModel` |
| `Views/MemberViolation/Index.cshtml` | View | 違規紀錄列表頁面 |
| `Views/MemberViolation/Create.cshtml` | View | 新增違規紀錄表單頁面 |
| `Views/MemberViolation/Edit.cshtml` | View | 編輯違規紀錄表單頁面 |
| `Infra/FunctionAttribute.cs` | Filter | 自訂功能授權過濾器 |
| `Program.cs` | 啟動設定 | DI 註冊與 Middleware 設定 |

---

## 九、程式碼優化建議

### 9.1 Delete Action 缺少 `[ValidateAntiForgeryToken]`

**問題：**
```csharp
// MemberViolationController.cs L134-139
[HttpPost]
public IActionResult Delete(int id)
```

`Delete` Action 標記了 `[HttpPost]` 但未加上 `[ValidateAntiForgeryToken]`，而 `Create(POST)` 和 `Edit(POST)` 都有加。

**原因：** 缺少 CSRF 防護，可能遭受跨站請求偽造攻擊，攻擊者可透過惡意網頁觸發刪除操作。

**建議改法：**
```csharp
[HttpPost]
[ValidateAntiForgeryToken]
public IActionResult Delete(int id)
```
並在 `Index.cshtml` 的 `deleteForm` 表單中確保已加入 `@Html.AntiForgeryToken()` 或使用 `asp-action` Tag Helper（目前已使用 `asp-action="Delete"`，會自動產生 Token）。

### 9.2 Repository 的 `GetAll()` 中使用 `.Select(mv => mv.ToDto())` 可能導致用戶端評估

**問題：**
```csharp
// MemberViolationRepository.cs L30-34
return _context.MemberViolations
    .Include(mv => mv.Member)
    .ThenInclude(m => m.User)
    .Select(mv => mv.ToDto())   // ← ToDto() 無法轉譯為 SQL
    .ToList();
```

**原因：** `ToDto()` 是自訂擴充方法，EF Core 無法將其轉譯為 SQL。EF Core 會先執行 `SELECT *` 載入所有欄位至記憶體，再在用戶端執行 `ToDto()`。雖然功能正確，但會載入不必要的欄位。

**建議改法：** 在 LINQ 查詢中直接使用匿名物件或 DTO 投影，讓 EF Core 只 SELECT 需要的欄位：
```csharp
return _context.MemberViolations
    .Include(mv => mv.Member)
    .ThenInclude(m => m.User)
    .Select(mv => new MemberViolationDto
    {
        Id = mv.Id,
        MemberId = mv.MemberId,
        MemberName = mv.Member.User.UserName ?? "Unknown",
        MemberEmail = mv.Member.User.Email ?? "Unknown",
        WarningCount = mv.WarningCount,
        IsSuspended = mv.IsSuspended,
        LastWarningAt = mv.LastWarningAt,
        SuspendedAt = mv.SuspendedAt,
        Reason = mv.Reason
    })
    .ToList();
```

### 9.3 `GetMembersWithoutViolations()` 使用兩次查詢

**問題：**
```csharp
// MemberViolationRepository.cs L82-90
public List<Member> GetMembersWithoutViolations()
{
    var violationMemberIds = _context.MemberViolations.Select(mv => mv.MemberId).ToList();  // 第一次查詢
    return _context.Members
        .Include(m => m.User)
        .Where(m => !violationMemberIds.Contains(m.Id))  // 第二次查詢
        .ToList();
}
```

**原因：** 先執行一次查詢取得所有違規會員 ID（載入至記憶體），再用 `Contains` 過濾。當資料量大時，會產生 `WHERE Id NOT IN (1, 2, 3, ...)` 這樣的長 SQL。

**建議改法：** 使用子查詢，讓 SQL Server 在一次查詢中完成：
```csharp
public List<Member> GetMembersWithoutViolations()
{
    return _context.Members
        .Include(m => m.User)
        .Where(m => !_context.MemberViolations.Any(mv => mv.MemberId == m.Id))
        .ToList();
}
```
這會產生 `WHERE NOT EXISTS (SELECT 1 FROM MemberViolations WHERE ...)` 的高效 SQL。

### 9.4 Service 層過度薄弱（Anemic Service Layer）

**問題：** `MemberViolationService` 的所有方法都只是直接委派給 Repository，沒有任何商業邏輯。

**原因：** 若 Service 層只是 pass-through，則失去了分層的意義，增加了不必要的間接呼叫。

**建議改法：** 目前架構在設計上保留了 Service 層的擴充空間（例如未來可加入警告次數自動累加、自動停權判斷等邏輯），但可以考慮將以下邏輯從 Controller 移到 Service：
- DTO ↔ ViewModel 的轉換（目前在 Controller 中進行）
- 新增時自動設定 `LastWarningAt = DateTime.Now`
- 當 `WarningCount >= 3` 時自動設定 `IsSuspended = true`

### 9.5 Edit(POST) 失敗時重新查詢可簡化

**問題：**
```csharp
// MemberViolationController.cs L124-129
var existingDto = _service.GetById(viewModel.Id);
if (existingDto != null)
{
    viewModel.MemberName = existingDto.MemberName;
}
```

**原因：** 當驗證失敗需要重新顯示表單時，需要額外一次資料庫查詢來取得 `MemberName`。

**建議改法：** 在 `MemberViolationCreateEditViewModel` 的 `MemberName` 欄位加上 `[HiddenInput]` 屬性，並在 Edit View 中加上 `<input type="hidden" asp-for="MemberName" />`，這樣 POST 回來時 Model Binding 就會自動保留 `MemberName`，無需再次查詢資料庫。
