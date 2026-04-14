# ProductOrdersController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

## 一、全局架構概覽

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Browser (HTTP Request)                       │
│              GET /ProductOrders/Index?status=0&searchString=...       │
└──────────────────────────────┬────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Middleware Pipeline                              │
│  UseHttpsRedirection → UseStaticFiles → UseRouting                   │
│  → UseAuthentication → UseAuthorization → Endpoint                   │
└──────────────────────────────┬────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     Routing & Endpoint Resolution                     │
│            {controller=Account}/{action=Login}/{id?}                 │
│            匹配 → ProductOrdersController.Index(...)                 │
└──────────────────────────────┬────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   DI Container 建立物件鏈                             │
│                                                                      │
│  MyFitnessCoachDbContext (Scoped)                                     │
│          ↓ 注入                                                      │
│  ProductOrderRepository : IProductOrderRepository (Scoped)           │
│          ↓ 注入                                                      │
│  ProductOrderService (Scoped)                                        │
│          ↓ 注入                                                      │
│  ProductOrdersController                                             │
└──────────────────────────────┬────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│              ProductOrdersController (Action 執行)                    │
│                      ↓ 呼叫                                          │
│              ProductOrderService (商業邏輯層)                         │
│                      ↓ 呼叫                                          │
│      ProductOrderRepository : IProductOrderRepository (資料存取層)    │
│                      ↓ 操作                                          │
│              EF Core (MyFitnessCoachDbContext)                        │
│                      ↓ SQL                                           │
│              SQL Server 資料庫                                        │
└──────────────────────────────┬────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    View 渲染 (Razor Engine)                           │
│    Views/ProductOrders/Index.cshtml | Details.cshtml | ...           │
│    Model: ProductOrderDto / ProductOrderViewModel / ...              │
└──────────────────────────────┬────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      HTTP Response (HTML)                             │
└─────────────────────────────────────────────────────────────────────┘
```

**架構特點：此 Controller 採用完整的三層式架構（Controller → Service → Repository → EF Core），符合 ASP.NET Core 的最佳實踐。Service 類別位於 `Models/Services/` 目錄下，Repository 位於 `Repositories/` 目錄下。**

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊

```csharp
// Program.cs L28-29
builder.Services.AddScoped<IProductOrderRepository, ProductOrderRepository>();
builder.Services.AddScoped<ProductOrderService>();

// Program.cs L24-25（DbContext 共用）
builder.Services.AddDbContext<MyFitnessCoachDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
```

### 2.2 生命週期範圍

| 註冊項目                      | 生命週期   | 說明                                                    |
|-----------------------------|-----------|--------------------------------------------------------|
| `MyFitnessCoachDbContext`   | **Scoped** | `AddDbContext<T>()` 預設為 Scoped                        |
| `IProductOrderRepository`   | **Scoped** | Program.cs L28，每個 Request 一個實例                     |
| `ProductOrderService`       | **Scoped** | Program.cs L29，每個 Request 一個實例                     |

### 2.3 DI 注入鏈（由下往上）

```
SQL Server
   ↑
MyFitnessCoachDbContext (Scoped) ─── AddDbContext L24-25
   ↑ 注入
ProductOrderRepository : IProductOrderRepository (Scoped) ─── L28
   ↑ 注入
ProductOrderService (Scoped) ─── L29
   ↑ 注入
ProductOrdersController
```

### 2.4 建構子程式碼

**Controller 建構子：**
```csharp
// Controllers/ProductOrdersController.cs L14-19
private readonly ProductOrderService _service;

public ProductOrdersController(ProductOrderService service)
{
    _service = service;
}
```

**Service 建構子：**
```csharp
// Models/Services/ProductOrderService.cs L10-15
private readonly IProductOrderRepository _repository;

public ProductOrderService(IProductOrderRepository repository)
{
    _repository = repository;
}
```

**Repository 建構子：**
```csharp
// Repositories/ProductOrderRepository.cs L57-62
private readonly MyFitnessCoachDbContext _context;

