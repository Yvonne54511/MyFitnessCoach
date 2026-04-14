# ReservationController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

## 一、全局架構概覽

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Browser (HTTP Request)                       │
│              GET /Reservation/Index?startDate=&endDate=               │
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
│            匹配 → ReservationController.Index(...)                   │
└──────────────────────────────┬────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   DI Container 建立物件鏈                             │
│                                                                      │
│  MyFitnessCoachDbContext (Scoped)                                     │
│          ↓ 注入                                                      │
│  ReservationRepository : IReservationRepository (Scoped)             │
│          ↓ 注入                                                      │
│  ReservationService (Scoped)                                         │
│          ↓ 注入                                                      │
│  ReservationController                                               │
└──────────────────────────────┬────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│               ReservationController (Action 執行)                     │
│  [Authorize] ─── Cookie 驗證 + InstructorId Claim 檢查               │
│                      ↓ 呼叫                                          │
│              ReservationService (商業邏輯層)                          │
│                      ↓ 呼叫                                          │
│      ReservationRepository : IReservationRepository (資料存取層)      │
│                      ↓ 操作                                          │
│              EF Core (MyFitnessCoachDbContext)                        │
│                      ↓ SQL                                           │
│              SQL Server 資料庫                                        │
└──────────────────────────────┬────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    View 渲染 (Razor Engine)                           │
│    Views/Reservation/Index.cshtml | Edit.cshtml                      │
│    Model: IEnumerable<ReservationViewModel> | ReservationViewModel   │
└──────────────────────────────┬────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      HTTP Response (HTML)                             │
└─────────────────────────────────────────────────────────────────────┘
```

**架構特點：此 Controller 採用完整的三層式架構（Controller → Service → Repository → EF Core）。Controller 類別層級標記了 `[Authorize]`，所有 Action 皆需登入才能存取。此外，每個 Action 會額外檢查使用者的 `InstructorId` Claim，確保講師只能查看/編輯自己的預約班表。Service 位於 `Services/` 目錄下（非 `Models/Services/`）。**

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊

```csharp
// Program.cs L64-66
// 註冊 Reservation 模組
builder.Services.AddScoped<IReservationRepository, ReservationRepository>();
builder.Services.AddScoped<ReservationService>();

// Program.cs L24-25（DbContext 共用）
builder.Services.AddDbContext<MyFitnessCoachDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Program.cs L119-129（Cookie Authentication，本 Controller 依賴此驗證機制）
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.Cookie.Name = "MyFitnessCoach.Auth";
        options.LoginPath = "/Account/Login";
        options.AccessDeniedPath = "/Home/Error/403";
        options.Cookie.HttpOnly = true;
        options.Cookie.SameSite = SameSiteMode.Lax;
        options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    });
```

### 2.2 生命週期範圍

| 註冊項目                      | 生命週期   | 說明                                     |
|-----------------------------|-----------|------------------------------------------|
| `MyFitnessCoachDbContext`   | **Scoped** | `AddDbContext<T>()` 預設為 Scoped          |
| `IReservationRepository`    | **Scoped** | Program.cs L65，每個 Request 一個實例       |
| `ReservationService`        | **Scoped** | Program.cs L66，每個 Request 一個實例       |

### 2.3 DI 注入鏈（由下往上）

```
SQL Server
   ↑
MyFitnessCoachDbContext (Scoped) ─── AddDbContext L24-25
   ↑ 注入
ReservationRepository : IReservationRepository (Scoped) ─── L65
   ↑ 注入
ReservationService (Scoped) ─── L66
   ↑ 注入
ReservationController
```

### 2.4 建構子程式碼

**Controller 建構子：**
```csharp
// Controllers/ReservationController.cs L18-22
private readonly ReservationService _reservationService;

public ReservationController(ReservationService reservationService)
{
    _reservationService = reservationService;
}
```

**Service 建構子：**
```csharp
// Services/ReservationService.cs L11-16
private readonly IReservationRepository _repository;

public ReservationService(IReservationRepository repository)
{
    _repository = repository;
}
```

**Repository 建構子：**
```csharp
// Repositories/ReservationRepository.cs L20-25
private readonly MyFitnessCoachDbContext _context;

