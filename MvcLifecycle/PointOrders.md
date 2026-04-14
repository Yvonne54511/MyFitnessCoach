# PointOrdersController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

## 一、全局架構概覽

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Browser (Client)                          │
│              GET  /PointOrders/Index        (儲值訂單列表)           │
│              GET  /PointOrders/DashBoard    (數據概覽看板)           │
│              GET  /PointOrders/PointRecords (會員點數總覽)           │
│              GET  /PointOrders/Recharge     (儲值頁面)              │
│              POST /PointOrders/Recharge     (執行儲值)              │
│              GET  /PointOrders/Details/5    (訂單詳情)              │
│              POST /PointOrders/CancelOrder  (取消訂單)              │
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
│  │ 注意：Controller 級別未加 [Authorize]                         │  │
│  │ 僅 Index 有 [Function("edit_PlanOrders")]                    │  │
│  └──────────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ 路由匹配
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│               PointOrdersController (Controller 層)                 │
│               繼承: Controller（MVC Controller）                     │
│               DI 注入: MyFitnessCoachDbContext (直接)                │
│                        IPointOrderService                           │
│               ※ 混合使用 DbContext 直接查詢 + Service 層             │
└─────────┬─────────────────────────────┬─────────────────────────────┘
          │ 直接操作 DbContext            │ 呼叫 Service
          ▼                              ▼
┌──────────────────────┐   ┌──────────────────────────────────────────┐
│ MyFitnessCoachDbContext│   │ PointOrderService (Service 層)           │
│ (直接資料存取)         │   │ DI 注入: IPointOrderRepository           │
│                       │   │           MyFitnessCoachDbContext        │
└─────────┬─────────────┘   └──────────────────┬──────────────────────┘
          │                                     │ 呼叫 Repository
          │                                     ▼
          │                 ┌──────────────────────────────────────────┐
          │                 │ PointOrderRepository (Repository 層)      │
          │                 │ DI 注入: MyFitnessCoachDbContext          │
          │                 │ 命名空間: Models.Repositories             │
          │                 └──────────────────┬──────────────────────┘
          │                                     │
          ▼                                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│               EF Core (MyFitnessCoachDbContext)                     │
│               DbSet<PointOrder>, DbSet<Member>,                    │
│               DbSet<UserWallet>, DbSet<PointsRecordDetail>,        │
│               DbSet<TopUpPlan>                                     │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ SQL 查詢
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        SQL Server                                   │
│               Tables: PointOrders, Members, Users,                  │
│               UserWallets, PointsRecordDetails, TopUpPlans          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊

```csharp
// Program.cs L57-59
// 註冊 PointOrder 模組 (含平均客單計算)
builder.Services.AddScoped<Project_MyFitnessCoach.Models.Repositories.IPointOrderRepository,
                           Project_MyFitnessCoach.Models.Repositories.PointOrderRepository>();  // L58
builder.Services.AddScoped<Project_MyFitnessCoach.Models.Services.IPointOrderService,
                           Project_MyFitnessCoach.Models.Services.PointOrderService>();          // L59
```

> **注意命名空間差異：** PointOrder 模組的 Repository 和 Service 位於 `Models.Repositories` 和 `Models.Services` 命名空間下，與其他模組（如 MemberViolation 位於 `Repositories` 和 `Services`）不同，因此需要使用完整命名空間註冊。

DbContext 的註冊：
```csharp
// Program.cs L24-25
builder.Services.AddDbContext<MyFitnessCoachDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
```

### 2.2 生命週期範圍

| 服務 | 生命週期 | 說明 |
|------|----------|------|
| `IPointOrderRepository` → `PointOrderRepository` | **Scoped** | 每個 HTTP Request 建立一個實例 |
| `IPointOrderService` → `PointOrderService` | **Scoped** | 每個 HTTP Request 建立一個實例 |
| `MyFitnessCoachDbContext` | **Scoped** | Controller 和 Service 共用同一實例 |

### 2.3 DI 注入鏈（由下往上）

```
SQL Server
    ↑
MyFitnessCoachDbContext                (Scoped, Program.cs L24-25)
    ↑                    ↑
    │                    │
    │    PointOrderRepository          (Scoped, Program.cs L58)
    │        ↑ 實作 IPointOrderRepository
    │        │
    │    PointOrderService             (Scoped, Program.cs L59)
    │        ↑ 實作 IPointOrderService
    │        │
    └────────┤
             │
    PointOrdersController              (由 MVC 框架建立)
    注入: _context (DbContext) + _pointOrderService (Service)
```

> **特殊結構：** Controller 同時注入了 `MyFitnessCoachDbContext` 和 `IPointOrderService`。大部分 Action 直接操作 `_context`，僅 `DashBoard` 中的平均客單價計算透過 `_pointOrderService` 呼叫。

### 2.4 建構子程式碼