public ProductOrderRepository(MyFitnessCoachDbContext context)
{
    _context = context;
}
```

### 2.5 介面與實作對照表

| 介面                         | 實作類別                   | 註冊位置         |
|-----------------------------|---------------------------|-----------------|
| `IProductOrderRepository`    | `ProductOrderRepository`  | Program.cs L28  |
| （無介面，直接註冊具體類別）    | `ProductOrderService`     | Program.cs L29  |

---

## 三、完整 Request 生命週期（以 Index Action 為例）

### 步驟 1：HTTP Request

```
GET /ProductOrders/Index?status=0&searchString=王 HTTP/1.1
Host: localhost:xxxx
Cookie: MyFitnessCoach.Auth=<加密Cookie>
```

管理員在訂單管理頁面選擇「待處理」狀態篩選並輸入關鍵字「王」，表單透過 `method="get"` 發送 GET 請求。

### 步驟 2：Middleware Pipeline

請求依序通過以下 Middleware（對應 Program.cs L147-181）：

```
UseHttpsRedirection()    → L147：HTTP 重導至 HTTPS
UseStaticFiles()         → L149-176：靜態檔案處理
UseRouting()             → L178：路由匹配
UseAuthentication()      → L180：Cookie 驗證身份解析
UseAuthorization()       → L181：授權檢查
```

**重點：Index Action 標記了 `[Function("edit_ProductOrders")]`（自訂授權過濾器），將在 Action 執行前進行功能權限檢查。**

### 步驟 3：路由匹配

```csharp
// Program.cs L185-187
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Account}/{action=Login}/{id?}");
```

路由引擎將 URL `/ProductOrders/Index` 解析為：
- **Controller** = `ProductOrders` → `ProductOrdersController`
- **Action** = `Index` → `Index(int? status, string searchString)`
- Query String `status=0` 和 `searchString=王` 透過 Model Binding 綁定

### 步驟 4：DI 容器建立物件鏈

```
1. DI 容器收到建立 ProductOrdersController 的請求
2. 檢查建構子需要 ProductOrderService
3. ProductOrderService 建構子需要 IProductOrderRepository
4. IProductOrderRepository 解析為 ProductOrderRepository
5. ProductOrderRepository 建構子需要 MyFitnessCoachDbContext
6. 從 Scoped 容器取得（或建立）MyFitnessCoachDbContext
7. 建立 ProductOrderRepository，注入 DbContext
8. 建立 ProductOrderService，注入 Repository
9. 建立 ProductOrdersController，注入 Service
```

**在執行 Action 之前，`FunctionAttribute` 授權過濾器會先執行：**

```csharp
// Infra/FunctionAttribute.cs L20-38
public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
{
    // 檢查使用者是否已登入
    if (context.HttpContext.User.Identity?.IsAuthenticated != true) return;

    // 檢查使用者的 Claims 中是否包含 "edit_ProductOrders" 功能
    var userFunctions = context.HttpContext.User.FindAll("Function").Select(c => c.Value);
    if (!userFunctions.Contains(FunctionName))
    {
        context.Result = new ForbidResult(); // 403 Forbidden
    }
}
```

### 步驟 5：Controller Action 執行

```csharp
// Controllers/ProductOrdersController.cs L22-31
[Function("edit_ProductOrders")]
public async Task<IActionResult> Index(int? status, string searchString)
{
    // L25：委派給 Service 層取得資料
    var orders = await _service.GetAllAsync(status, searchString);

    // L27-28：將篩選條件存入 ViewBag 供 View 回顯
    ViewBag.CurrentStatus = status;
    ViewBag.CurrentSearch = searchString;

    // L30：傳遞 DTO 清單給 View
    return View(orders);
}
```

### 步驟 6：Service 層商業邏輯

```csharp
// Models/Services/ProductOrderService.cs L17-20
public async Task<List<ProductOrderDto>> GetAllAsync(int? status, string searchString)
{
    return await _repository.GetAllAsync(status, searchString);
}
```

在 Index 的情境中，Service 層僅作為透傳層（Pass-through），直接呼叫 Repository。但 Service 層的存在為未來擴充商業邏輯保留了空間（如 `UpdateStatusAsync` 方法中的註解提到可加入狀態轉換驗證和通知發送）。

### 步驟 7：Repository 層資料存取

```csharp
// Repositories/ProductOrderRepository.cs L181-211
public async Task<List<ProductOrderDto>> GetAllAsync(int? status, string searchString)
{
    // L183-186：建立基礎查詢，Include 會員和使用者資料
    var query = _context.ProductOrders
        .Include(p => p.Member)
        .ThenInclude(m => m.User)
        .AsQueryable();

    // L188-191：依狀態篩選
    if (status.HasValue)
    {
        query = query.Where(p => p.Status == status.Value);
    }

    // L193-197：依關鍵字篩選（會員姓名或收件人）
    if (!string.IsNullOrEmpty(searchString))
    {
        query = query.Where(p => p.Member.User.UserName.Contains(searchString) ||
                                   p.Receiver.Contains(searchString));
    }

    // L199-210：排序並投影為 DTO
    return await query.OrderByDescending(p => p.CreateAt)
        .Select(p => new ProductOrderDto
        {
            Id = p.Id,
            MemberId = p.MemberId,
            MemberName = p.Member.User.UserName,
            CreateAt = p.CreateAt,
            OriginalAmount = p.OriginalAmount,
            DiscountAmount = p.DiscountAmount,
            Receiver = p.Receiver,
            Status = p.Status
        }).ToListAsync();
}
```

### 步驟 8：EF Core → SQL Server

EF Core 將 LINQ 轉換為 SQL，範例（status=0, searchString="王"）：

```sql
SELECT [p].[Id], [p].[MemberId], [u].[UserName] AS [MemberName],
       [p].[CreateAt], [p].[OriginalAmount], [p].[DiscountAmount],
       [p].[Receiver], [p].[Status]
