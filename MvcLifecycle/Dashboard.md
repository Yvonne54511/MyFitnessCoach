# DashboardController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

## 一、全局架構概覽

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Browser (HTTP Request)                             │
│                     GET /Dashboard/Index?year=2025&month=3                       │
└─────────────────────────┬───────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          ASP.NET Core Middleware Pipeline                        │
│  ┌──────────────────┐ ┌──────────────────┐ ┌────────────────┐ ┌──────────────┐ │
│  │UseHttpsRedirection│→│ UseStaticFiles   │→│UseAuthentication│→│UseAuthorization│
│  └──────────────────┘ └──────────────────┘ └────────────────┘ └──────────────┘ │
│                                                                                 │
│  ┌──────────────────┐ ┌──────────────────────────────────────────────────────┐  │
│  │  UseRouting       │→│  MapControllerRoute("{controller}/{action}/{id?}")   │  │
│  └──────────────────┘ └──────────────────────────────────────────────────────┘  │
└─────────────────────────┬───────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        DI 容器建立物件鏈 (Scoped)                                │
│                                                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────┐   │
│  │ DashboardController                                                      │   │
│  │   ├── IDashboardService  → DashboardService                              │   │
│  │   │       └── IDashboardRepository → DashboardRepository                 │   │
│  │   │               └── MyFitnessCoachDbContext                            │   │
│  │   └── IKeyWordRepository → KeyWordRepository                             │   │
│  │           └── MyFitnessCoachDbContext (同一 Scoped 實例)                  │   │
│  └──────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────┬───────────────────────────────────────────────────────┘
                          │
                          ▼
┌───────────────────┐   ┌───────────────────┐   ┌───────────────────┐
│  Controller       │──▶│  Service 層        │──▶│  Repository 層    │
│  (Action 執行)    │   │  (商業邏輯)        │   │  (資料存取)       │
└───────────────────┘   └───────────────────┘   └────────┬──────────┘
                                                          │
                                                          ▼
                                                ┌───────────────────┐
                                                │  EF Core          │
                                                │  DbContext         │
                                                └────────┬──────────┘
                                                          │
                                                          ▼
                                                ┌───────────────────┐
                                                │  SQL Server       │
                                                │  (資料庫)         │
                                                └───────────────────┘
```

**DI 注入對象：**
- `IDashboardService` → 負責 Dashboard 彙總、評分、關鍵字頻率等商業邏輯
- `IKeyWordRepository` → 直接注入 Repository，用於 `CreateKeyWord` Action 新增關鍵字

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊（附行號）

```csharp
// Program.cs L50-51：Dashboard 模組
builder.Services.AddScoped<IDashboardRepository, DashboardRepository>();   // L50
builder.Services.AddScoped<IDashboardService, DashboardService>();         // L51

// Program.cs L89-90：KeyWord 模組
builder.Services.AddScoped<IKeyWordRepository, KeyWordRepository>();       // L89
builder.Services.AddScoped<IKeyWordService, KeyWordService>();             // L90

// Program.cs L24-25：DbContext 註冊
builder.Services.AddDbContext<MyFitnessCoachDbContext>(options =>           // L24
    options.UseSqlServer(...));                                             // L25

// Program.cs L119-129：Cookie Authentication
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)  // L119
    .AddCookie(options => { ... });                                                    // L120-129
```

### 2.2 生命週期範圍

| 服務                      | 生命週期   | 說明                                       |
| ------------------------- | ---------- | ------------------------------------------ |
| `IDashboardRepository`    | **Scoped** | 每次 HTTP Request 建立一個實例             |
| `IDashboardService`       | **Scoped** | 每次 HTTP Request 建立一個實例             |
| `IKeyWordRepository`      | **Scoped** | 每次 HTTP Request 建立一個實例             |
| `MyFitnessCoachDbContext` | **Scoped** | EF Core 預設為 Scoped，同一 Request 共用   |

### 2.3 DI 注入鏈（由下往上）

```
SQL Server
    ↑
MyFitnessCoachDbContext (Scoped)
    ↑                    ↑