**Controller 建構子：**
```csharp
// PointOrdersController.cs L17-24
private readonly MyFitnessCoachDbContext _context;       // L17
private readonly IPointOrderService _pointOrderService;  // L18

public PointOrdersController(MyFitnessCoachDbContext context, IPointOrderService pointOrderService)  // L20
{
    _context = context;                        // L22
    _pointOrderService = pointOrderService;    // L23
}
```

**Service 建構子：**
```csharp
// PointOrderService.cs L23-30
private readonly IPointOrderRepository _repository;  // L23
private readonly MyFitnessCoachDbContext _context;    // L24

public PointOrderService(IPointOrderRepository repository, MyFitnessCoachDbContext context)  // L26
{
    _repository = repository;  // L28
    _context = context;        // L29
}
```

**Repository 建構子：**
```csharp
// PointOrderRepository.cs L22-27
private readonly MyFitnessCoachDbContext _context;

public PointOrderRepository(MyFitnessCoachDbContext context)  // L24
{
    _context = context;  // L26
}
```

### 2.5 介面與實作對照表

| 介面 | 實作類別 | 檔案位置 | 命名空間 |
|------|----------|----------|----------|
| `IPointOrderService` | `PointOrderService` | `Models/Services/PointOrderService.cs` | `Project_MyFitnessCoach.Models.Services` |
| `IPointOrderRepository` | `PointOrderRepository` | `Repositories/PointOrderRepository.cs` | `Project_MyFitnessCoach.Models.Repositories` |
| (無介面) | `MyFitnessCoachDbContext` | `Models/EfModels/MyFitnessCoachDbContext.cs` | `Project_MyFitnessCoach.Models.EfModels` |

---

## 三、完整 Request 生命週期（以 Index Action 為例）

### 步驟 1：HTTP Request

```
使用者在瀏覽器輸入或點擊連結：
GET https://localhost/PointOrders/Index

Request Headers:
  - Cookie: MyFitnessCoach.Auth=<加密Token>  ← Cookie 認證
  - Accept: text/html
```

### 步驟 2：Middleware Pipeline

請求依序經過以下 Middleware（Program.cs L131-187）：

```
1. ExceptionHandler        (L136/L142) → 捕捉未處理例外
2. StatusCodePages         (L145)      → HTTP 狀態碼頁面
3. HttpsRedirection        (L147)      → 確保 HTTPS
4. StaticFiles             (L149-176)  → 非靜態檔案，跳過
5. Routing                 (L178)      → 匹配路由規則
6. Authentication          (L180)      → 解析 Cookie（但此 Controller 未加 [Authorize]）
7. Authorization           (L181)      → Index 有 [Function("edit_PlanOrders")]，需檢查權限
```

### 步驟 3：路由匹配

```csharp
// Program.cs L185-187
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Account}/{action=Login}/{id?}");
```

URL `/PointOrders/Index` 匹配：
- **Controller**: `PointOrders` → `PointOrdersController`
- **Action**: `Index`
- **id**: null

### 步驟 4：DI 容器建立物件鏈

MVC 框架偵測到 `PointOrdersController` 建構子需要 `MyFitnessCoachDbContext` 和 `IPointOrderService`：

```
1. 建立 MyFitnessCoachDbContext        (若此 Request 尚未建立)
2. 建立 PointOrderRepository           (注入 DbContext)
3. 建立 PointOrderService              (注入 Repository + DbContext)
4. 建立 PointOrdersController          (注入 DbContext + Service)
```

進入 Action 前，`[Function("edit_PlanOrders")]` 檢查使用者的 Claims 中是否包含 `Function = "edit_PlanOrders"`。

### 步驟 5：Controller Action 執行

```csharp
// PointOrdersController.cs L27-37
[Function("edit_PlanOrders")]
public async Task<IActionResult> Index()
{
    var pointOrders = await _context.PointOrders                      // L30 ← 直接使用 DbContext
        .Include(p => p.Member).ThenInclude(m => m.User)             // L31
        .Include(p => p.PointsRecordDetails)                         // L32
        .Include(p => p.TopUpPlan)                                   // L33
        .OrderByDescending(p => p.CreateAt)                          // L34
        .ToListAsync();                                              // L35
    return View(pointOrders);                                        // L36 ← 直接傳 Entity 給 View
}
```

> **注意：** 此 Action 直接操作 `_context`（DbContext），繞過了 Service 和 Repository 層。

### 步驟 6：Service 層商業邏輯

**Index Action 未使用 Service 層。** Controller 直接查詢 DbContext。

Service 層僅在 `DashBoard` Action 中被使用，用於計算平均客單價：
```csharp
// PointOrdersController.cs L109-111 (DashBoard Action 中)
var avgDto = await _pointOrderService.CalculateAverageTicketSizeAsync(start, end);
```