FROM [ProductOrders] AS [p]
INNER JOIN [Members] AS [m] ON [p].[MemberId] = [m].[Id]
INNER JOIN [Users] AS [u] ON [m].[UserId] = [u].[Id]
WHERE [p].[Status] = 0
  AND ([u].[UserName] LIKE N'%王%' OR [p].[Receiver] LIKE N'%王%')
ORDER BY [p].[CreateAt] DESC
```

### 步驟 9：View 渲染

Razor 引擎載入 `Views/ProductOrders/Index.cshtml`，Model 型別為 `IEnumerable<ProductOrderDto>`。

View 負責：
- 篩選表單：狀態下拉選單（自動觸發 submit）、關鍵字搜尋、重置按鈕
- 訂單列表表格：編號、時間、會員帳號（點擊可查看該會員全部訂單）、收件人、金額、狀態 Badge、操作按鈕（詳情/刪除）
- 狀態以不同顏色 Badge 呈現（待處理=黃、已出貨=藍、已送達=綠、已取消=紅、退貨=資訊藍、爭議=警告黃）

### 步驟 10：HTTP Response

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

<html>... (訂單列表 HTML) ...</html>
```

### 步驟 11：Scoped 物件 Dispose

```
1. HTTP Response 發送完成
2. DI 容器銷毀本次 Request 的 Scoped 物件（LIFO 順序）：
   - ProductOrdersController → GC 回收
   - ProductOrderService → GC 回收
   - ProductOrderRepository → GC 回收
   - MyFitnessCoachDbContext.Dispose() → 釋放 DB 連線回連線池
```

---

## 四、其他 Action 生命週期

### 4.1 Dashboard Action

```csharp
// Controllers/ProductOrdersController.cs L34-80
public async Task<IActionResult> Dashboard()
```