DashboardRepository      KeyWordRepository
    ↑                         ↑
DashboardService              │ (直接注入 Controller)
    ↑                         │
DashboardController ──────────┘
```

### 2.4 建構子程式碼（附行號）

**DashboardController 建構子** (`Controllers/DashboardController.cs` L14-18)：
```csharp
// L11: private readonly IDashboardService _dashboardService;
// L12: private readonly Repositories.IKeyWordRepository _keyWordRepo;

// L14-18
public DashboardController(IDashboardService dashboardService, Repositories.IKeyWordRepository keyWordRepo)
{
    _dashboardService = dashboardService;
    _keyWordRepo = keyWordRepo;
}
```

**DashboardService 建構子** (`Services/DashboardService.cs` L20-23)：
```csharp
// L18: private readonly IDashboardRepository _dashboardRepository;

// L20-23
public DashboardService(IDashboardRepository dashboardRepository)
{
    _dashboardRepository = dashboardRepository;
}
```

**DashboardRepository 建構子** (`Repositories/DashboardRepository.cs` L34-38)：
```csharp
// L34: private readonly MyFitnessCoachDbContext _db;

// L36-39
public DashboardRepository(MyFitnessCoachDbContext db)
{
    _db = db;
}
```

**KeyWordRepository 建構子** (`Repositories/KeyWordRepository.cs` L18-23)：
```csharp
// L18: private readonly MyFitnessCoachDbContext _context;

// L20-23
public KeyWordRepository(MyFitnessCoachDbContext context)
{
    _context = context;
}
```

### 2.5 介面與實作對照表

| 介面                    | 實作類別              | 註冊位置         |
| ----------------------- | --------------------- | ---------------- |
| `IDashboardService`     | `DashboardService`    | Program.cs L51   |
| `IDashboardRepository`  | `DashboardRepository` | Program.cs L50   |
| `IKeyWordRepository`    | `KeyWordRepository`   | Program.cs L89   |

---

## 三、完整 Request 生命週期（以 `Index` Action 為例）

### 步驟 1：HTTP Request

```
使用者在瀏覽器輸入或點擊連結：
GET https://localhost:xxxx/Dashboard/Index?year=2025&month=3 HTTP/1.1
Cookie: MyFitnessCoach.Auth=<加密 Token>
```

- 瀏覽器發送 GET 請求，攜帶 Cookie 認證資訊

### 步驟 2：Middleware Pipeline

請求依序通過以下中介軟體（`Program.cs` L131-187）：

1. **UseExceptionHandler** (L136/142)：全域例外處理，出錯導向 `/Home/Error`
2. **UseStatusCodePagesWithReExecute** (L145)：處理 HTTP 狀態碼錯誤頁面
3. **UseHttpsRedirection** (L147)：強制 HTTPS
4. **UseStaticFiles** (L149-176)：靜態檔案處理（含 charset 設定）
5. **UseRouting** (L178)：路由中介軟體
6. **UseAuthentication** (L180)：Cookie 認證，解析 `MyFitnessCoach.Auth` Cookie → 建立 `ClaimsPrincipal`
7. **UseAuthorization** (L181)：授權檢查，DashboardController 標記 `[Authorize]`（L8），驗證使用者是否已登入

### 步驟 3：路由匹配

```
路由範本 (Program.cs L185-187):
"{controller=Account}/{action=Login}/{id?}"

匹配結果:
  controller = "Dashboard"
  action     = "Index"
  year       = 2025 (Query String)
  month      = 3    (Query String)