```csharp
// PointOrderService.cs L32-40
public async Task<AverageTicketSizeDto> CalculateAverageTicketSizeAsync(DateTime? startDate = null, DateTime? endDate = null)
{
    if (startDate > endDate)
    {
        throw new ArgumentException("開始日期不能晚於結束日期");  // L36
    }
    return await _repository.GetAverageTicketSizeAsync(startDate, endDate);  // L39
}
```

### 步驟 7：Repository 層資料存取

**Index Action 未使用 Repository 層。**

Repository 在 Service 呼叫時使用，例如計算平均客單價：
```csharp
// PointOrderRepository.cs L29-49
public async Task<AverageTicketSizeDto> GetAverageTicketSizeAsync(DateTime? startDate, DateTime? endDate)
{
    var query = _context.PointOrders.Where(p => p.Status == 1).AsQueryable();  // L31

    if (startDate.HasValue) query = query.Where(p => p.CreateAt >= startDate.Value);  // L33
    if (endDate.HasValue) query = query.Where(p => p.CreateAt <= endDate.Value);      // L34

    var result = await query.Select(p => new { p.DiscountedPrice })
        .ToListAsync();  // L36-37

    var totalRevenue = result.Sum(r => r.DiscountedPrice);  // L39
    var totalCount = result.Count;                           // L40

    return new AverageTicketSizeDto
    {
        TotalRevenue = totalRevenue,                                          // L43
        TotalOrderCount = totalCount,                                         // L44
        AverageTicketSize = totalCount > 0 ? totalRevenue / totalCount : 0,  // L45
        CalculationDate = DateTime.Now                                        // L46
    };
}
```

### 步驟 8：EF Core → SQL Server

Index Action 產生的 SQL 大致如下：

```sql
SELECT p.[Id], p.[MemberId], p.[TopUpPlanId], p.[CreateAt], p.[PointQty],
       p.[OriginalPrice], p.[DiscountedPrice], p.[Status],
       m.[Id], m.[UserId], u.[Id], u.[UserName],
       tp.[Id], tp.[PlanName],
       prd.[Id], prd.[PointOrderId], prd.[PointAmount], ...
FROM [PointOrders] AS p
INNER JOIN [Members] AS m ON p.[MemberId] = m.[Id]
INNER JOIN [Users] AS u ON m.[UserId] = u.[Id]
LEFT JOIN [TopUpPlans] AS tp ON p.[TopUpPlanId] = tp.[Id]
LEFT JOIN [PointsRecordDetails] AS prd ON prd.[PointOrderId] = p.[Id]
ORDER BY p.[CreateAt] DESC
```

### 步驟 9：View 渲染

Controller 回傳 `View(pointOrders)` 後，Razor 引擎渲染 `Views/PointOrders/Index.cshtml`：

```
View 檔案: Views/PointOrders/Index.cshtml
Model 型別: IEnumerable<PointOrder>  ← 直接使用 Entity，非 ViewModel

渲染內容：
1. 頁面標題「儲值訂單管理」
2. 成功訊息 TempData 區塊
3. 「新增儲值」按鈕（連結到 Recharge）
4. 資料表（訂單編號、會員ID、會員姓名、方案名稱、儲值點數、實付金額、儲值時間）
5. 訂單編號為超連結，連結到 Details/{id}
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
1. PointOrdersController       → Dispose
2. PointOrderService           → Dispose
3. PointOrderRepository        → Dispose
4. MyFitnessCoachDbContext     → Dispose（關閉資料庫連線，歸還至連線池）
```

---

## 四、其他 Action 生命週期

### 4.1 DashBoard - 點數數據概覽

```csharp
// PointOrdersController.cs L40-129
public async Task<IActionResult> DashBoard()
```

| 差異點 | 說明 |
|--------|------|
| 資料存取方式 | **混合模式**：大部分直接操作 `_context`，僅平均客單價透過 `_pointOrderService` |
| 資料查詢量 | 大量查詢：今日營收 (L50-52)、昨日營收 (L54-56)、月營收 (L58-64)、總流通點數 (L66)、30 日趨勢 (L73-82)、熱門方案 (L92-101)、12 個月平均客單價 (L104-111) |
| Service 使用 | `_pointOrderService.CalculateAverageTicketSizeAsync(start, end)` (L109) 被迴圈呼叫 12 次 |
| ViewModel | 使用 `PointOrderDashboardViewModel`，組合多種 KPI 數據和圖表數據 |
| View | `Views/PointOrders/DashBoard.cshtml`，包含 Chart.js 圖表（堆疊面積圖、橫向長條圖、折線圖） |
| 無權限限制 | 未加 `[Authorize]` 或 `[Function]` 屬性 |

### 4.2 PointRecords - 會員點數資產總覽

```csharp
// PointOrdersController.cs L132-150
public async Task<IActionResult> PointRecords()
```