| 差異點 | 說明 |
|-------|------|
| 無篩選參數 | 不接受任何查詢參數 |
| 無 `[Function]` 標記 | 未使用自訂授權過濾器（但也無 `[Authorize]`） |
| Service 呼叫 | `_service.GetDashboardDataAsync()` → Repository 執行多次聚合查詢 |
| DTO → ViewModel 轉換 | Controller 中手動將 `ProductOrderDashboardDto` 轉換為 `ProductOrderDashboardViewModel`（L38-77） |
| Repository 複雜度 | Repository L64-179 執行了 8+ 次 DB 查詢（本月/上月訂單量、待出貨、爭議、趨勢、縣市、類別、今日訂單、待處理訂單） |
| View | `Dashboard.cshtml`：使用 Chart.js 渲染折線圖（訂單趨勢）、圓餅圖（縣市分布）、橫向長條圖（類別排行） |

### 4.2 MemberAllOrders Action

```csharp
// Controllers/ProductOrdersController.cs L83-110
public async Task<IActionResult> MemberAllOrders(int? id)
```

| 差異點 | 說明 |
|-------|------|
| 路由參數 | 接受 `id`（memberId），預設為 1（測試用） |
| Service 呼叫 | `_service.GetByMemberIdAsync(memberId)` |
| DTO → ViewModel | 將 `ProductOrderDto` 列表轉換為 `ProductOrderViewModel` 列表（L90-106） |
| 包含明細 | 查詢結果包含 `OrderDetails`（子訂單明細） |
| View | `MemberAllOrders.cshtml`：可展開的訂單列表，含商品明細折疊區塊 |

### 4.3 Details Action

```csharp
// Controllers/ProductOrdersController.cs L113-157
public async Task<IActionResult> Details(int? id)
```

| 差異點 | 說明 |
|-------|------|
| 空值檢查 | `id == null` 時回傳 `NotFound()` |
| Service 呼叫 | `_service.GetByIdAsync(id.Value)` |
| DTO → ViewModel | 完整轉換包含所有欄位（含 Receiver、Address、Mobile、TaxNumber、Memo 等） |
| View | `Details.cshtml`：含基本資訊卡片、狀態管理表單、收件人資訊、備註、退貨/爭議處理區塊、商品明細表格 |

### 4.4 UpdateStatus Action (POST)

```csharp
// Controllers/ProductOrdersController.cs L160-173
[HttpPost]
[ValidateAntiForgeryToken]
public async Task<IActionResult> UpdateStatus(int id, int newStatus)
```

| 差異點 | 說明 |
|-------|------|
| HTTP Method | POST（寫入操作） |
| 防偽驗證 | `[ValidateAntiForgeryToken]` 防止 CSRF 攻擊 |
| 存在性檢查 | `_service.Exists(id)` → Repository 的同步方法 |
| Service 呼叫 | `_service.UpdateStatusAsync(id, newStatus)` → Repository 更新 Status 欄位 |
| TempData | 設定成功訊息 `TempData["SuccessMessage"]` |
| 重導向 | `RedirectToAction(nameof(Details), new { id })` → PRG 模式 |

### 4.5 Delete / DeleteConfirmed Action

```csharp
// Controllers/ProductOrdersController.cs L176-205
// GET: Delete(int? id) - 顯示確認頁面
// POST: DeleteConfirmed(int id) - 執行「刪除」（實際為軟刪除，Status 設為 3）
```