```

### 步驟 4：DI 容器建立物件鏈

ASP.NET Core 框架從 DI 容器解析 `DashboardController` 及其所有依賴：

```
1. 建立 MyFitnessCoachDbContext (Scoped，若該 Request 中尚未建立)
2. 建立 DashboardRepository(MyFitnessCoachDbContext)
3. 建立 DashboardService(IDashboardRepository)
4. 建立 KeyWordRepository(MyFitnessCoachDbContext)  ← 共用同一個 DbContext 實例
5. 建立 DashboardController(IDashboardService, IKeyWordRepository)
```

### 步驟 5：Controller Action 執行

**`DashboardController.Index`** (`Controllers/DashboardController.cs` L20-28)：

```csharp
// L20-28
public IActionResult Index(int? year, int? month)
{
    int y = year ?? DateTime.Now.Year;      // L22: 若未提供年份，預設當前年
    int m = month ?? DateTime.Now.Month;    // L23: 若未提供月份，預設當前月

    ViewBag.Title = "Dashboard 概覽";       // L25: 設定頁面標題
    var summary = _dashboardService.GetSummary(y, m);  // L26: 呼叫 Service 取得彙總
    return View(summary);                   // L27: 傳遞 ViewModel 到 View
}
```

### 步驟 6：Service 層商業邏輯

**`DashboardService.GetSummary`** (`Services/DashboardService.cs` L25-51)：

```csharp
// L25-51
public DashboardSummaryViewModel GetSummary(int year, int month)
{
    return new DashboardSummaryViewModel
    {
        TotalUsers = _dashboardRepository.GetTotalUsers(),                    // L29
        ActiveUsers = _dashboardRepository.GetActiveUsers(),                  // L30
        PendingUsers = _dashboardRepository.GetPendingUsers(),                // L31
        ActiveRoles = _dashboardRepository.GetActiveRoles(),                  // L32
        ActiveFunctions = _dashboardRepository.GetActiveFunctions(),          // L33
        ActiveInstructors = _dashboardRepository.GetActiveInstructors(),      // L34
        MonthlyOrdersCount = _dashboardRepository.GetMonthlyOrdersCount(year, month),  // L36
        MonthlyRevenue = _dashboardRepository.GetMonthlyRevenue(year, month),          // L37
        MonthlyReviewsCount = _dashboardRepository.GetMonthlyReviewsCount(year, month),// L38
        MonthlyActiveMembers = _dashboardRepository.GetMonthlyActiveMembers(year, month),// L39
        YearlyOrdersCount = _dashboardRepository.GetMonthlyOrdersCount(year, 0),       // L41
        YearlyRevenue = _dashboardRepository.GetMonthlyRevenue(year, 0),               // L42
        YearlyReviewsCount = _dashboardRepository.GetMonthlyReviewsCount(year, 0),     // L43
        YearlyActiveMembers = _dashboardRepository.GetMonthlyActiveMembers(year, 0),   // L44
        MonthlyRevenueTrend = _dashboardRepository.GetMonthlyRevenueTrendData(year),   // L46
        SelectedYear = year,                                                           // L48
        SelectedMonth = month                                                          // L49
    };
}
```

**設計特點：** Service 層負責組裝 ViewModel，將多個 Repository 方法的回傳值聚合為單一 ViewModel。`month = 0` 作為「年度累計」的旗標。

### 步驟 7：Repository 層資料存取

**`DashboardRepository`** (`Repositories/DashboardRepository.cs`)：

以 `GetMonthlyRevenue` 為例 (L55-70)：

```csharp
// L55-70
public decimal GetMonthlyRevenue(int year, int month)
{
    decimal pRev = _db.ProductOrders
        .Where(x => x.CreateAt.Year == year && (month == 0 || x.CreateAt.Month == month))
        .Sum(x => (decimal?)(x.OriginalAmount - x.DiscountAmount)) ?? 0;  // L57-59

    decimal rRev = _db.ReserveOrders
        .Where(x => x.CreateAt.Year == year && (month == 0 || x.CreateAt.Month == month))
        .Sum(x => (decimal?)x.Price) ?? 0;                                // L61-63

    decimal ptRev = _db.PointOrders
        .Where(x => x.CreateAt.Year == year && (month == 0 || x.CreateAt.Month == month))
        .Sum(x => (decimal?)x.DiscountedPrice) ?? 0;                      // L65-67

    return pRev + rRev + ptRev;                                            // L69
}
```

**設計特點：** 合併三種訂單類型（ProductOrders、ReserveOrders、PointOrders）的營收計算。使用 `(decimal?)` 避免空集合造成的 `InvalidOperationException`。

### 步驟 8：EF Core → SQL Server

EF Core 將 LINQ 查詢轉為 SQL 語句，例如 `GetTotalUsers()`：

```sql
-- 示意 SQL (由 EF Core 產生)
SELECT COUNT(*) FROM [Users]
SELECT COUNT(*) FROM [Users] WHERE [IsActive] = 1
SELECT SUM([OriginalAmount] - [DiscountAmount]) FROM [ProductOrders] WHERE YEAR([CreateAt]) = @year AND MONTH([CreateAt]) = @month
-- ... 等多筆查詢
```

### 步驟 9：View 渲染

框架將 `DashboardSummaryViewModel` 傳入 `Views/Dashboard/Index.cshtml`：

- **Model 型別**：`@model Project_MyFitnessCoach.Models.ViewModel.DashboardSummaryViewModel`
- **Partial View**：引入 `_DashboardFilter` 年月篩選元件
- **前端圖表**：使用 Chart.js 繪製年度營收趨勢折線圖，資料透過 `@Html.Raw(Json.Serialize(Model.MonthlyRevenueTrend))` 序列化注入 JavaScript
- **系統概況**：顯示角色數、功能模組數、管理員資訊

### 步驟 10：HTTP Response

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<html>
  <!-- 完整 HTML 頁面，包含 Dashboard 資料卡片 + Chart.js 圖表 -->
</html>
```