| 差異點 | 說明 |
|--------|------|
| 資料存取 | 直接操作 `_context.UserWallets`（非 PointOrders） |
| Include 鏈 | `UserWallets` → `Member` → `User` (L135-136) |
| ViewModel 轉換 | Entity → `PointOrderViewModel`（L140-147），但欄位映射有些特殊 |
| 特殊映射 | `PointQty = (int)w.CurrentBalance`、`CreateAt = w.LastUpdated` — 欄位名稱與實際語意不完全對應 |
| View | `Views/PointOrders/PointRecords.cshtml`，使用 jQuery DataTables 分頁排序 |

### 4.3 Recharge (GET) - 儲值頁面

```csharp
// PointOrdersController.cs L153-156
public IActionResult Recharge()
```

| 差異點 | 說明 |
|--------|------|
| 同步方法 | 非 async（無需查詢資料庫） |
| 無 Model | 直接回傳空 View |
| View | `Views/PointOrders/Recharge.cshtml`，手動輸入會員 ID、儲值點數、付款金額 |

### 4.4 Recharge (POST) - 執行儲值

```csharp
// PointOrdersController.cs L280-361
[HttpPost]
[ValidateAntiForgeryToken]
public async Task<IActionResult> Recharge(int memberId, int pointAmount, decimal price)
```

| 差異點 | 說明 |
|--------|------|
| HTTP 方法 | POST |
| Model Binding | 直接綁定 3 個基本型別參數（非 ViewModel） |
| 資料庫交易 | 使用 `_context.Database.BeginTransactionAsync()` (L303) 管理交易 |
| 多步驟操作 | 1. 驗證會員 → 2. 驗證金額 → 3. 建立 PointOrder → 4. 更新 UserWallet → 5. 記錄 PointsRecordDetail |
| 錢包建立 | 若會員無錢包，自動建立（L322-331） |
| 錯誤處理 | try-catch + transaction.RollbackAsync()（L355-359） |
| 成功回應 | TempData + RedirectToAction → Index |

### 4.5 Details - 訂單詳情

```csharp
// PointOrdersController.cs L159-196
public async Task<IActionResult> Details(int? id)
```

| 差異點 | 說明 |
|--------|------|
| 路由參數 | `int? id`（可為 null） |
| Include 鏈 | `PointOrders` → `Member` → `User`、`TopUpPlan`、`PointsRecordDetails` (L163-167) |
| ViewModel | 使用 `PointOrderViewModel`，含巢狀 `List<PointsRecordDetailViewModel>` (L183-192) |
| View | `Views/PointOrders/Details.cshtml`，包含基本資訊卡片、方案資訊、點數異動明細表格 |
| 操作按鈕 | 「同意取消」按鈕（連結到 CancelOrder）、「確認收款」按鈕 |

### 4.6 CancelOrder - 取消儲值訂單

```csharp
// PointOrdersController.cs L199-277
[HttpPost]
[ValidateAntiForgeryToken]
public async Task<IActionResult> CancelOrder(int id)
```

| 差異點 | 說明 |
|--------|------|
| HTTP 方法 | POST |
| 資料庫交易 | 使用 `BeginTransactionAsync()` (L214) |
| 狀態檢查 | 若已取消 (`Status == 3`)，回傳錯誤訊息 (L208-212) |
| 條件退點 | 原狀態為已完成 (`oldStatus == 1`) 時，從錢包扣除點數 (L224-244) |
| 流水帳記錄 | 無論原狀態，都建立 `PointsRecordDetail` 記錄（已完成扣負值，待付款記 0） |
| TempData | 成功/失敗訊息透過 TempData 傳遞 |
| 重導向 | 回到 Details 頁面 |

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── PointOrdersController.cs                  ← Controller 層
├── Models/
│   ├── Services/
│   │   └── PointOrderService.cs                  ← Service 層（含 IPointOrderService 介面）
│   ├── Repositories/
│   │   └── PointOrderRepository.cs               ← Repository 層（含 IPointOrderRepository 介面）
│   │                                             ※ 注意：位於 Models/ 下，非頂層 Repositories/
│   ├── EfModels/
│   │   ├── PointOrder.cs                         ← 主要 Entity
│   │   ├── Member.cs                             ← 關聯 Entity (會員)
│   │   ├── User.cs                               ← 關聯 Entity (使用者)
│   │   ├── UserWallet.cs                         ← 關聯 Entity (錢包)
│   │   ├── PointsRecordDetail.cs                 ← 關聯 Entity (點數流水帳)
│   │   ├── TopUpPlan.cs                          ← 關聯 Entity (儲值方案)
│   │   ├── ReserveOrder.cs                       ← 關聯 Entity (預約訂單，退款用)
│   │   └── MyFitnessCoachDbContext.cs            ← EF Core DbContext
│   ├── DTOs/
│   │   ├── PointOrderDto.cs                      ← 訂單 DTO
│   │   ├── AverageTicketSizeDto.cs               ← 平均客單價 DTO
│   │   └── PointsRecordDetailDto.cs              ← 點數記錄 DTO
│   ├── ViewModels/
│   │   ├── PointOrderViewModel.cs                ← 訂單 ViewModel + PointsRecordDetailViewModel
│   │   └── PointOrderDashboardViewModel.cs       ← 數據看板 ViewModel
│   └── Infra/
│       └── FunctionAttribute.cs                  ← 自訂授權過濾器
├── Views/
│   └── PointOrders/
│       ├── Index.cshtml                          ← 訂單列表頁面
│       ├── DashBoard.cshtml                      ← 數據看板頁面（含 Chart.js）
│       ├── PointRecords.cshtml                   ← 會員點數總覽（含 DataTables）
│       ├── Recharge.cshtml                       ← 儲值表單頁面
│       └── Details.cshtml                        ← 訂單詳情頁面
└── Repositories/
    └── PointOrderRepository.cs                   ← ※ 實際位於 Models/Repositories/