| 差異點 | 說明 |
|-------|------|
| 兩階段操作 | GET 顯示確認頁 → POST 執行刪除 |
| 軟刪除 | Repository L261-268：`order.Status = 3`（已取消），非真正刪除資料列 |
| `[ActionName("Delete")]` | POST 方法名為 `DeleteConfirmed`，但路由名稱仍為 `Delete` |
| View | `Delete.cshtml`：顯示訂單摘要資訊，確認刪除表單 |

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── ProductOrdersController.cs              ← Controller
├── Models/
│   ├── EfModels/
│   │   ├── ProductOrder.cs                     ← Entity（商品訂單）
│   │   ├── ProductOrderDetail.cs               ← Entity（訂單明細）
│   │   ├── Member.cs                           ← Entity（會員）
│   │   ├── User.cs                             ← Entity（使用者帳號）
│   │   └── Product.cs                          ← Entity（商品，Category 排行用）
│   ├── DTOs/
│   │   ├── ProductOrderDto.cs                  ← DTO（訂單資料傳輸）
│   │   └── ProductOrderDashboardDto.cs         ← DTO（看板資料傳輸）
│   ├── ViewModels/
│   │   ├── ProductOrderViewModel.cs            ← ViewModel（訂單顯示）
│   │   └── ProductOrderDashboardViewModel.cs   ← ViewModel（看板顯示）
│   ├── Services/
│   │   └── ProductOrderService.cs              ← Service 層
│   └── Infra/
│       └── FunctionAttribute.cs                ← 自訂授權過濾器
├── Repositories/
│   └── ProductOrderRepository.cs               ← Repository 層（含 Interface）
├── Views/
│   └── ProductOrders/
│       ├── Index.cshtml                        ← 訂單列表
│       ├── Details.cshtml                      ← 訂單詳情
│       ├── Dashboard.cshtml                    ← 統計看板
│       ├── MemberAllOrders.cshtml              ← 會員訂單總覽
│       ├── Delete.cshtml                       ← 刪除確認
│       ├── Create.cshtml                       ← 建立訂單（Controller 中無對應 Action）
│       └── Edit.cshtml                         ← 編輯訂單（Controller 中無對應 Action）
└── Program.cs                                  ← DI 註冊（L28-29）
```

### 5.2 Entity 關聯鏈

```
ProductOrder (商品訂單)
├── MemberId (FK) ──→ Member (會員)
│                       └── UserId (FK) ──→ User (使用者帳號)
└── ProductOrderDetails (1:N) ──→ ProductOrderDetail (訂單明細)
                                    └── ProductId (FK) ──→ Product (商品)
                                                            └── CategoryId (FK) ──→ Category (商品類別)