public ReservationRepository(MyFitnessCoachDbContext context)
{
    _context = context;
}
```

### 2.5 介面與實作對照表

| 介面                         | 實作類別                   | 註冊位置         |
|-----------------------------|---------------------------|-----------------|
| `IReservationRepository`     | `ReservationRepository`   | Program.cs L65  |
| （無介面，直接註冊具體類別）    | `ReservationService`      | Program.cs L66  |

---

## 三、完整 Request 生命週期（以 Index Action 為例）

### 步驟 1：HTTP Request

```
GET /Reservation/Index?startDate=2026-03-01&endDate=2026-03-31 HTTP/1.1
Host: localhost:xxxx
Cookie: MyFitnessCoach.Auth=<加密Cookie包含InstructorId Claim>
```

講師在預約班表頁面選擇日期範圍後點擊「篩選」，表單透過 `method="get"` 發送 GET 請求。

### 步驟 2：Middleware Pipeline

請求依序通過以下 Middleware（對應 Program.cs L147-181）：

```
UseHttpsRedirection()    → L147：HTTP 重導至 HTTPS
UseStaticFiles()         → L149-176：靜態檔案處理
UseRouting()             → L178：路由匹配
UseAuthentication()      → L180：解析 Cookie，還原 ClaimsPrincipal
UseAuthorization()       → L181：檢查 [Authorize] 標記
```

**重點：**
1. `UseAuthentication()` 解析 Cookie `MyFitnessCoach.Auth`，還原使用者身份（包含 `InstructorId` 等 Claims）
2. `UseAuthorization()` 檢查 Controller 類別層級的 `[Authorize]`，若未登入則重導向至 `/Account/Login`

### 步驟 3：路由匹配

```csharp
// Program.cs L185-187
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Account}/{action=Login}/{id?}");
```

路由引擎將 URL `/Reservation/Index` 解析為：
- **Controller** = `Reservation` → `ReservationController`
- **Action** = `Index` → `Index(DateOnly? startDate, DateOnly? endDate)`
- Query String `startDate=2026-03-01` 和 `endDate=2026-03-31` 透過 Model Binding 綁定為 `DateOnly?` 型別

### 步驟 4：DI 容器建立物件鏈

```
1. DI 容器收到建立 ReservationController 的請求
2. 檢查建構子需要 ReservationService
3. ReservationService 建構子需要 IReservationRepository
4. IReservationRepository 解析為 ReservationRepository
5. ReservationRepository 建構子需要 MyFitnessCoachDbContext
6. 從 Scoped 容器取得（或建立）MyFitnessCoachDbContext
7. 依序建立 Repository → Service → Controller
```

### 步驟 5：Controller Action 執行

```csharp
// Controllers/ReservationController.cs L26-53
[Authorize]
public async Task<IActionResult> Index(DateOnly? startDate, DateOnly? endDate)
{
    // L29-33：從 Claims 取得 InstructorId，驗證講師身份
    var instructorIdClaim = User.FindFirst("InstructorId")?.Value;
    if (string.IsNullOrEmpty(instructorIdClaim) || !int.TryParse(instructorIdClaim, out int instructorId) || instructorId == 0)
    {
        return Forbid();  // 非講師角色 → 403
    }

    // L35：呼叫 Service 取得已被預約的班表
    var bookedShifts = await _reservationService.GetBookedShiftsAsync(instructorId, startDate, endDate);

    // L38-47：DTO 轉換為 ViewModel
    var vms = bookedShifts.Select(d => new ReservationViewModel
    {
        Id = d.Id,
        InstructorName = d.InstructorName,
        MemberName = d.MemberName ?? "未知名稱",
        ScheduleDate = d.ScheduleDate,
        TimeSlot = d.TimeSlot,
        Target = d.Target,
        Memorandum = d.Memorandum
    }).ToList();

    // L49-50：將日期範圍存入 ViewBag 供 View 回顯
    ViewBag.StartDate = startDate?.ToString("yyyy-MM-dd");
    ViewBag.EndDate = endDate?.ToString("yyyy-MM-dd");

    // L52：傳遞 ViewModel 清單給 View
    return View(vms);
}
```

### 步驟 6：Service 層商業邏輯

```csharp
// Services/ReservationService.cs L18-28
public async Task<List<ReservationDto>> GetBookedShiftsAsync(
    int instructorId, DateOnly? startDate = null, DateOnly? endDate = null)
{
    // L20-26：建立查詢條件物件，設定預設日期範圍
    var criteria = new ShiftQueryCriteria
    {
        InstructorId = instructorId,
        StartDate = startDate ?? DateOnly.FromDateTime(DateTime.Today.AddMonths(-1)),  // 預設往前一個月
        EndDate = endDate ?? DateOnly.FromDateTime(DateTime.Today.AddMonths(2)),        // 預設往後兩個月
        IsBooked = true  // 只查已預約的班表
    };
    // L27：呼叫 Repository
    return await _repository.GetByCriteriaAsync(criteria);
}
```

**Service 層的重要職責：**
- 設定預設日期範圍（前 1 個月到後 2 個月）
- 強制 `IsBooked = true`（業務規則：講師只看已被預約的班表）
- 封裝查詢條件為 `ShiftQueryCriteria` 物件

### 步驟 7：Repository 層資料存取

```csharp
// Repositories/ReservationRepository.cs L27-72
public async Task<List<ReservationDto>> GetByCriteriaAsync(ShiftQueryCriteria criteria)
{
    // L29-35：建立基礎查詢，多層 Include
    var query = _context.Shifts
        .Include(s => s.Instructor).ThenInclude(i => i.User)
        .Include(s => s.ReserveOrders).ThenInclude(ro => ro.Member).ThenInclude(m => m.User)
        .AsQueryable();

    // L37-40：依講師篩選
    if (criteria.InstructorId.HasValue)
        query = query.Where(x => x.InstructorId == criteria.InstructorId.Value);

    // L42-45：依起始日期篩選
    if (criteria.StartDate.HasValue)
        query = query.Where(x => x.ScheduleDate >= criteria.StartDate.Value);

    // L47-50：依結束日期篩選
    if (criteria.EndDate.HasValue)
        query = query.Where(x => x.ScheduleDate <= criteria.EndDate.Value);

    // L52-55：依是否已預約篩選
    if (criteria.IsBooked.HasValue)
        query = query.Where(x => x.IsBooked == criteria.IsBooked.Value);

    // L57-71：投影為 ReservationDto
    return await query
        .Select(s => new ReservationDto
        {
            Id = s.Id,
            InstructorId = s.InstructorId,
            InstructorName = s.Instructor.User.UserName,
            ScheduleDate = s.ScheduleDate,
            TimeSlot = s.TimeSlot,
            IsBooked = s.IsBooked,
            MemberName = s.ReserveOrders.Select(ro => ro.Member.User.UserName).FirstOrDefault(),
            MemberId = s.ReserveOrders.Select(ro => ro.MemberId).FirstOrDefault(),
            Target = s.ReserveOrders.Select(ro => ro.Target).FirstOrDefault(),
            Memorandum = s.ReserveOrders.Select(ro => ro.Memorandum).FirstOrDefault()
        })
        .ToListAsync();
}
```

### 步驟 8：EF Core → SQL Server

EF Core 將 LINQ 轉換為 SQL，範例（instructorId=3, startDate=2026-03-01, endDate=2026-03-31, isBooked=true）：

```sql
SELECT [s].[Id], [s].[InstructorId],
       [u].[UserName] AS [InstructorName],
       [s].[ScheduleDate], [s].[TimeSlot], [s].[IsBooked],
       (SELECT TOP(1) [u1].[UserName] FROM [ReserveOrders] AS [r]
        INNER JOIN [Members] AS [m] ON [r].[MemberId] = [m].[Id]
        INNER JOIN [Users] AS [u1] ON [m].[UserId] = [u1].[Id]
        WHERE [s].[Id] = [r].[ShiftId]) AS [MemberName],
       (SELECT TOP(1) [r0].[MemberId] FROM [ReserveOrders] AS [r0]
        WHERE [s].[Id] = [r0].[ShiftId]) AS [MemberId],
       (SELECT TOP(1) [r1].[Target] FROM [ReserveOrders] AS [r1]
        WHERE [s].[Id] = [r1].[ShiftId]) AS [Target],
       (SELECT TOP(1) [r2].[Memorandum] FROM [ReserveOrders] AS [r2]
        WHERE [s].[Id] = [r2].[ShiftId]) AS [Memorandum]