```

### 5.2 Entity 關聯鏈

```
User (使用者)
  │ PK: Id
  │
  └──── Member (會員，1:1)
          │ PK: Id
          │ FK: UserId → User.Id
          │
          ├──── PointOrder (儲值訂單，1:N)
          │       │ PK: Id
          │       │ FK: MemberId → Member.Id
          │       │ FK: TopUpPlanId → TopUpPlan.Id
          │       │ Properties: CreateAt, PointQty, OriginalPrice, DiscountedPrice, Status
          │       │
          │       ├──── PointsRecordDetail (點數流水帳，1:N)
          │       │       PK: Id
          │       │       FK: PointOrderId → PointOrder.Id
          │       │       FK: UserWalletId → UserWallet.Id
          │       │       FK: ReserveOrderId → ReserveOrder.Id (可 null)
          │       │       Properties: CreateAt, PointAmount, MerchandiseCategory
          │       │
          │       └──── TopUpPlan (儲值方案，N:1)
          │               PK: Id
          │               Properties: PlanName, ...
          │
          └──── UserWallet (使用者錢包，1:1)
                  PK: Id
                  FK: MemberId → Member.Id
                  Properties: CurrentBalance, LastUpdated

PointOrder.Status 狀態碼：
  0 = 待付款
  1 = 已完成
  2 = 爭議中
  3 = 已取消
```

---

## 六、重要概念總整理

### 6.1 混合架構模式：Controller 直接操作 DbContext + Service/Repository

此 Controller 是專案中的**特殊案例**，它同時注入了 `MyFitnessCoachDbContext` 和 `IPointOrderService`：

```csharp
// PointOrdersController.cs L17-18
private readonly MyFitnessCoachDbContext _context;
private readonly IPointOrderService _pointOrderService;
```

- **大部分 Action**（Index、PointRecords、Details、CancelOrder、Recharge）直接操作 `_context`
- **僅 DashBoard** 中的平均客單價計算透過 `_pointOrderService`

這種混合模式使得部分商業邏輯散落在 Controller 中，不符合嚴格的三層式架構。

### 6.2 資料庫交易 (Database Transaction)

`Recharge(POST)` 和 `CancelOrder` 都使用了明確的交易管理：

```csharp
using var transaction = await _context.Database.BeginTransactionAsync();
try
{
    // 多步驟操作...
    await _context.SaveChangesAsync();
    await transaction.CommitAsync();
}
catch (Exception ex)
{
    await transaction.RollbackAsync();
    // 錯誤處理...
}
```

交易確保了多步驟操作的原子性：
- **Recharge**：建立訂單 → 更新錢包 → 記錄流水帳，全部成功或全部回滾
- **CancelOrder**：更新狀態 → 扣除點數 → 記錄流水帳，全部成功或全部回滾

### 6.3 TempData 跨 Request 訊息傳遞

Controller 使用 `TempData` 在 POST → Redirect → GET 之間傳遞訊息：

```csharp
TempData["SuccessMessage"] = "訂單已成功取消...";
TempData["ErrorMessage"] = $"取消過程發生錯誤：{ex.Message}";
```

View 中讀取：
```html
@if (TempData["SuccessMessage"] != null)
{
    <div class="alert alert-success">@TempData["SuccessMessage"]</div>
}
```

TempData 使用 Cookie 或 Session 儲存，僅在下一次 Request 中有效，讀取後自動清除。

### 6.4 [Function] 屬性僅套用於 Index

```csharp
// PointOrdersController.cs L27
[Function("edit_PlanOrders")]
public async Task<IActionResult> Index()
```

**重要：** 只有 `Index` Action 加了 `[Function("edit_PlanOrders")]`，其他 Action（DashBoard、PointRecords、Recharge、Details、CancelOrder）皆**無權限限制**，也無 Controller 層級的 `[Authorize]`。

### 6.5 命名空間差異

PointOrder 模組的 Service 和 Repository 位於 `Models` 子目錄下：
- Repository: `Project_MyFitnessCoach.Models.Repositories`
- Service: `Project_MyFitnessCoach.Models.Services`

其他模組（如 MemberViolation）則位於頂層目錄：
- Repository: `Project_MyFitnessCoach.Repositories`
- Service: `Project_MyFitnessCoach.Services`

### 6.6 Chart.js 圖表整合

DashBoard 頁面使用 Chart.js 2.x 繪製三種圖表：
1. **堆疊面積圖**：儲值趨勢（近 30 日實際支付 vs 系統贈送）
2. **橫向長條圖**：熱門儲值方案排行榜
3. **折線圖**：平均客單價每月走勢

資料透過 `@Html.Raw(Json.Serialize(Model.xxx))` 將 C# 物件序列化為 JavaScript 變數。

---

## 七、完整資料流圖

### 7.1 Index（查詢所有儲值訂單）

```
Browser                 Controller              DbContext             EF Core / DB
  │                        │                       │                     │
  │── GET /Index ─────────→│                       │                     │
  │                        │── _context.PointOrders │                     │
  │                        │   .Include(Member/User)│                     │
  │                        │   .Include(RecordDetail)                    │
  │                        │   .Include(TopUpPlan)  │                     │
  │                        │   .OrderByDescending ──→│                     │
  │                        │   .ToListAsync() ─────→│── LINQ → SQL ─────→│
  │                        │                       │                     │── SELECT ... JOIN ...
  │                        │                       │←── List<PointOrder> ─│
  │                        │←── List<PointOrder> ──│                     │
  │                        │── return View(entities)                     │
  │                        │── Razor 渲染 ─────────→│                     │
  │←── HTML Response ──────│                       │                     │