### 步驟 11：Scoped 物件 Dispose

Request 結束後，DI 容器依序 Dispose：
1. `DashboardController`
2. `DashboardService`
3. `DashboardRepository`
4. `KeyWordRepository`
5. `MyFitnessCoachDbContext`（釋放資料庫連線回 Connection Pool）

---

## 四、其他 Action 生命週期

### 4.1 `Rating` Action (`Controllers/DashboardController.cs` L30-48)

```csharp
// L30-48
public IActionResult Rating(int? year, int? month)
{
    int y = year ?? DateTime.Now.Year;
    int m = month ?? DateTime.Now.Month;

    ViewBag.Title = "營養師評分統計";
    var ratings = _dashboardService.GetInstructorRatings(y, m);
    var yearlyRatings = _dashboardService.GetInstructorRatings(y, 0);
    var globalRating = _dashboardService.GetGlobalRating(y, m);
    var viewModel = new InstructorRatingViewModel
    {
        InstructorRatings = ratings,
        YearlyInstructorRatings = yearlyRatings,
        GlobalRating = globalRating,
        SelectedYear = y,
        SelectedMonth = m
    };
    return View(viewModel);
}
```

**與 Index 的差異：**
- **呼叫不同 Service 方法**：`GetInstructorRatings()` 和 `GetGlobalRating()`
- **ViewModel 不同**：使用 `InstructorRatingViewModel`（組合月度 + 年度評分 + 全體評分）
- **Repository 邏輯更複雜**：`GetInstructorRatings()` (L200-283) 包含情感分析算法：
  - 基礎分（星等評分轉分數）
  - 關鍵字加權（正向/負向詞語匹配 + 權重計算）
  - 長字詞優先匹配（避免「不專業」被「專業」重複計算）
- **View 更豐富**：`Rating.cshtml` 包含 Chart.js 圓餅圖 + 堆疊長條圖 + 排名 Modal + Accordion 評論明細

### 4.2 `KeyWordAnalytics` Action (`Controllers/DashboardController.cs` L50-59)

```csharp
// L50-59
public IActionResult KeyWordAnalytics(int? year, int? month)
{
    int y = year ?? DateTime.Now.Year;
    int m = month ?? DateTime.Now.Month;

    ViewBag.Title = "評論關鍵字詞分析";
    var data = _dashboardService.GetKeyWordFrequencies(y, m);
    ViewBag.SelectedYear = y;
    ViewBag.SelectedMonth = m;
    return View(data);
}
```