FROM [Shifts] AS [s]
INNER JOIN [Instructors] AS [i] ON [s].[InstructorId] = [i].[Id]
INNER JOIN [Users] AS [u] ON [i].[UserId] = [u].[Id]
WHERE [s].[InstructorId] = 3
  AND [s].[ScheduleDate] >= '2026-03-01'
  AND [s].[ScheduleDate] <= '2026-03-31'
  AND [s].[IsBooked] = 1
```

### 步驟 9：View 渲染

Razor 引擎載入 `Views/Reservation/Index.cshtml`，Model 型別為 `IEnumerable<ReservationViewModel>`。

View 負責：
- 日期範圍篩選表單（startDate、endDate，含「篩選」和「重置」按鈕）
- 成功訊息提示（TempData["SuccessMessage"]）
- 預約班表表格（日期、時段 Badge、預約客戶名稱、「詳細資訊」連結）
- 時段 Badge 顏色：早班=黃色、午班=橘色、晚班=深藍色
- DataTables jQuery 外掛提供排序、分頁、搜尋功能
- 「返回排班表單」按鈕連結至 ShiftController

### 步驟 10：HTTP Response

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Set-Cookie: MyFitnessCoach.Auth=<...>; path=/; secure; httponly; samesite=lax

<html>... (預約班表 HTML 頁面) ...</html>
```