```

### 7.2 DashBoard（數據概覽看板）

```
Browser           Controller              DbContext           Service          Repository        DB
  │                  │                       │                   │                 │              │
  │── GET /DashBoard→│                       │                   │                 │              │
  │                  │── 今日營收查詢 ────────→│                   │                 │              │
  │                  │── 昨日營收查詢 ────────→│                   │                 │              │
  │                  │── 月營收查詢 ──────────→│                   │                 │              │
  │                  │── 總流通點數查詢 ──────→│                   │                 │              │
  │                  │── 30 日趨勢查詢 ──────→│                   │                 │              │
  │                  │── 熱門方案查詢 ────────→│                   │                 │              │
  │                  │                       │                   │                 │              │
  │                  │── for (month=1..12)   │                   │                 │              │
  │                  │── CalculateAverage ───→│                   │                 │              │
  │                  │   TicketSizeAsync()    │── GetAverage ───→│                 │              │
  │                  │                       │   TicketSize()    │── LINQ Query ──→│              │
  │                  │                       │                   │←── DTO ─────────│              │
  │                  │←── DTO ──────────────→│                   │                 │              │
  │                  │                       │                   │                 │              │
  │                  │── 組合 DashboardVM ───→│                   │                 │              │
  │                  │── return View(vm) ───→│ Razor + Chart.js  │                 │              │
  │←── HTML + JS ────│                       │                   │                 │              │
```

### 7.3 Recharge POST（執行儲值）

```
Browser           Controller              DbContext                              DB
  │                  │                       │                                    │
  │── POST /Recharge→│                       │                                    │
  │   memberId=5     │                       │                                    │
  │   pointAmount=100│                       │                                    │
  │   price=100      │                       │                                    │
  │                  │── 驗證會員 ────────────→│── SELECT Member ──────────────────→│
  │                  │                       │←── Member Entity ──────────────────│
  │                  │── BeginTransaction ──→│                                    │
  │                  │                       │                                    │
  │                  │── 建立 PointOrder ────→│── INSERT PointOrder ──────────────→│
  │                  │── SaveChanges ────────→│                                    │
  │                  │                       │                                    │
  │                  │── 更新 UserWallet ────→│── UPDATE UserWallet ──────────────→│
  │                  │                       │   (CurrentBalance += pointAmount)   │
  │                  │                       │                                    │
  │                  │── 建立 RecordDetail ──→│── INSERT PointsRecordDetail ──────→│
  │                  │── SaveChanges ────────→│                                    │
  │                  │── CommitTransaction ──→│── COMMIT ─────────────────────────→│
  │                  │                       │                                    │
  │←── 302 → /Index ─│                       │                                    │