```

**Entity 欄位摘要：**

| Entity               | 關鍵欄位                                                                    |
|----------------------|----------------------------------------------------------------------------|
| `ProductOrder`       | Id, MemberId, CreateAt, OriginalAmount, DiscountAmount, Receiver, Address, Mobile, TaxNumber, Status, Memo |
| `ProductOrderDetail` | Id, ProductOrderId, ProductId, UnitPrice, Qty, SubTotal, DiscountedPrice, ProductName, ImageUrl, Memo      |
| `Member`             | Id, UserId, Gender, DateOfBirth, Weight, Height                            |
| `User`               | Id, Account, UserName, Email, IsActive                                     |

**訂單狀態對照：**

| Status 值 | 狀態名稱   |
|-----------|----------|
| 0         | 待處理    |
| 1         | 已出貨    |
| 2         | 已送達    |
| 3         | 已取消    |
| 4         | 退貨申請  |
| 5         | 退貨申請中 |
| 6         | 爭議      |

---

## 六、重要概念總整理

### 6.1 三層式架構（Controller → Service → Repository）

此 Controller 完整實作了三層式架構：
- **Controller**：接收 HTTP 請求、呼叫 Service、轉換 DTO → ViewModel、回傳 View
- **Service**：商業邏輯封裝（目前大部分為透傳，但預留了擴充空間）
- **Repository**：EF Core 資料存取、LINQ 查詢、DTO 投影

### 6.2 自訂授權過濾器（FunctionAttribute）

```csharp
// Controllers/ProductOrdersController.cs L22
[Function("edit_ProductOrders")]
```

`FunctionAttribute` 繼承自 `AuthorizeAttribute` 並實作 `IAsyncAuthorizationFilter`，在 Action 執行前檢查使用者的 Claims 中是否包含對應的 Function 名稱。這實現了**基於功能的細粒度權限控制**。

### 6.3 DTO 與 ViewModel 分離

本 Controller 嚴格區分：
- **DTO**（`ProductOrderDto`）：Service/Repository 層之間傳遞資料
- **ViewModel**（`ProductOrderViewModel`）：傳遞給 View 的顯示模型，包含 `[Display]`、`[DisplayFormat]` 等 DataAnnotation，以及計算屬性（如 `TotalAmount`、`StatusName`）

### 6.4 軟刪除策略

`DeleteAsync` 方法並非真正刪除資料列，而是將 `Status` 設為 3（已取消）：

```csharp
// Repositories/ProductOrderRepository.cs L261-268
public async Task DeleteAsync(int id)
{
    var order = await _context.ProductOrders.FindAsync(id);
    if (order != null)
    {
        order.Status = 3;  // 軟刪除：設為已取消
        await _context.SaveChangesAsync();
    }
}
```

### 6.5 Dashboard 的多次 DB 查詢

Dashboard Action 的 Repository 方法（`GetDashboardDataAsync`）在單一方法中執行了多次獨立的 DB 查詢：
- 本月/上月訂單量（2 次）
- 待出貨本月/上月（2 次）
- 爭議本月/上月（2 次）
- 趨勢資料（1 次）
- 縣市分布（1 次）
- 類別排行（1 次）
- 今日訂單（1 次）
- 待處理訂單（1 次）
- 不限月份的待出貨/爭議數量（2 次）

共計約 **13 次** DB 查詢。

### 6.6 PRG（Post-Redirect-Get）模式

`UpdateStatus` 和 `DeleteConfirmed` 均採用 PRG 模式：
1. POST 處理寫入操作
2. 設定 `TempData["SuccessMessage"]`（跨 Request 傳遞訊息）
3. `RedirectToAction()` 重導向到 GET 頁面
4. 避免使用者重新整理頁面時重複提交表單

### 6.7 防偽驗證（Anti-Forgery Token）

所有 POST Action 均標記 `[ValidateAntiForgeryToken]`，搭配 View 中的 `<form>` Tag Helper 自動產生的隱藏欄位，防止 CSRF 攻擊。

---

## 七、完整資料流圖

```
[瀏覽器] ──GET /ProductOrders/Index?status=0&searchString=王──→

    ┌─────────── Middleware Pipeline ───────────┐
    │ HTTPS Redirect → Static Files → Routing   │
    │ → Authentication (Cookie 解析)             │
    │ → Authorization                            │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── FunctionAttribute 授權檢查 ───────────┐
    │  檢查 User Claims 是否含                  │
    │  "Function" = "edit_ProductOrders"         │
    │  ├── 有權限 → 繼續執行 Action              │
    │  └── 無權限 → 403 ForbidResult            │
    └──────────────────┬────────────────────────┘
                       │ (有權限)
                       ▼
    ┌─── DI Container ─────────────────────────┐
    │  建立 MyFitnessCoachDbContext (Scoped)     │
    │  建立 ProductOrderRepository              │
    │  建立 ProductOrderService                 │
    │  建立 ProductOrdersController             │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── Controller: Index() ──────────────────┐
    │  呼叫 _service.GetAllAsync(status, search)│
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── Service: GetAllAsync() ───────────────┐
    │  呼叫 _repository.GetAllAsync(...)        │
    │  （目前為透傳，未來可擴充商業邏輯）         │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── Repository: GetAllAsync() ────────────┐
    │  1. 建立 IQueryable (Include Member/User) │
    │  2. Where(Status == 0)                    │
    │  3. Where(UserName.Contains("王")         │
    │         || Receiver.Contains("王"))        │
    │  4. OrderByDescending(CreateAt)           │
    │  5. Select → ProductOrderDto 投影          │
    │  6. ToListAsync() → 執行 SQL              │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── EF Core → SQL Server ─────────────────┐
    │  SELECT ... FROM ProductOrders            │
    │  JOIN Members JOIN Users                  │
    │  WHERE Status=0 AND (UserName LIKE '%王%' │
    │        OR Receiver LIKE '%王%')            │
    │  ORDER BY CreateAt DESC                   │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── Controller（續）──────────────────────┐
    │  ViewBag.CurrentStatus = 0                │
    │  ViewBag.CurrentSearch = "王"             │
    │  return View(orders)  // List<DTO>        │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── View: Index.cshtml ───────────────────┐
    │  @model IEnumerable<ProductOrderDto>      │
    │  - 篩選表單（狀態下拉、關鍵字搜尋）        │
    │  - 訂單表格（foreach 逐筆渲染）           │
    │  - 狀態 Badge 顏色對應                    │
    │  - 操作按鈕（詳情 / 刪除）                │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── HTTP Response ────────────────────────┐
    │  200 OK + HTML                            │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── Dispose（LIFO 順序）──────────────────┐
    │  Controller → Service → Repository → GC   │
    │  DbContext.Dispose() → 釋放 DB Connection │
    └──────────────────────────────────────────┘