**與 Index 的差異：**
- **呼叫 `GetKeyWordFrequencies()`**：Repository 中最複雜的方法 (L104-198)
  - 統計資料庫已有關鍵字的出現次數
  - N-Gram 演算法挖掘新的高頻詞彙（2~5 字元）
  - 停用詞過濾 + 本地忽略清單
  - 冗餘子字串過濾
- **直接傳遞 DTO 集合**：Model 型別為 `IEnumerable<KeyWordFrequencyDto>`，不包裝為 ViewModel
- **使用 ViewBag 傳遞年月參數**：而非放入 Model

### 4.3 `CreateKeyWord` Action (`Controllers/DashboardController.cs` L62-84)

```csharp
// L62-84
[HttpPost]
public async Task<IActionResult> CreateKeyWord(string word, int category, int weight)
{
    if (string.IsNullOrEmpty(word)) return BadRequest("字詞不能為空");

    if (category == 0)
    {
        string filePath = Path.Combine(Directory.GetCurrentDirectory(), "ignored_words.txt");
        await System.IO.File.AppendAllLinesAsync(filePath, new[] { word });
        return Ok(new { success = true, message = $"已將「{word}」加入本地忽略清單" });
    }

    var keyWord = new Models.EfModels.KeyWord { Word = word, Category = category, Weight = weight };
    await _keyWordRepo.CreateAsync(keyWord);
    return Ok(new { success = true, message = $"已成功將「{word}」加入關鍵字庫" });
}
```