### 步驟 11：Scoped 物件 Dispose

```
1. HTTP Response 發送完成
2. DI 容器銷毀本次 Request 的 Scoped 物件（LIFO 順序）：
   - ReservationController → GC 回收
   - ReservationService → GC 回收
   - ReservationRepository → GC 回收
   - MyFitnessCoachDbContext.Dispose() → 釋放 DB 連線回連線池
```

---

## 四、其他 Action 生命週期

### 4.1 Edit (GET) Action

```csharp
// Controllers/ReservationController.cs L56-82
[HttpGet]
[Authorize]
public async Task<IActionResult> Edit(int id)
```

| 差異點 | 說明 |
|-------|------|
| 路由參數 | 接受 `id`（ShiftId） |
| 身份驗證 | 額外驗證 `booking.InstructorId != instructorId` → Forbid() |
| Service 呼叫 | `_reservationService.GetBookingDetailsAsync(id)` → 取得單一預約詳情 |
| 可編輯判斷 | L78-79：計算五天前日期，`booking.ScheduleDate >= fiveDaysAgo` 決定是否可編輯 |
| ViewBag.IsEditable | 傳遞布林值控制 View 中的 textarea 是否為 readonly 及提交按鈕是否顯示 |
| View | `Edit.cshtml`：顯示客戶名稱、預約目標、備忘錄編輯表單 |

**Service 層：**
```csharp
// Services/ReservationService.cs L30-33
public async Task<ReservationDto?> GetBookingDetailsAsync(int shiftId)
{
    return await _repository.GetByShiftIdAsync(shiftId);
}
```

**Repository 層：**
```csharp
// Repositories/ReservationRepository.cs L74-97
public async Task<ReservationDto?> GetByShiftIdAsync(int shiftId)
{
    // 與 GetByCriteriaAsync 類似的 Include 鏈
    // Where(s => s.Id == shiftId)
    // 投影為 ReservationDto
    // FirstOrDefaultAsync()
}
```

### 4.2 Edit (POST) Action

```csharp
// Controllers/ReservationController.cs L84-134
[HttpPost]
[ValidateAntiForgeryToken]
[Authorize]
public async Task<IActionResult> Edit([Bind("Id,Memorandum")] ReservationViewModel model)
```

| 差異點 | 說明 |
|-------|------|
| HTTP Method | POST（寫入操作） |
| 防偽驗證 | `[ValidateAntiForgeryToken]` |
| `[Bind]` 限制 | 只綁定 `Id` 和 `Memorandum`，防止 Over-Posting |
| 身份驗證 | 二次查詢確認預約歸屬（L89-94） |
| 五天限制 | L96-102：超過五天的紀錄無法修改 |
| ModelState 清理 | L105-111：手動移除非 `Id`、`Memorandum` 的驗證錯誤（因 `[Bind]` 只綁定部分欄位） |
| Service 呼叫 | `_reservationService.UpdateMemorandumAsync(model.Id, model.Memorandum)` |
| Result 模式 | Service 回傳 `Result` 物件，Controller 檢查 `IsSuccess` |
| 成功重導向 | `TempData["SuccessMessage"] = "變更成功"` → `RedirectToAction("Index")` |