```

---

## 八、涉及的關鍵檔案清單

| 檔案路徑                                                        | 用途                          | 行號重點                |
|---------------------------------------------------------------|------------------------------|------------------------|
| `Program.cs`                                                   | DI 註冊                       | L24-25（DbContext）, L28-29（Repository, Service） |
| `Controllers/ProductOrdersController.cs`                       | Controller                    | L14-19（建構子）, L22-31（Index）, L34-80（Dashboard）, L113-157（Details）, L160-173（UpdateStatus）, L176-205（Delete） |
| `Models/Services/ProductOrderService.cs`                       | Service 層                    | L10-15（建構子）, L17-20（GetAllAsync）, L37-43（UpdateStatusAsync） |
| `Repositories/ProductOrderRepository.cs`                       | Repository 層 + Interface     | L10-19（Interface）, L57-62（建構子）, L64-179（Dashboard查詢）, L181-211（GetAllAsync）, L213-249（GetByIdAsync）, L251-259（UpdateStatus）, L261-268（Delete/軟刪除） |
| `Models/EfModels/ProductOrder.cs`                              | Entity（訂單）                 | L8-35              |
| `Models/EfModels/ProductOrderDetail.cs`                        | Entity（訂單明細）              | L8-33              |
| `Models/DTOs/ProductOrderDto.cs`                               | DTO                           | L6-36              |
| `Models/DTOs/ProductOrderDashboardDto.cs`                      | Dashboard DTO                 | L6-41              |
| `Models/ViewModels/ProductOrderViewModel.cs`                   | ViewModel（含 StatusName）     | L7-94              |
| `Models/ViewModels/ProductOrderDashboardViewModel.cs`          | Dashboard ViewModel           | L7-66              |
| `Infra/FunctionAttribute.cs`                                   | 自訂授權過濾器                  | L11-40             |
| `Views/ProductOrders/Index.cshtml`                             | 訂單列表頁面                    | 全檔               |
| `Views/ProductOrders/Details.cshtml`                           | 訂單詳情頁面                    | 全檔               |
| `Views/ProductOrders/Dashboard.cshtml`                         | 統計看板（含 Chart.js）         | 全檔               |
| `Views/ProductOrders/MemberAllOrders.cshtml`                   | 會員訂單總覽                    | 全檔               |
| `Views/ProductOrders/Delete.cshtml`                            | 刪除確認頁面                    | 全檔               |

---

## 九、程式碼優化建議

### 9.1 Dashboard Repository 方法中多次獨立 DB 查詢

**問題：** `GetDashboardDataAsync()` 方法（Repository L64-179）在單一方法中執行了約 13 次獨立的 DB 查詢，每次查詢都是獨立的 `await`，無法並行執行。

**原因：** 各統計指標（本月訂單量、待出貨數、爭議數、趨勢、縣市分布等）分別查詢，且 EF Core 同一個 DbContext 不支援並行查詢。

**建議改法：** 將多個不依賴彼此結果的 Count 查詢合併為單一查詢：

```csharp
// 合併多個 Count 為一次查詢
var stats = await _context.ProductOrders
    .Where(o => o.CreateAt >= startOfMonth)
    .GroupBy(o => 1)
    .Select(g => new
    {
        Total = g.Count(),
        Pending = g.Count(o => o.Status == 0),
        Disputed = g.Count(o => o.Status == 4 || o.Status == 5 || o.Status == 6)
    })
    .FirstOrDefaultAsync();