**與 Index 的差異：**
- **HTTP 方法**：`[HttpPost]`，由前端 AJAX 呼叫
- **非同步方法**：使用 `async Task<IActionResult>`
- **回傳 JSON**：使用 `Ok(new { ... })`，而非 `View()`
- **直接使用 Repository**：跳過 Service 層，直接呼叫 `_keyWordRepo.CreateAsync()`
- **雙重儲存策略**：category == 0 時寫入本地文字檔 `ignored_words.txt`；否則存入資料庫
- **無 `[ValidateAntiForgeryToken]`**：因為是 AJAX 呼叫

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── DashboardController.cs
├── Services/
│   └── DashboardService.cs              (IDashboardService + DashboardService)
├── Repositories/
│   ├── DashboardRepository.cs           (IDashboardRepository + DashboardRepository)
│   └── KeyWordRepository.cs             (IKeyWordRepository + KeyWordRepository)
├── Models/
│   ├── EfModels/
│   │   ├── MyFitnessCoachDbContext.cs
│   │   └── KeyWord.cs                   (Entity)
│   ├── ViewModel/
│   │   └── DashboardSummaryViewModel.cs
│   ├── ViewModels/
│   │   └── InstructorRatingViewModel.cs
│   └── DTOs/
│       ├── InstructorRatingDto.cs
│       ├── GlobalRatingDto.cs
│       ├── KeyWordFrequencyDto.cs
│       └── ReviewSentimentDto.cs
├── Views/
│   └── Dashboard/
│       ├── Index.cshtml
│       ├── Rating.cshtml
│       └── KeyWordAnalytics.cshtml
├── Views/Shared/
│   └── _DashboardFilter.cshtml          (Partial View)
└── Program.cs
```

### 5.2 Entity 關聯鏈

```
DashboardRepository 直接存取的 DbSet：
├── Users           → 會員總數、活躍/待審核統計
├── Roles           → 角色數量統計
├── Functions       → 功能模組數量統計
├── Instructors     → 營養師數量統計
│   ├── .User       → 營養師的使用者資訊（姓名）
│   └── .Reviews    → 營養師收到的評論
│       └── .Member → 評論者的會員資訊
│           └── .User → 評論者的使用者名稱
├── ProductOrders   → 商品訂單（營收、訂單數）
├── ReserveOrders   → 預約訂單（營收、訂單數）
├── PointOrders     → 點數訂單（營收、訂單數）
├── Reviews         → 評論統計、情感分析
└── KeyWords        → 關鍵字詞庫（情感分析用）
```

---

## 六、重要概念總整理

### 6.1 `[Authorize]` 全 Controller 認證

```csharp
[Authorize]  // DashboardController.cs L8
public class DashboardController : Controller
```

- 所有 Action 都需要使用者登入
- 未登入時，Cookie Authentication 自動導向 `/Account/Login` (Program.cs L123)
- 此 Controller **未使用** `[Function]` 權限控制，表示任何已登入使用者皆可存取 Dashboard

### 6.2 混合模型情感分析（Rating Action）

Repository 中的情感分析採用「星等基礎分 + 關鍵字加權」的混合模型：

1. **基礎分**：Rating >= 4 → +2 分；Rating <= 2 → -2 分；Rating == 3 → 0 分
2. **關鍵字加權**：依照 KeyWords 資料表中的正向/負向分類及權重值計算
3. **長字詞優先匹配**：`sortedAllKeywords = keyWords.OrderByDescending(k => k.Word.Length)` 確保「不專業」先於「專業」匹配
4. **已匹配字詞替換為空白**：避免短字詞重複計算

### 6.3 N-Gram 高頻詞挖掘（KeyWordAnalytics Action）

`GetKeyWordFrequencies` 方法實現自動化的文字探勘：

1. **已知關鍵字統計**：統計資料庫中已分類關鍵字在評論中的出現次數
2. **N-Gram 滑動窗口**：對每則評論切割後，以長度 2~5 的滑動窗口產生候選字詞
3. **停用詞過濾**：內建 37 個常用中文停用詞 + 本地 `ignored_words.txt` 的手動忽略清單
4. **頻率門檻**：出現次數 >= 5 次的新詞彙才進入候選
5. **冗餘子字串過濾**：若短字詞已被更長的字詞包含且次數接近（>= 90%），則排除

### 6.4 Controller 直接注入 Repository

`DashboardController` 同時注入了 `IDashboardService` 和 `IKeyWordRepository`，這是一種特殊設計：
- `CreateKeyWord` Action 直接呼叫 Repository，跳過 Service 層
- 原因：該 Action 的邏輯簡單（直接建立實體），不需要額外的商業邏輯層
- 但這違反了三層式架構的一致性原則（詳見第九章建議）

### 6.5 雙重儲存策略

`CreateKeyWord` 中 category == 0（忽略）時，字詞存入本地檔案 `ignored_words.txt` 而非資料庫。這是因為忽略的字詞不屬於分析用的關鍵字，僅用於過濾 N-Gram 結果。

---

## 七、完整資料流圖

### 7.1 Index Action 資料流

```
Browser                    Controller              Service                   Repository               EF Core / DB
  │                           │                       │                          │                        │
  │  GET /Dashboard/Index     │                       │                          │                        │
  │ ─────────────────────────▶│                       │                          │                        │
  │                           │  GetSummary(y, m)     │                          │                        │
  │                           │──────────────────────▶│                          │                        │
  │                           │                       │  GetTotalUsers()         │                        │
  │                           │                       │─────────────────────────▶│  SELECT COUNT(*)       │
  │                           │                       │                          │──────────────────────▶ │
  │                           │                       │                          │◀────── count ──────── │
  │                           │                       │◀───────── int ──────────│                        │
  │                           │                       │                          │                        │
  │                           │                       │  GetMonthlyRevenue(y,m)  │                        │
  │                           │                       │─────────────────────────▶│  SELECT SUM(...)       │
  │                           │                       │                          │──────────────────────▶ │
  │                           │                       │                          │◀────── decimal ─────  │
  │                           │                       │◀───────── decimal ──────│                        │
  │                           │                       │                          │                        │
  │                           │                       │  ... (多次 Repository 呼叫)                       │
  │                           │                       │                          │                        │
  │                           │◀─ DashboardSummary ──│                          │                        │
  │                           │    ViewModel           │                          │                        │
  │                           │                       │                          │                        │
  │                           │  return View(summary)  │                          │                        │
  │                           │  → Razor 引擎渲染      │                          │                        │
  │ ◀──── HTML Response ─────│                       │                          │                        │
  │                           │                       │                          │                        │