**Service 層：**
```csharp
// Services/ReservationService.cs L35-39
public async Task<Result> UpdateMemorandumAsync(int shiftId, string memorandum)
{
    var success = await _repository.UpdateMemorandumAsync(shiftId, memorandum);
    return success ? Result.Success(shiftId) : Result.Failure("更新備註失敗，找不到預約紀錄。");
}
```

**Repository 層：**
```csharp
// Repositories/ReservationRepository.cs L99-107
public async Task<bool> UpdateMemorandumAsync(int shiftId, string memorandum)
{
    var order = await _context.ReserveOrders.FirstOrDefaultAsync(ro => ro.ShiftId == shiftId);
    if (order == null) return false;
    order.Memorandum = memorandum;
    await _context.SaveChangesAsync();
    return true;
}
```

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── ReservationController.cs                ← Controller（[Authorize] 類別層級）
├── Services/
│   └── ReservationService.cs                   ← Service 層（注意：在 Services/ 而非 Models/Services/）
├── Repositories/
│   └── ReservationRepository.cs                ← Repository 層（含 Interface）
├── Models/
│   ├── EfModels/
│   │   ├── Shift.cs                            ← Entity（班表）
│   │   ├── ReserveOrder.cs                     ← Entity（預約訂單）
│   │   ├── Instructor.cs                       ← Entity（講師）
│   │   ├── Member.cs                           ← Entity（會員）
│   │   └── User.cs                             ← Entity（使用者帳號）
│   ├── DTOs/
│   │   ├── ReservationDto.cs                   ← DTO（預約資料傳輸）
│   │   └── ShiftQueryCriteria.cs               ← 查詢條件物件
│   └── ViewModels/
│       └── ReservationViewModel.cs             ← ViewModel
├── Views/
│   └── Reservation/
│       ├── Index.cshtml                        ← 預約班表列表
│       └── Edit.cshtml                         ← 編輯備忘錄
└── Program.cs                                  ← DI 註冊（L64-66）
```

### 5.2 Entity 關聯鏈

```
Shift (班表)
├── InstructorId (FK) ──→ Instructor (講師)
│                           └── UserId (FK) ──→ User (使用者帳號)
└── ReserveOrders (1:N) ──→ ReserveOrder (預約訂單)
                              ├── MemberId (FK) ──→ Member (會員)
                              │                       └── UserId (FK) ──→ User (使用者帳號)
                              └── ShiftId (FK) ──→ Shift (班表)  [反向關聯]