```

### 7.4 CancelOrder POST（取消訂單）

```
Browser           Controller              DbContext                              DB
  │                  │                       │                                    │
  │── POST /Cancel ──→│                       │                                    │
  │   id=5            │── 查詢訂單 ──────────→│── SELECT PointOrder + Wallet ─────→│
  │                  │                       │←── Entity ────────────────────────│
  │                  │── 狀態檢查 (==3?) ───→│                                    │
  │                  │── BeginTransaction ──→│                                    │
  │                  │                       │                                    │
  │                  │── Status = 3 ────────→│── UPDATE Status ──────────────────→│
  │                  │── if (oldStatus==1):  │                                    │
  │                  │   扣除錢包點數 ───────→│── UPDATE Wallet ──────────────────→│
  │                  │   記錄流水帳(負值) ──→│── INSERT RecordDetail ─────────────→│
  │                  │── SaveChanges ────────→│                                    │
  │                  │── CommitTransaction ──→│── COMMIT ─────────────────────────→│
  │                  │                       │                                    │
  │←── 302 → Details ─│                       │                                    │
```

---

## 八、涉及的關鍵檔案清單

| 檔案 | 類型 | 說明 |
|------|------|------|
| `Controllers/PointOrdersController.cs` | Controller | 處理儲值訂單相關的所有 HTTP 請求 |
| `Models/Services/PointOrderService.cs` | Service + Interface | 商業邏輯層（含 `IPointOrderService` 介面定義） |
| `Models/Repositories/PointOrderRepository.cs` | Repository + Interface | 資料存取層（含 `IPointOrderRepository` 介面定義，注意位於 Models/ 下） |
| `Models/EfModels/PointOrder.cs` | Entity | 儲值訂單實體 |
| `Models/EfModels/Member.cs` | Entity | 會員實體 |
| `Models/EfModels/User.cs` | Entity | 使用者實體 |
| `Models/EfModels/UserWallet.cs` | Entity | 使用者錢包實體 |
| `Models/EfModels/PointsRecordDetail.cs` | Entity | 點數流水帳實體 |
| `Models/EfModels/TopUpPlan.cs` | Entity | 儲值方案實體 |
| `Models/EfModels/ReserveOrder.cs` | Entity | 預約訂單實體（退款功能使用） |
| `Models/DTOs/PointOrderDto.cs` | DTO | 訂單資料傳輸物件 |
| `Models/DTOs/AverageTicketSizeDto.cs` | DTO | 平均客單價 DTO |
| `Models/DTOs/PointsRecordDetailDto.cs` | DTO | 點數記錄 DTO |
| `Models/ViewModels/PointOrderViewModel.cs` | ViewModel | 訂單 ViewModel + 點數記錄子 ViewModel |
| `Models/ViewModels/PointOrderDashboardViewModel.cs` | ViewModel | 數據看板 ViewModel（KPI + 圖表數據） |
| `Views/PointOrders/Index.cshtml` | View | 儲值訂單列表頁面 |
| `Views/PointOrders/DashBoard.cshtml` | View | 數據概覽看板（含 Chart.js） |
| `Views/PointOrders/PointRecords.cshtml` | View | 會員點數總覽（含 DataTables） |
| `Views/PointOrders/Recharge.cshtml` | View | 儲值表單頁面 |
| `Views/PointOrders/Details.cshtml` | View | 訂單詳情頁面 |
| `Infra/FunctionAttribute.cs` | Filter | 自訂功能授權過濾器 |
| `Program.cs` | 啟動設定 | DI 註冊（L57-59）與 Middleware 設定 |

---

## 九、程式碼優化建議

### 9.1 Controller 直接操作 DbContext，繞過 Service/Repository 層

**問題：**
```csharp
// PointOrdersController.cs L17
private readonly MyFitnessCoachDbContext _context;
```

Controller 中大量直接使用 `_context` 進行查詢和寫入（Index L30-35、DashBoard L50-101、PointRecords L134-138、Details L163-167、CancelOrder L203-266、Recharge L285-350）。

**原因：** 違反三層式架構原則，商業邏輯（如取消訂單的退點邏輯、儲值的錢包更新邏輯）散落在 Controller 中，導致：
- 難以單元測試（Controller 直接依賴 DbContext）
- 商業邏輯無法在其他地方重用
- 與專案中其他模組（如 MemberViolation 嚴格遵循三層式）風格不一致

**建議改法：** 將 Controller 中的查詢邏輯移至 `PointOrderService` 和 `PointOrderRepository`，Controller 僅負責接收請求和回傳結果。例如將 `CancelOrder` 的交易邏輯移至 Service 層：
```csharp
// Controller
public async Task<IActionResult> CancelOrder(int id)
{
    var result = await _pointOrderService.CancelOrderAsync(id);
    TempData[result.Success ? "SuccessMessage" : "ErrorMessage"] = result.Message;
    return RedirectToAction(nameof(Details), new { id });
}
```

### 9.2 大部分 Action 缺少授權保護

**問題：** Controller 類別層級未加 `[Authorize]`，僅 `Index` Action 有 `[Function("edit_PlanOrders")]`。

```csharp
// PointOrdersController.cs L14-15
public class PointOrdersController : Controller  // ← 無 [Authorize]
```

**原因：** `DashBoard`、`PointRecords`、`Details`、`Recharge`、`CancelOrder` 等涉及敏感資料和金融操作的 Action 完全無需登入即可存取。

**建議改法：** 在 Controller 類別層級加上 `[Authorize]`：
```csharp
[Authorize]
public class PointOrdersController : Controller
```
並視需要對各 Action 加上 `[Function]` 權限控制。

### 9.3 DashBoard 中平均客單價計算效率低

**問題：**
```csharp
// PointOrdersController.cs L104-111
for (int month = 1; month <= 12; month++)
{
    var start = new DateTime(now.Year, month, 1);
    var end = start.AddMonths(1).AddDays(-1);
    var avgDto = await _pointOrderService.CalculateAverageTicketSizeAsync(start, end);
    monthlyAverageTicketSizes.Add(avgDto.AverageTicketSize);
}
```

**原因：** 迴圈呼叫 12 次 `CalculateAverageTicketSizeAsync`，每次都會執行一次資料庫查詢。加上 DashBoard 中其他 6 次查詢，一次頁面載入共觸發約 18 次 SQL 查詢。

**建議改法：** 使用單一查詢搭配 `GroupBy` 月份計算 12 個月的平均客單價：
```csharp
var monthlyData = await _context.PointOrders
    .Where(o => o.CreateAt.Year == now.Year && o.Status == 1)
    .GroupBy(o => o.CreateAt.Month)
    .Select(g => new
    {
        Month = g.Key,
        Average = g.Average(o => o.DiscountedPrice)
    })
    .ToListAsync();