```

### 7.2 CreateKeyWord Action 資料流

```
Browser (AJAX)             Controller                KeyWordRepository          EF Core / DB
  │                           │                          │                        │
  │  POST /Dashboard/         │                          │                        │
  │  CreateKeyWord            │                          │                        │
  │  {word,category,weight}   │                          │                        │
  │ ─────────────────────────▶│                          │                        │
  │                           │                          │                        │
  │                           │─ if category == 0 ──────▶│ (寫入本地檔案)         │
  │                           │                          │ ignored_words.txt      │
  │ ◀── JSON { success } ────│                          │                        │
  │                           │                          │                        │
  │                           │─ if category != 0 ──────▶│                        │
  │                           │  CreateAsync(entity)     │  INSERT INTO KeyWords  │
  │                           │                          │──────────────────────▶ │
  │                           │                          │◀────── OK ────────── │
  │ ◀── JSON { success } ────│◀──────── Task ──────────│                        │
  │                           │                          │                        │
```

---

## 八、涉及的關鍵檔案清單

| 檔案路徑                                                           | 角色               | 說明                                     |
| ------------------------------------------------------------------ | ------------------ | ---------------------------------------- |
| `Controllers/DashboardController.cs`                               | Controller         | 4 個 Action：Index、Rating、KeyWordAnalytics、CreateKeyWord |
| `Services/DashboardService.cs`                                     | Service (介面+實作) | 商業邏輯：彙總、評分、關鍵字頻率         |
| `Repositories/DashboardRepository.cs`                              | Repository (介面+實作) | 資料存取：使用者統計、營收、評論情感分析、N-Gram 詞頻 |
| `Repositories/KeyWordRepository.cs`                                | Repository (介面+實作) | 關鍵字 CRUD 資料存取                     |
| `Models/ViewModel/DashboardSummaryViewModel.cs`                    | ViewModel          | Dashboard 首頁彙總資料模型               |
| `Models/ViewModels/InstructorRatingViewModel.cs`                   | ViewModel          | 營養師評分頁面資料模型                   |
| `Models/DTOs/InstructorRatingDto.cs`                               | DTO                | 營養師評分資料傳輸物件                   |
| `Models/DTOs/GlobalRatingDto.cs`                                   | DTO                | 全體評分資料傳輸物件                     |
| `Models/DTOs/KeyWordFrequencyDto.cs`                               | DTO                | 關鍵字頻率資料傳輸物件                   |
| `Models/DTOs/ReviewSentimentDto.cs`                                | DTO                | 評論情感分析結果傳輸物件                 |
| `Models/EfModels/KeyWord.cs`                                       | Entity             | KeyWord 資料表實體                       |
| `Models/EfModels/MyFitnessCoachDbContext.cs`                       | DbContext          | EF Core 資料庫上下文                     |
| `Views/Dashboard/Index.cshtml`                                     | View               | Dashboard 首頁（含 Chart.js 折線圖）     |
| `Views/Dashboard/Rating.cshtml`                                    | View               | 營養師評分統計（含圓餅圖、堆疊長條圖、排名 Modal） |
| `Views/Dashboard/KeyWordAnalytics.cshtml`                          | View               | 關鍵字詞分析（含橫向長條圖、篩選、快速歸類 Modal） |
| `Views/Shared/_DashboardFilter.cshtml`                             | Partial View       | 年度/月份篩選元件（共用）                |
| `Program.cs`                                                       | 啟動設定           | DI 註冊、Middleware、路由設定            |

---

## 九、程式碼優化建議

### 9.1 Controller 直接注入 Repository 違反分層原則

**問題：** `DashboardController` 直接注入 `IKeyWordRepository` 並在 `CreateKeyWord` Action 中直接呼叫 Repository，跳過 Service 層。

**原因：** 三層式架構的原則是 Controller 只與 Service 溝通，Service 封裝商業邏輯後再呼叫 Repository。直接注入 Repository 會導致：
- 若未來 `CreateKeyWord` 需要驗證邏輯（如重複字詞檢查），改動會發生在 Controller 層
- 與專案中其他 Controller（如 KeyWordsController）的架構風格不一致

**建議改法：** 將 `CreateKeyWord` 的邏輯移至 `IKeyWordService`，Controller 改為注入 `IKeyWordService`：

```csharp
// DashboardController 改為：
private readonly IDashboardService _dashboardService;
private readonly IKeyWordService _keyWordService;