```

### 9.2 Service 層目前大多為透傳

**問題：** `ProductOrderService` 中大部分方法僅直接呼叫 Repository 的同名方法並回傳結果，未包含額外的商業邏輯。

**原因：** 這是三層式架構的常見現象，Service 層預留了擴充空間。

**建議：** 目前架構合理，但可考慮在 `UpdateStatusAsync` 中加入狀態轉換驗證邏輯（如：只有「待處理」能轉為「已出貨」），使 Service 層更有價值：

```csharp
public async Task UpdateStatusAsync(int id, int newStatus)
{
    var order = await _repository.GetByIdAsync(id);
    if (!IsValidStatusTransition(order.Status, newStatus))
        throw new InvalidOperationException($"無法從狀態 {order.Status} 轉換到 {newStatus}");

    await _repository.UpdateStatusAsync(id, newStatus);
}
```

### 9.3 MemberAllOrders 預設 memberId 為 1

**問題：** `MemberAllOrders` 方法（L86）在未傳入 `id` 時預設為 `1`，這是測試用的硬編碼值。

```csharp
// L86
int memberId = id ?? 1;
```

**原因：** 開發階段的測試用程式碼未清除。

**建議改法：** 應在缺少 `id` 時回傳錯誤或重導向：

```csharp
if (id == null) return BadRequest("會員 ID 為必填參數");
int memberId = id.Value;
```

### 9.4 部分 Action 缺少 `[Function]` 或 `[Authorize]` 標記

**問題：** 僅 `Index` Action 標記了 `[Function("edit_ProductOrders")]`，其他 Action（`Dashboard`、`MemberAllOrders`、`Details`、`Delete`）均未標記任何授權特性，可能導致未授權使用者直接存取。

**建議改法：** 在 Controller 類別層級加上授權標記，或為每個 Action 加上適當的 `[Function]` 標記：

```csharp
[Authorize]
public class ProductOrdersController : Controller
{
    [Function("edit_ProductOrders")]
    public async Task<IActionResult> Index(...) { ... }

    [Function("view_ProductOrders")]
    public async Task<IActionResult> Dashboard() { ... }

    // ...
}
```

### 9.5 Index View 直接使用 DTO 而非 ViewModel

**問題：** `Index` Action 的 View Model 型別為 `IEnumerable<ProductOrderDto>`（DTO），而 `Details` 和 `MemberAllOrders` 則使用了 `ProductOrderViewModel`。這造成不一致。

**原因：** Index 頁面需要的欄位較少，開發時直接使用了 DTO。

**建議：** 統一使用 ViewModel 模式，或至少確保 DTO 不被直接傳遞到 View，以保持層級分離的一致性。

### 9.6 Repository 中 Exists 使用同步方法

**問題：** `Exists` 方法（Repository L271-274）使用了同步的 `Any()` 而非 `AnyAsync()`：

```csharp
public bool Exists(int id)
{
    return _context.ProductOrders.Any(e => e.Id == id);
}
```

**建議改法：** 改為非同步方法以避免執行緒阻塞：

```csharp
public async Task<bool> ExistsAsync(int id)
{
    return await _context.ProductOrders.AnyAsync(e => e.Id == id);
}
```