```

**Entity 欄位摘要：**

| Entity          | 關鍵欄位                                                                |
|----------------|------------------------------------------------------------------------|
| `Shift`        | Id, InstructorId, ScheduleDate (DateOnly), TimeSlot, IsBooked          |
| `ReserveOrder` | Id, MemberId, ShiftId, CreateAt, Status, PaymentMethod, Target, PointCost, Price, Memorandum |
| `Instructor`   | Id, UserId, ImageUrl, Description, HourWage, IsActive                   |
| `Member`       | Id, UserId, Gender, DateOfBirth, Weight, Height, Target                 |
| `User`         | Id, Account, UserName, Email, IsActive                                  |

**重要關聯：** `Shift` 與 `ReserveOrder` 是 1:N 關係，但在實際業務中一個班表時段通常只會對應一筆預約訂單。Repository 使用 `FirstOrDefault()` 取得第一筆 ReserveOrder 的資料。

---

## 六、重要概念總整理

### 6.1 Claims-Based 身份驗證與授權

本 Controller 實現了兩層授權機制：

1. **`[Authorize]`（類別層級）：** 確保使用者已登入（Cookie 驗證）
2. **InstructorId Claim 檢查（Action 層級）：** 從 `User.FindFirst("InstructorId")` 取得講師 ID，確保：
   - 使用者具有講師角色
   - 講師只能查看/編輯自己的預約班表

```csharp
// L29-33
var instructorIdClaim = User.FindFirst("InstructorId")?.Value;
if (string.IsNullOrEmpty(instructorIdClaim) || !int.TryParse(instructorIdClaim, out int instructorId) || instructorId == 0)
{
    return Forbid();
}
```

### 6.2 Criteria Pattern（查詢條件物件模式）

Service 層使用 `ShiftQueryCriteria` 物件封裝查詢條件，而非直接傳遞多個參數：

```csharp
// Models/DTOs/ShiftQueryCriteria.cs L3-11
public class ShiftQueryCriteria
{
    public int? InstructorId { get; set; }
    public string? InstructorName { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool? IsBooked { get; set; }
}
```

此模式的優點：
- 查詢條件集中管理
- 可輕鬆擴充新的篩選條件
- Repository 方法簽名不會因新增條件而變更

### 6.3 Result 模式（操作結果封裝）

Service 層的 `UpdateMemorandumAsync` 回傳 `Result` 物件，而非直接拋出例外：

```csharp
// Services/ReservationService.cs L35-39
var success = await _repository.UpdateMemorandumAsync(shiftId, memorandum);
return success ? Result.Success(shiftId) : Result.Failure("更新備註失敗，找不到預約紀錄。");
```

Controller 檢查結果：
```csharp
// Controllers/ReservationController.cs L124-133
var result = await _reservationService.UpdateMemorandumAsync(model.Id, model.Memorandum);
if (result.IsSuccess)
{
    TempData["SuccessMessage"] = "變更成功";
    return RedirectToAction("Index");
}
ModelState.AddModelError("", result.ErrorMessage);
```

### 6.4 [Bind] 防止 Over-Posting

```csharp
// L87
public async Task<IActionResult> Edit([Bind("Id,Memorandum")] ReservationViewModel model)
```

使用 `[Bind]` 特性限制 Model Binding 只綁定 `Id` 和 `Memorandum` 欄位，防止惡意使用者透過 POST 請求修改其他欄位（如 MemberName、ScheduleDate 等）。

### 6.5 五天編輯限制（業務規則）

```csharp
// Controllers/ReservationController.cs L78-79 (GET Edit)
var fiveDaysAgo = DateOnly.FromDateTime(DateTime.Today.AddDays(-5));
ViewBag.IsEditable = booking.ScheduleDate >= fiveDaysAgo;

// Controllers/ReservationController.cs L96-102 (POST Edit)
if (booking.ScheduleDate < fiveDaysAgo)
{
    ModelState.AddModelError("", "超過五天的紀錄無法修改。");
    ViewBag.IsEditable = false;
    return View(model);
}
```

此業務規則在 Controller 和 View 兩端都有實作：
- **Controller（POST）：** 伺服器端驗證，防止直接 POST 修改
- **View：** 根據 `ViewBag.IsEditable` 決定 textarea 是否 readonly 和是否顯示提交按鈕

### 6.6 DateOnly 型別使用

本 Controller 使用了 .NET 6+ 的 `DateOnly` 型別來處理日期（不含時間）：
- `Shift.ScheduleDate` 為 `DateOnly`
- Action 參數 `DateOnly? startDate, DateOnly? endDate`
- 與 `DateTime` 相比，`DateOnly` 更精確地表達「只有日期」的語意

### 6.7 DataTables jQuery 外掛整合

Index View 使用了 DataTables 外掛提供前端表格增強功能：
- 客戶端排序（預設按日期降冪）
- 分頁
- 前端搜尋
- 中文化語系設定

---

## 七、完整資料流圖

```
[瀏覽器] ──GET /Reservation/Index?startDate=2026-03-01&endDate=2026-03-31──→