// CreateKeyWord Action 改為呼叫：
await _keyWordService.CreateAsync(new KeyWordDto { Word = word, Category = category, Weight = weight });
```

### 9.2 `CreateKeyWord` 缺少 AntiForgeryToken 驗證

**問題：** `CreateKeyWord` 是 `[HttpPost]` 但未標記 `[ValidateAntiForgeryToken]`（對比 `KeyWordsController.Create` 在 L44 有此標記）。

**原因：** 缺少 CSRF 防護，攻擊者可以構造惡意頁面讓已登入使用者不知情地新增關鍵字。

**建議改法：** 前端 AJAX 呼叫時加入 AntiForgeryToken，Controller Action 加上 `[ValidateAntiForgeryToken]`：

```csharp
[HttpPost]
[ValidateAntiForgeryToken]
public async Task<IActionResult> CreateKeyWord(string word, int category, int weight)
```

### 9.3 `GetSummary` 方法的 N+1 查詢問題

**問題：** `DashboardService.GetSummary` 一次性呼叫了 14 個 Repository 方法（L29-49），每個方法各自發送 SQL 查詢，共產生 14+ 次資料庫往返。

**原因：** 每次 DB 往返都有網路延遲，Dashboard 首頁載入時間會因此拉長。

**建議改法：** 考慮將多個統計查詢合併為一次查詢或使用 Stored Procedure，或至少將「月度」與「年度」使用的相同方法（如 `GetMonthlyOrdersCount` 被呼叫兩次）進行結果快取：

```csharp
// 例如可以在 Repository 加入一個方法同時回傳月度和年度統計
public (MonthlyStats monthly, YearlyStats yearly) GetAllStats(int year, int month);
```

### 9.4 `GetKeyWordFrequencies` 方法過長且職責混亂

**問題：** `DashboardRepository.GetKeyWordFrequencies` (L104-198) 長達 94 行，包含：資料查詢、停用詞過濾、N-Gram 演算法、冗餘子字串過濾等多種邏輯。

**原因：** Repository 層的職責應僅限於資料存取，N-Gram 演算法屬於商業邏輯，應放在 Service 層。方法過長也降低可讀性和可測試性。

**建議改法：**
1. Repository 僅負責 `GetReviewComments(year, month)` 和 `GetAllKeyWords()`
2. Service 層負責 N-Gram 演算法和頻率統計
3. 將 N-Gram 演算法抽取為獨立的 Helper 或 Strategy 類別

### 9.5 本地檔案寫入缺少並發保護

**問題：** `CreateKeyWord` 中 `File.AppendAllLinesAsync` (L71) 直接寫入檔案，若多個請求同時到達可能產生檔案鎖定衝突。

**原因：** ASP.NET Core 是多執行緒環境，多個 Request 可能同時寫入同一檔案。

**建議改法：** 使用 `SemaphoreSlim` 或 `ConcurrentQueue` 確保寫入序列化，或改為將忽略清單也存入資料庫（新增 Category = 0 的記錄，但查詢時排除）。

### 9.6 `GetMonthlyRevenueTrendData` 的記憶體效率

**問題：** `GetMonthlyRevenueTrendData` (L87-102) 將三張訂單表的全年資料 `.ToList()` 載入記憶體後再做分組統計。

**原因：** 若訂單量龐大，會消耗大量記憶體。

**建議改法：** 在資料庫端完成分組彙總：

```csharp
var trend = _db.ProductOrders
    .Where(x => x.CreateAt.Year == year)
    .GroupBy(x => x.CreateAt.Month)
    .Select(g => new { Month = g.Key, Revenue = g.Sum(x => x.OriginalAmount - x.DiscountAmount) })
    .ToList();
```