```

### 9.4 Index View 直接使用 Entity 作為 Model

**問題：**
```csharp
// PointOrdersController.cs L36
return View(pointOrders);  // List<PointOrder> Entity
```

```html
<!-- Index.cshtml L1 -->
@model IEnumerable<Project_MyFitnessCoach.Models.EfModels.PointOrder>
```

**原因：** View 直接使用 EF Core Entity，存在以下風險：
- Entity 變更追蹤仍然有效，View 中意外修改可能影響資料庫
- 暴露不必要的導覽屬性和欄位
- View 中需要使用 `item.Member?.User?.UserName`（多層 null check），可讀性差

**建議改法：** 使用已經定義好的 `PointOrderViewModel` 或 `PointOrderDto`：
```csharp
var viewModels = pointOrders.Select(p => new PointOrderViewModel
{
    Id = p.Id,
    MemberName = p.Member?.User?.UserName ?? "未知",
    PlanName = p.TopUpPlan?.PlanName ?? "手動儲值",
    PointQty = p.PointQty,
    DiscountedPrice = p.DiscountedPrice,
    CreateAt = p.CreateAt,
    Status = p.Status
}).ToList();
return View(viewModels);
```

### 9.5 PointRecords 中 ViewModel 欄位語意不匹配

**問題：**
```csharp
// PointOrdersController.cs L142-146
var viewModel = wallets.Select(w => new PointOrderViewModel
{
    Id = w.Id,
    MemberId = w.MemberId,
    MemberName = w.Member.User.UserName,
    PointQty = (int)w.CurrentBalance,    // ← 「錢包餘額」映射到「儲值點數」
    CreateAt = w.LastUpdated              // ← 「最後更新時間」映射到「建立時間」
}).ToList();
```

**原因：** 強行將 `UserWallet` 的欄位映射到 `PointOrderViewModel`，語意不對應。`PointQty` 原意為「儲值點數」，這裡卻代表「錢包餘額」；`CreateAt` 原意為「建立時間」，這裡卻代表「最後更新時間」。

**建議改法：** 建立專用的 `WalletOverviewViewModel`：
```csharp
public class WalletOverviewViewModel
{
    public int MemberId { get; set; }
    public string MemberName { get; set; }
    public int CurrentBalance { get; set; }
    public DateTime LastUpdated { get; set; }
}
```

### 9.6 CancelOrder 中的 Exception 訊息直接暴露給使用者

**問題：**
```csharp
// PointOrdersController.cs L273
TempData["ErrorMessage"] = $"取消過程發生錯誤：{ex.Message}";
```

**原因：** `ex.Message` 可能包含資料庫連線資訊、SQL 語句等敏感內容。在生產環境中，將例外訊息直接顯示給使用者是一個安全風險。

**建議改法：** 記錄完整例外至日誌，顯示友善的錯誤訊息：
```csharp
catch (Exception ex)
{
    await transaction.RollbackAsync();
    // _logger.LogError(ex, "取消訂單 {OrderId} 失敗", id);
    TempData["ErrorMessage"] = "取消過程發生錯誤，請稍後再試或聯繫管理員。";
}
```