    ┌─────────── Middleware Pipeline ───────────┐
    │ HTTPS Redirect → Static Files → Routing   │
    │ → Authentication (Cookie 解析)             │
    │   → 還原 ClaimsPrincipal                  │
    │   → Claims 包含 "InstructorId" = "3"      │
    │ → Authorization ([Authorize] 檢查)         │
    │   → 已登入 ✓ → 繼續                       │
    │   → 未登入 ✗ → 302 → /Account/Login       │
    └──────────────────┬────────────────────────┘
                       │ (已登入)
                       ▼
    ┌─── DI Container ─────────────────────────┐
    │  建立 MyFitnessCoachDbContext (Scoped)     │
    │  建立 ReservationRepository               │
    │  建立 ReservationService                  │
    │  建立 ReservationController               │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── Controller: Index() ──────────────────┐
    │  1. 取得 InstructorId Claim (L29-30)      │
    │  2. 驗證 InstructorId 有效 (L30-33)       │
    │     └── 無效 → return Forbid()            │
    │  3. 呼叫 Service (L35)                    │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── Service: GetBookedShiftsAsync() ──────┐
    │  1. 建立 ShiftQueryCriteria (L20-26)      │
    │     - InstructorId = 3                    │
    │     - StartDate = 2026-03-01              │
    │     - EndDate = 2026-03-31                │
    │     - IsBooked = true                     │
    │  2. 呼叫 Repository (L27)                 │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── Repository: GetByCriteriaAsync() ─────┐
    │  1. 建立 IQueryable (Include 多層關聯)     │
    │  2. Where(InstructorId == 3)              │
    │  3. Where(ScheduleDate >= 2026-03-01)     │
    │  4. Where(ScheduleDate <= 2026-03-31)     │
    │  5. Where(IsBooked == true)               │
    │  6. Select → ReservationDto 投影           │
    │     (含 MemberName, Target, Memorandum)    │
    │  7. ToListAsync()                         │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── EF Core → SQL Server ─────────────────┐
    │  SELECT ... FROM Shifts                   │
    │  JOIN Instructors JOIN Users               │
    │  LEFT JOIN ReserveOrders (子查詢 TOP 1)    │
    │  WHERE InstructorId=3                     │
    │    AND ScheduleDate BETWEEN ...           │
    │    AND IsBooked=1                         │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── Controller（續）──────────────────────┐
    │  4. DTO → ViewModel 轉換 (L38-47)        │
    │  5. ViewBag 設定 (L49-50)                 │
    │  6. return View(vms) (L52)                │
    └──────────────────┬────────────────────────┘
                       │
                       ▼
    ┌─── View: Index.cshtml ───────────────────┐
    │  @model IEnumerable<ReservationViewModel> │
    │  - 日期範圍篩選表單                        │
    │  - 成功訊息 (TempData)                    │
    │  - 預約班表表格 (DataTables 外掛)          │
    │    - 日期 / 時段 Badge / 客戶 / 詳細連結   │
    │  - 返回排班表單按鈕                        │
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
| `Program.cs`                                                   | DI 註冊                       | L24-25（DbContext）, L64-66（Repository, Service）, L119-129（Cookie Auth） |
| `Controllers/ReservationController.cs`                         | Controller                    | L14-22（建構子）, L26-53（Index）, L56-82（Edit GET）, L84-134（Edit POST） |
| `Services/ReservationService.cs`                               | Service 層                    | L11-16（建構子）, L18-28（GetBookedShiftsAsync）, L30-33（GetBookingDetailsAsync）, L35-39（UpdateMemorandumAsync） |
| `Repositories/ReservationRepository.cs`                        | Repository 層 + Interface     | L11-16（Interface）, L20-25（建構子）, L27-72（GetByCriteriaAsync）, L74-97（GetByShiftIdAsync）, L99-107（UpdateMemorandumAsync） |
| `Models/EfModels/Shift.cs`                                     | Entity（班表）                 | L8-23              |
| `Models/EfModels/ReserveOrder.cs`                              | Entity（預約訂單）              | L8-37              |
| `Models/EfModels/Instructor.cs`                                | Entity（講師）                 | L8-31              |
| `Models/EfModels/Member.cs`                                    | Entity（會員）                 | L8-51              |
| `Models/EfModels/User.cs`                                      | Entity（使用者）                | L8-47              |
| `Models/DTOs/ReservationDto.cs`                                | DTO                           | L5-19              |
| `Models/DTOs/ShiftQueryCriteria.cs`                            | 查詢條件物件                    | L3-11              |
| `Models/ViewModels/ReservationViewModel.cs`                    | ViewModel                     | L5-17              |
| `Views/Reservation/Index.cshtml`                               | 預約列表頁面（含 DataTables）   | 全檔               |
| `Views/Reservation/Edit.cshtml`                                | 編輯備忘錄頁面                  | 全檔               |

---

## 九、程式碼優化建議

### 9.1 重複的 InstructorId 驗證邏輯

**問題：** Index、Edit(GET)、Edit(POST) 三個 Action 都有幾乎相同的 `InstructorId` Claim 取得與驗證邏輯：

```csharp
var instructorIdClaim = User.FindFirst("InstructorId")?.Value;
int instructorId = int.Parse(instructorIdClaim ?? "0");
if (booking.InstructorId != instructorId) return Forbid();
```

且 Edit(GET) 和 Edit(POST) 中的 `int.Parse(instructorIdClaim ?? "0")` 在 `instructorIdClaim` 為 null 時不會拋出例外但會回傳 0，而 Index 用了更安全的 `int.TryParse` 寫法，兩處風格不一致。

**建議改法：** 抽取為一個私有方法或建立自訂 Action Filter：

```csharp
private int? GetCurrentInstructorId()
{
    var claim = User.FindFirst("InstructorId")?.Value;
    return int.TryParse(claim, out int id) && id > 0 ? id : null;
}
```

### 9.2 Edit(POST) 中二次查詢資料庫確認預約歸屬

**問題：** Edit(POST) 在 L89 再次呼叫 `_reservationService.GetBookingDetailsAsync(model.Id)` 來確認預約歸屬。這導致每次 POST 編輯都需要兩次 DB 查詢（一次確認歸屬 + 一次更新）。

**原因：** HTTP 是無狀態的，POST 請求必須重新驗證資料的歸屬權。

**建議：** 此設計是正確且安全的做法，二次查詢是必要的安全措施。但可考慮將歸屬驗證邏輯移入 Service 層，讓 Controller 更簡潔：

```csharp
// Service 層
public async Task<Result> UpdateMemorandumAsync(int shiftId, string memorandum, int instructorId)
{
    var booking = await _repository.GetByShiftIdAsync(shiftId);
    if (booking == null) return Result.Failure("找不到預約紀錄");
    if (booking.InstructorId != instructorId) return Result.Failure("無權修改此預約");
    // ... 五天驗證 ...
    return await _repository.UpdateMemorandumAsync(shiftId, memorandum)
        ? Result.Success(shiftId) : Result.Failure("更新失敗");
}
```

### 9.3 五天編輯限制的業務規則散落在 Controller 中

**問題：** 「超過五天的紀錄無法修改」這個業務規則在 Controller 的 Edit(GET) L78-79 和 Edit(POST) L96-102 中都有實作。業務規則應集中在 Service 層。

**建議改法：** 將五天限制邏輯移至 Service 層：

```csharp
// Service 層
public bool IsEditable(DateOnly scheduleDate)
{
    var fiveDaysAgo = DateOnly.FromDateTime(DateTime.Today.AddDays(-5));
    return scheduleDate >= fiveDaysAgo;
}
```

### 9.4 Repository 中子查詢使用 FirstOrDefault 的潛在問題

**問題：** Repository 的 `GetByCriteriaAsync` 和 `GetByShiftIdAsync` 使用 `s.ReserveOrders.Select(ro => ...).FirstOrDefault()` 取得預約會員資訊。如果一個班表有多筆 ReserveOrder（例如取消後重新預約），只會取得第一筆，可能不是最新的。

**建議改法：** 加上排序條件以確保取得最新的預約訂單：

```csharp
MemberName = s.ReserveOrders
    .OrderByDescending(ro => ro.CreateAt)
    .Select(ro => ro.Member.User.UserName)
    .FirstOrDefault(),
```

### 9.5 ModelState 手動清理的替代方案

**問題：** Edit(POST) 中 L105-111 手動遍歷 ModelState 並移除非 `Id`、`Memorandum` 的驗證錯誤。這種做法較脆弱，若 ViewModel 新增欄位容易遺漏。

```csharp
// L105-111
foreach (var key in ModelState.Keys.ToList())
{
    if (key != nameof(model.Id) && key != nameof(model.Memorandum))
    {
        ModelState.Remove(key);
    }
}
```

**建議改法：** 建立一個專用的 Edit ViewModel，只包含需要的欄位：

```csharp
public class ReservationEditViewModel
{
    public int Id { get; set; }

    [Display(Name = "課程備忘錄")]
    [StringLength(100, ErrorMessage = "備註最多只能輸入 100 個字")]
    public string? Memorandum { get; set; }
}
```

這樣就不需要 `[Bind]` 或手動清理 ModelState。

### 9.6 Service 未使用介面註冊

**問題：** `ReservationService` 直接以具體類別註冊（`AddScoped<ReservationService>()`），而非透過介面。這使得 Controller 直接依賴具體實作，不利於單元測試中 Mock Service 層。

**建議改法：** 建立 `IReservationService` 介面並透過介面註冊：

```csharp
// 介面
public interface IReservationService
{
    Task<List<ReservationDto>> GetBookedShiftsAsync(int instructorId, DateOnly? startDate, DateOnly? endDate);
    Task<ReservationDto?> GetBookingDetailsAsync(int shiftId);
    Task<Result> UpdateMemorandumAsync(int shiftId, string memorandum);
}

// Program.cs
builder.Services.AddScoped<IReservationService, ReservationService>();
```
