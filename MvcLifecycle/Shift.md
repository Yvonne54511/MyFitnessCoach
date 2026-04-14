# ShiftController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

## 一、全局架構概覽

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Browser (前端)                                │
│   Instructor: 排班行事曆頁面 (Index)                                        │
│   Admin: 管理所有營養師排班 (AllShifts)                                      │
└─────────────────┬───────────────────────────────────────────────────────────┘
                  │ HTTP Request (GET/POST)
                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Middleware Pipeline                                 │
│  UseHttpsRedirection → UseStaticFiles → UseRouting                         │
│  → UseAuthentication (Cookie) → UseAuthorization                           │
│  → [FunctionAttribute 權限過濾器]                                           │
└─────────────────┬───────────────────────────────────────────────────────────┘
                  │ 路由匹配: {controller=Account}/{action=Login}/{id?}
                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ShiftController [Authorize]                          │
│  DI 注入:                                                                   │
│    ├── ShiftService          (營養師排班商業邏輯)                              │
│    ├── IAdminService         (管理員排班檢視/操作)                             │
│    └── ILogger<ShiftController>  (日誌記錄)                                  │
└────────┬────────────────────────────────┬───────────────────────────────────┘
         │ 營養師操作                       │ 管理員操作
         ▼                                ▼
┌──────────────────────┐   ┌──────────────────────────────┐
│     ShiftService     │   │     AdminService              │
│  DI: IShiftRepository│   │  DI: IAdminRepository         │
└─────────┬────────────┘   └──────────────┬───────────────┘
          │                                │
          ▼                                ▼
┌──────────────────────┐   ┌──────────────────────────────┐
│   ShiftRepository    │   │     AdminRepository           │
│  DI: DbContext       │   │  DI: DbContext                │
└─────────┬────────────┘   └──────────────┬───────────────┘
          │                                │
          ▼                                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EF Core (MyFitnessCoachDbContext)                        │
│  DbSet<Shift>, DbSet<Instructor>, DbSet<ReserveOrder>                      │
└─────────────────────────────────────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SQL Server                                        │
│  Tables: Shifts, Instructors, ReserveOrders, Users                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊

| 行號 | 程式碼 | 說明 |
|------|--------|------|
| L24-25 | `AddDbContext<MyFitnessCoachDbContext>` | 註冊 EF Core DbContext（Scoped） |
| L61-62 | `AddScoped<IShiftRepository, ShiftRepository>()` | 註冊排班 Repository |
| L68-70 | `AddScoped<IAdminRepository, AdminRepository>()` / `AddScoped<IAdminService, AdminService>()` | 註冊管理員 Repository 與 Service |
| L73 | `AddScoped<ShiftService>()` | 註冊排班 Service（BLL） |
| L119-129 | `AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)` | Cookie 驗證機制 |

### 2.2 生命週期範圍

| 服務 | 生命週期 | 說明 |
|------|---------|------|
| `MyFitnessCoachDbContext` | **Scoped** | 每次 HTTP Request 建立一個實例 |
| `IShiftRepository` / `ShiftRepository` | **Scoped** | 每次 Request 共用同一個 DbContext |
| `ShiftService` | **Scoped** | 依賴 Scoped 的 Repository |
| `IAdminRepository` / `AdminRepository` | **Scoped** | 每次 Request 共用同一個 DbContext |
| `IAdminService` / `AdminService` | **Scoped** | 依賴 Scoped 的 Repository |
| `ILogger<ShiftController>` | **Singleton** | 由框架內建 Logging 系統提供 |

### 2.3 DI 注入鏈（由下往上）

```
SQL Server
  ↑
MyFitnessCoachDbContext (Scoped)
  ↑                         ↑
ShiftRepository (Scoped)    AdminRepository (Scoped)
  ↑                         ↑
ShiftService (Scoped)       AdminService (Scoped)
  ↑                         ↑
  └────────┬────────────────┘
           ↑
    ShiftController
           ↑
    ILogger<ShiftController> (Singleton)
```

### 2.4 建構子程式碼

**ShiftController** (`Controllers/ShiftController.cs` L16-25)：
```csharp
// L16-18: 私有欄位宣告
private readonly ShiftService _shiftService;
private readonly IAdminService _adminService;
private readonly ILogger<ShiftController> _logger;

// L20-25: 建構子注入
public ShiftController(ShiftService shiftService, IAdminService adminService, ILogger<ShiftController> logger)
{
    _shiftService = shiftService;
    _adminService = adminService;
    _logger = logger;
}
```

**ShiftService** (`Services/ShiftService.cs` L14-18)：
```csharp
private readonly IShiftRepository _repository;

public ShiftService(IShiftRepository repository)
{
    _repository = repository;
}
```

**AdminService** (`Services/AdminService.cs` L17-22)：
```csharp
private readonly IAdminRepository _adminRepository;

public AdminService(IAdminRepository adminRepository)
{
    _adminRepository = adminRepository;
}
```

### 2.5 介面與實作對照表

| 介面 | 實作類別 | 檔案位置 |
|------|---------|---------|
| `IShiftRepository` | `ShiftRepository` | `Repositories/ShiftRepository.cs` |
| `IAdminRepository` | `AdminRepository` | `Repositories/AdminRepository.cs` |
| `IAdminService` | `AdminService` | `Services/AdminService.cs` |
| （無介面，直接注入） | `ShiftService` | `Services/ShiftService.cs` |

---

## 三、完整 Request 生命週期（以 AllShifts Action 為例）

以管理員檢視所有排班為主要範例：`GET /Shift/AllShifts?InstructorId=1&StartDate=2026-03-01`

### 步驟 1：HTTP Request

```
GET /Shift/AllShifts?InstructorId=1&StartDate=2026-03-01&EndDate=2026-03-31 HTTP/1.1
Host: localhost
Cookie: MyFitnessCoach.Auth=<encrypted_token>
```

管理員在瀏覽器上選擇篩選條件，瀏覽器發送 GET 請求。Query String 參數會自動綁定到 `ShiftQueryCriteria` 物件。

### 步驟 2：Middleware Pipeline

```
HttpsRedirection → StaticFiles (跳過，非靜態檔) → Routing
→ Authentication (驗證 Cookie: MyFitnessCoach.Auth)
  → 解析 Cookie 取得 ClaimsPrincipal（含 Function Claims）
→ Authorization
  → [Authorize] 檢查是否已登入
  → [Function("view_InstructorShifts")] 檢查是否有 "view_InstructorShifts" Claim
```

`FunctionAttribute`（`Infra/FunctionAttribute.cs` L20-38）是自訂的 `IAsyncAuthorizationFilter`，會檢查使用者的 `Function` Claim 是否包含 `"view_InstructorShifts"`，若無則回傳 `ForbidResult`（403）。

### 步驟 3：路由匹配

```
模板: {controller=Account}/{action=Login}/{id?}
匹配: controller = "Shift", action = "AllShifts"
Query String 綁定: ShiftQueryCriteria { InstructorId = 1, StartDate = 2026-03-01, EndDate = 2026-03-31 }
```

ASP.NET Core 的模型綁定器（Model Binder）將 Query String 參數自動映射到 `ShiftQueryCriteria` 物件的對應屬性。

### 步驟 4：DI 容器建立物件鏈

```
1. 建立 MyFitnessCoachDbContext (Scoped)
2. 建立 ShiftRepository(DbContext)
3. 建立 ShiftService(ShiftRepository)
4. 建立 AdminRepository(DbContext)    ← 共用同一個 DbContext
5. 建立 AdminService(AdminRepository)
6. 取得 ILogger<ShiftController> (Singleton，已存在)
7. 建立 ShiftController(ShiftService, AdminService, Logger)
```

### 步驟 5：Controller Action 執行

**`AllShifts` Action**（`Controllers/ShiftController.cs` L82-117）：

```csharp
// L82-83: 方法簽名，接收查詢條件
[Authorize]
[Function("view_InstructorShifts")]
public async Task<IActionResult> AllShifts(ShiftQueryCriteria criteria)
{
    // L84: 透過 AdminService 取得所有營養師排班
    var shifts = await _adminService.GetAllInstructorShiftsAsync(criteria);
    // L85: 取得營養師清單（用於下拉選單）
    var instructors = await _adminService.GetInstructorsAsync();

    var now = DateTime.Now;

    // L90-106: 將 DTO 轉換為 ViewModel，計算 CanEdit 邏輯
    var vms = shifts.Select(s => {
        int hour = s.TimeSlot.Contains("早") ? 8 : (s.TimeSlot.Contains("午") ? 13 : 18);
        var shiftDateTime = s.ScheduleDate.ToDateTime(new TimeOnly(hour, 0));

        return new AllShiftsViewModel
        {
            Id = s.Id,
            InstructorName = s.InstructorName,
            ScheduleDate = s.ScheduleDate,
            TimeSlot = s.TimeSlot,
            IsBooked = s.IsBooked,
            CanEdit = now <= shiftDateTime  // 只有未來的排班才能修改
        };
    }).ToList();

    // L108-109: 透過 ViewBag 傳遞下拉選單資料與查詢條件
    ViewBag.Instructors = instructors;
    ViewBag.Criteria = criteria;

    // L111-113: 判斷是否為 AJAX 請求
    if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
    {
        return PartialView("_AllShiftsTable", vms);
    }

    // L116: 一般請求回傳完整 View
    return View(vms);
}
```

### 步驟 6：Service 層商業邏輯

**`AdminService.GetAllInstructorShiftsAsync`**（`Services/AdminService.cs` L24-27）：

```csharp
public async Task<List<ShiftDto>> GetAllInstructorShiftsAsync(ShiftQueryCriteria criteria = null)
{
    return await _adminRepository.GetAllInstructorShiftsAsync(criteria);
}
```

此 Service 層為薄封裝（Thin Service），直接委派給 Repository。

### 步驟 7：Repository 層資料存取

**`AdminRepository.GetAllInstructorShiftsAsync`**（`Repositories/AdminRepository.cs` L27-72）：

```csharp
public async Task<List<ShiftDto>> GetAllInstructorShiftsAsync(ShiftQueryCriteria criteria = null)
{
    // L29-32: 建立查詢，Include Instructor 和 User 導航屬性
    var query = _context.Shifts
        .Include(s => s.Instructor)
        .ThenInclude(i => i.User)
        .AsQueryable();

    // L34-56: 動態篩選條件
    if (criteria != null)
    {
        if (criteria.InstructorId.HasValue)
            query = query.Where(s => s.InstructorId == criteria.InstructorId.Value);
        if (!string.IsNullOrEmpty(criteria.InstructorName))
            query = query.Where(s => s.Instructor.User.UserName.Contains(criteria.InstructorName));
        if (criteria.StartDate.HasValue)
            query = query.Where(s => s.ScheduleDate >= criteria.StartDate.Value);
        if (criteria.EndDate.HasValue)
            query = query.Where(s => s.ScheduleDate <= criteria.EndDate.Value);
        if (criteria.IsBooked.HasValue)
            query = query.Where(s => s.IsBooked == criteria.IsBooked.Value);
    }

    // L58-72: 排序並投影為 DTO
    return await query
        .OrderBy(s => s.Instructor.User.UserName)
        .ThenBy(s => s.ScheduleDate)
        .ThenBy(s => s.TimeSlot)
        .Select(s => new ShiftDto
        {
            Id = s.Id,
            InstructorId = s.InstructorId,
            InstructorName = s.Instructor.User.UserName,
            ScheduleDate = s.ScheduleDate,
            TimeSlot = s.TimeSlot,
            IsBooked = s.IsBooked
        })
        .ToListAsync();
}
```

### 步驟 8：EF Core → SQL Server

EF Core 將 LINQ 查詢轉譯為如下 SQL（概略）：

```sql
SELECT s.Id, s.InstructorId, u.UserName AS InstructorName,
       s.ScheduleDate, s.TimeSlot, s.IsBooked
FROM Shifts s
INNER JOIN Instructors i ON s.InstructorId = i.Id
INNER JOIN Users u ON i.UserId = u.Id
WHERE s.InstructorId = @p0
  AND s.ScheduleDate >= @p1
  AND s.ScheduleDate <= @p2
ORDER BY u.UserName, s.ScheduleDate, s.TimeSlot
```

### 步驟 9：View 渲染

**一般請求**：回傳 `Views/Shift/AllShifts.cshtml`
- 使用 `@model IEnumerable<AllShiftsViewModel>`
- 渲染篩選表單（營養師下拉選單、日期範圍、預約狀態）
- 載入 `_AllShiftsTable` Partial View 顯示表格
- 引入 DataTables.js 實現分頁/排序
- 引入 SweetAlert2 實現狀態變更確認

**AJAX 請求**：僅回傳 `Views/Shift/_AllShiftsTable.cshtml`
- 純表格 HTML，前端以 `$('#tableContainer').html(html)` 替換

### 步驟 10：HTTP Response

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Set-Cookie: MyFitnessCoach.Auth=<renewed_token>

<html>... (完整頁面或 Partial HTML) ...</html>
```

### 步驟 11：Scoped 物件 Dispose

```
Request 結束 → DI 容器開始 Dispose Scoped 物件：
  1. ShiftController.Dispose()
  2. ShiftService (無 IDisposable)
  3. AdminService (無 IDisposable)
  4. ShiftRepository (無 IDisposable)
  5. AdminRepository (無 IDisposable)
  6. MyFitnessCoachDbContext.Dispose()
     → 關閉 SQL Server 連線（歸還 Connection Pool）
     → 釋放 ChangeTracker 中所有追蹤實體
```

---

## 四、其他 Action 生命週期

### 4.1 Index（營養師排班頁面入口）

| 項目 | 說明 |
|------|------|
| **路由** | `GET /Shift/Index` |
| **權限** | `[Authorize]` + `[Function("edit_InstructorShifts")]` |
| **差異** | 僅回傳空白 View，不呼叫任何 Service，前端透過 JavaScript 再呼叫 `GetBookedSlots` API |

```csharp
// Controllers/ShiftController.cs L31-34
public IActionResult Index()
{
    return View();
}
```

### 4.2 GetBookedSlots（取得營養師已排班時段）

| 項目 | 說明 |
|------|------|
| **路由** | `GET /Shift/GetBookedSlots` |
| **權限** | `[Authorize]`（無額外 Function 檢查） |
| **差異** | 從 `User.FindFirst("InstructorId")` 取得營養師 ID；呼叫 `ShiftService` 而非 `AdminService`；回傳 **JSON**（非 View） |
| **Service 呼叫** | `_shiftService.GetBookedSlotsForFrontendAsync(instructorId)` + `_shiftService.GetRemainingChancesAsync(instructorId)` |

```csharp
// Controllers/ShiftController.cs L38-52
[HttpGet]
public async Task<IActionResult> GetBookedSlots()
{
    var instructorIdClaim = User.FindFirst("InstructorId")?.Value;
    int instructorId = int.Parse(instructorIdClaim ?? "0");
    if (instructorId == 0) return BadRequest(new { success = false, message = "無效的講師 ID" });

    var bookedSlots = await _shiftService.GetBookedSlotsForFrontendAsync(instructorId);
    var remainingChances = await _shiftService.GetRemainingChancesAsync(instructorId);
    return Json(new { bookedSlots, remainingChances });
}
```

**Service 層差異**：
- `GetBookedSlotsForFrontendAsync`（`Services/ShiftService.cs` L45-77）：查詢當月排班紀錄，將 `ShiftDto` 轉為前端格式字串（如 `"2026-03-05-S0"`）
- `GetRemainingChancesAsync`（`Services/ShiftService.cs` L22-42）：計算本月剩餘修改次數（預設 3 次）

**Repository 層差異**：呼叫 `_repository.GetByCriteriaAsync(criteria)` → `ShiftRepository.GetByCriteriaAsync`（L168-202），使用動態篩選 LINQ 查詢。

### 4.3 Submit（營養師送出排班表）

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Shift/Submit` |
| **權限** | `[Authorize]` |
| **差異** | 接收 `[FromBody] List<ShiftViewModel>` JSON 資料；呼叫 `ShiftService.SaveFromViewModelsAsync`；回傳 JSON 結果 |
| **商業邏輯** | 包含首次排班 vs 修改排班的判斷、次數扣減、已預約時段保護等核心邏輯 |

```csharp
// Controllers/ShiftController.cs L56-76
[HttpPost]
public async Task<IActionResult> Submit([FromBody] List<ShiftViewModel> vm)
{
    var instructorIdClaim = User.FindFirst("InstructorId")?.Value;
    int instructorId = int.Parse(instructorIdClaim ?? "0");
    if (instructorId == 0) return BadRequest(new { success = false, message = "無效的講師 ID" });

    var result = await _shiftService.SaveFromViewModelsAsync(vm, instructorId);
    if (result.IsSuccess) return Ok(new { success = true, message = "儲存成功" });
    else return BadRequest(new { success = false, message = result.ErrorMessage });
}
```

**Service 層核心邏輯**（`Services/ShiftService.cs` L80-157 `SyncSchedulesAsync`）：
1. 取得營養師資訊
2. 取得當月現有排班紀錄
3. 比對前端送來的資料與資料庫資料，找出「要新增」和「要刪除」的項目
4. 檢查要刪除的是否有已預約（`IsBooked = true`），有則拒絕
5. 判斷首次排班（不扣次數）或修改排班（扣 CancelCount）
6. 執行 `DeleteRangeAsync` / `AddRangeAsync` / `UpdateInstructorAsync`

### 4.4 UpdateShiftStatus（管理員修改預約狀態）

| 項目 | 說明 |
|------|------|
| **路由** | `POST /Shift/UpdateShiftStatus` |
| **權限** | `[Authorize]` |
| **差異** | 接收 `int shiftId, bool isBooked`；呼叫 `AdminService.UpdateShiftStatusAsync`；回傳 JSON |

```csharp
// Controllers/ShiftController.cs L121-129
[HttpPost]
public async Task<IActionResult> UpdateShiftStatus(int shiftId, bool isBooked)
{
    var result = await _adminService.UpdateShiftStatusAsync(shiftId, isBooked);
    if (result) return Json(new { success = true });
    return Json(new { success = false, message = "更新失敗" });
}
```

**Repository 層差異**（`Repositories/AdminRepository.cs` L74-99 `UpdateShiftStatusAsync`）：
- 載入 Shift 及其關聯的 `ReserveOrders`
- 檢查排班時間是否已過（已過則不允許修改）
- 若取消預約（`isBooked = false`），同時刪除關聯的 `ReserveOrders`

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── ShiftController.cs
├── Services/
│   ├── ShiftService.cs
│   └── AdminService.cs
├── Repositories/
│   ├── ShiftRepository.cs      (含 IShiftRepository 介面)
│   └── AdminRepository.cs      (含 IAdminRepository 介面)
├── Models/
│   ├── EfModels/
│   │   ├── Shift.cs             (EF Core Entity)
│   │   ├── Instructor.cs        (EF Core Entity)
│   │   └── MyFitnessCoachDbContext.cs
│   ├── DTOs/
│   │   ├── ShiftDto.cs          (排班資料傳輸物件)
│   │   ├── ShiftRecordDto.cs    (營養師排班紀錄 DTO)
│   │   ├── ShiftQueryCriteria.cs (查詢條件 DTO)
│   │   ├── InstructorDto.cs     (營養師 DTO)
│   │   └── Result.cs            (操作結果封裝)
│   ├── ViewModels/
│   │   ├── ShiftViewModel.cs    (前端傳入的排班 VM)
│   │   └── AllShiftsViewModel.cs (管理員排班列表 VM)
│   └── Infra/
│       └── FunctionAttribute.cs (自訂權限過濾器)
├── Views/
│   └── Shift/
│       ├── AllShifts.cshtml     (管理員排班總覽頁)
│       └── _AllShiftsTable.cshtml (排班表格 Partial View)
└── Infra/
    └── FunctionAttribute.cs
```

### 5.2 Entity 關聯鏈

```
User (1) ──────── (1) Instructor
                         │
                         │ (1:N)
                         ▼
                      Shift (N)
                         │
                         │ (1:N)
                         ▼
                   ReserveOrder (N)
```

- **User → Instructor**：一個 User 可對應一個 Instructor（`Instructor.UserId` → `User.Id`）
- **Instructor → Shift**：一個 Instructor 有多筆 Shift（`Shift.InstructorId` → `Instructor.Id`）
- **Shift → ReserveOrder**：一個 Shift 可有多筆 ReserveOrder（`Shift.ReserveOrders`）

---

## 六、重要概念總整理

### 6.1 雙角色設計模式

ShiftController 同時服務兩種使用者角色：
- **營養師（Instructor）**：透過 `Index` → `GetBookedSlots` → `Submit` 操作自己的排班
- **管理員（Admin）**：透過 `AllShifts` → `UpdateShiftStatus` 檢視/管理所有排班

兩者使用不同的 Service：`ShiftService`（營養師）和 `AdminService`（管理員），實現職責分離。

### 6.2 自訂 FunctionAttribute 權限過濾器

`[Function("view_InstructorShifts")]` 是自訂的 `AuthorizeAttribute`，同時實作 `IAsyncAuthorizationFilter`。它在 `OnAuthorizationAsync` 方法中檢查使用者的 `Function` Claim，實現功能層級的權限控制（RBAC）。

### 6.3 排班修改次數控制（CancelCount）

- 首次排班：`CancelCount` 初始化為 3，不扣次數
- 修改排班：每次扣 1，歸零後本月無法再修改
- 此機制透過 `Instructor.CancelCount` 欄位實現，存放於 `Instructors` 資料表

### 6.4 AJAX + Partial View 即時篩選

`AllShifts` Action 透過判斷 `X-Requested-With` Header 來區分一般請求和 AJAX 請求：
- 一般請求：回傳完整 `AllShifts.cshtml`
- AJAX 請求：僅回傳 `_AllShiftsTable.cshtml`（表格部分），前端以 jQuery 替換 `#tableContainer` 內容

### 6.5 CanEdit 時間鎖定邏輯

管理員只能修改「未來」的排班狀態。Controller 在 L92-104 將 `TimeSlot` 字串（如 `"09-10 (早)"`）轉為概略時間，與 `DateTime.Now` 比較來決定 `CanEdit`。Repository 的 `UpdateShiftStatusAsync` 也有相同的時間檢查。

### 6.6 已預約時段保護

營養師修改排班時，若某時段已有客戶預約（`IsBooked = true`），`SyncSchedulesAsync` 會拒絕刪除該時段並回傳錯誤訊息。管理員手動取消預約時，`AdminRepository` 會同步刪除關聯的 `ReserveOrders`。

### 6.7 前端排班格式編碼

前端行事曆使用 `"yyyy-MM-dd-S{n}"` 格式（如 `"2026-03-05-S0"` 代表 3/5 早班），`ShiftService.GetBookedSlotsForFrontendAsync` 負責將資料庫格式轉換為此前端格式。

---

## 七、完整資料流圖

### 7.1 營養師排班流程

```
[營養師瀏覽器]
    │
    │ 1. GET /Shift/Index
    ▼
[ShiftController.Index] ──→ return View() ──→ [Index.cshtml 空白行事曆頁面]
    │
    │ 2. JS: $.get('/Shift/GetBookedSlots')
    ▼
[ShiftController.GetBookedSlots]
    │ User.FindFirst("InstructorId") → instructorId
    ▼
[ShiftService.GetBookedSlotsForFrontendAsync(instructorId)]
    │ 建立 ShiftQueryCriteria (本月範圍)
    ▼
[ShiftRepository.GetByCriteriaAsync(criteria)]
    │ LINQ → SQL: SELECT ... FROM Shifts WHERE ...
    ▼
[SQL Server] → List<ShiftDto> → 轉換為 ["2026-03-05-S0", ...] → JSON Response
    │
    │ 3. 使用者勾選/取消時段，按「送出」
    │    JS: POST /Shift/Submit (JSON Body: [{Date:"2026-03-05", Time_Slot:"09-10 (早)"}])
    ▼
[ShiftController.Submit]
    │ 解析 InstructorId，傳入 ViewModel 列表
    ▼
[ShiftService.SaveFromViewModelsAsync]
    │ ViewModel → ShiftRecordDto → SyncSchedulesAsync
    ▼
[ShiftService.SyncSchedulesAsync]
    │ ① 取得 Instructor 資訊
    │ ② 取得現有排班紀錄
    │ ③ 比對差異（toAdd / toDelete）
    │ ④ 檢查已預約保護
    │ ⑤ 檢查/扣減 CancelCount
    │ ⑥ 執行 AddRangeAsync / DeleteRangeAsync
    ▼
[ShiftRepository] → EF Core → SQL Server (INSERT/DELETE/UPDATE)
    │
    ▼
JSON: { success: true, message: "儲存成功" }
```

### 7.2 管理員查看/修改排班流程

```
[管理員瀏覽器]
    │
    │ 1. GET /Shift/AllShifts?InstructorId=1&StartDate=...
    ▼
[Middleware: Auth + Function("view_InstructorShifts") 檢查]
    │
    ▼
[ShiftController.AllShifts(criteria)]
    │ ① _adminService.GetAllInstructorShiftsAsync(criteria)
    │ ② _adminService.GetInstructorsAsync()
    │ ③ DTO → ViewModel (計算 CanEdit)
    ▼
[AdminService] → [AdminRepository]
    │ Include(Instructor).ThenInclude(User) + 動態篩選
    ▼
[EF Core] → SQL Server → List<ShiftDto> → List<AllShiftsViewModel>
    │
    ▼
[AllShifts.cshtml] ──嵌入──→ [_AllShiftsTable.cshtml] (表格)
    │
    │ 2. 管理員在下拉選單切換預約狀態
    │    SweetAlert2 確認 → POST /Shift/UpdateShiftStatus
    ▼
[ShiftController.UpdateShiftStatus(shiftId, isBooked)]
    ▼
[AdminService.UpdateShiftStatusAsync]
    ▼
[AdminRepository.UpdateShiftStatusAsync]
    │ ① 載入 Shift + ReserveOrders
    │ ② 時間鎖定檢查
    │ ③ 更新 IsBooked
    │ ④ 若取消預約，刪除 ReserveOrders
    ▼
[EF Core] → SQL Server (UPDATE/DELETE)
    │
    ▼
JSON: { success: true }  → 前端更新 Badge 顯示
```

---

## 八、涉及的關鍵檔案清單

| 檔案路徑 | 類型 | 說明 |
|----------|------|------|
| `Controllers/ShiftController.cs` | Controller | 排班控制器（5 個 Action） |
| `Services/ShiftService.cs` | Service | 營養師排班商業邏輯 |
| `Services/AdminService.cs` | Service | 管理員排班操作 |
| `Repositories/ShiftRepository.cs` | Repository | 排班資料存取（含 IShiftRepository） |
| `Repositories/AdminRepository.cs` | Repository | 管理員排班資料存取（含 IAdminRepository） |
| `Models/EfModels/Shift.cs` | Entity | Shift 資料表實體 |
| `Models/EfModels/Instructor.cs` | Entity | Instructor 資料表實體 |
| `Models/DTOs/ShiftDto.cs` | DTO | 排班資料傳輸物件 |
| `Models/DTOs/ShiftRecordDto.cs` | DTO | 營養師排班紀錄 DTO |
| `Models/DTOs/ShiftQueryCriteria.cs` | DTO | 查詢條件 DTO |
| `Models/DTOs/InstructorDto.cs` | DTO | 營養師 DTO |
| `Models/DTOs/Result.cs` | DTO | 操作結果封裝 |
| `Models/ViewModels/ShiftViewModel.cs` | ViewModel | 前端傳入排班資料 |
| `Models/ViewModels/AllShiftsViewModel.cs` | ViewModel | 管理員排班列表 VM |
| `Infra/FunctionAttribute.cs` | Filter | 自訂權限過濾器 |
| `Views/Shift/AllShifts.cshtml` | View | 管理員排班總覽頁面 |
| `Views/Shift/_AllShiftsTable.cshtml` | Partial View | 排班表格 |
| `Program.cs` | 啟動設定 | DI 註冊與 Middleware 配置 |

---

## 九、程式碼優化建議

### 9.1 ShiftService 未使用介面注入

**問題**：`ShiftService` 在 `Program.cs` L73 直接以 `AddScoped<ShiftService>()` 註冊，Controller 也直接注入具體類別而非介面。
**原因**：這違反了「依賴反轉原則（DIP）」，使得 Controller 與 ShiftService 之間產生緊密耦合，不利於單元測試中的 Mock 替換。
**建議**：建立 `IShiftService` 介面，並修改為 `AddScoped<IShiftService, ShiftService>()`，Controller 注入 `IShiftService`。

### 9.2 GetBookedSlots 中 InstructorId 解析缺乏安全處理

**問題**：`Controllers/ShiftController.cs` L41 使用 `int.Parse(instructorIdClaim ?? "0")`，若 Claim 值不是有效數字（例如被篡改），`int.Parse` 會拋出 `FormatException`。
**原因**：Claim 值來自 Cookie，雖然通常可信，但仍應使用 `int.TryParse` 做防禦性處理。
**建議**：改用 `int.TryParse`：
```csharp
if (!int.TryParse(User.FindFirst("InstructorId")?.Value, out int instructorId) || instructorId == 0)
{
    return BadRequest(new { success = false, message = "無效的講師 ID" });
}
```

### 9.3 AllShifts 中 TimeSlot 轉時間的魔法數字

**問題**：`Controllers/ShiftController.cs` L92 使用 `Contains("早") ? 8 : Contains("午") ? 13 : 18` 的硬編碼邏輯，`AdminRepository.cs` L83 也有重複的相同邏輯。
**原因**：兩處程式碼重複，且 "早/午/晚" 對應的小時數為魔法數字，修改時容易遺漏。
**建議**：將此邏輯抽取為共用的靜態方法或擴充方法：
```csharp
public static class ShiftTimeHelper
{
    public static int GetApproximateHour(string timeSlot)
    {
        if (timeSlot.Contains("早")) return 8;
        if (timeSlot.Contains("午")) return 13;
        return 18;
    }
}
```

### 9.4 AdminService 薄封裝層價值有限

**問題**：`AdminService`（`Services/AdminService.cs`）的三個方法全部是直接委派給 `AdminRepository`，沒有任何商業邏輯。
**原因**：目前的 AdminService 只是一個 pass-through 層，增加了程式碼量但未帶來實際價值。
**建議**：若未來確定不會在此層加入商業邏輯（如權限驗證、日誌記錄等），可考慮讓 Controller 直接注入 `IAdminRepository`。但若考量到架構一致性和未來擴展性，保留 Service 層也是合理的。

### 9.5 SyncSchedulesAsync 單一方法職責過多

**問題**：`ShiftService.SyncSchedulesAsync`（`Services/ShiftService.cs` L80-157）同時處理了：資料查詢、差異比對、預約保護檢查、首次/修改判斷、次數扣減、資料庫操作、營養師資訊更新。
**原因**：方法接近 80 行，包含多個獨立的業務邏輯區塊，可讀性和測試性較差。
**建議**：將部分邏輯提取為私有方法：
- `ValidateDeletions(toDeleteDtos)` — 檢查已預約保護
- `CalculateCancelCount(instructor, isFirstSubmission)` — 次數管理
- `ApplyChanges(toDeleteDtos, toAddDtos, instructor)` — 執行資料庫操作

### 9.6 Repository 中 DeleteRangeAsync 效能問題

**問題**：`ShiftRepository.DeleteRangeAsync`（`Repositories/ShiftRepository.cs` L104-136）先查出候選資料再於記憶體中比對，使用了巢狀 `dtoList.Any()` 進行 O(N*M) 比對。
**原因**：當資料量大時，此方法的記憶體和 CPU 消耗較高。
**建議**：可透過組合鍵（InstructorId + ScheduleDate + TimeSlot）建立 HashSet 來優化比對效能：
```csharp
var deleteKeys = new HashSet<string>(
    dtoList.Select(d => $"{d.InstructorId}-{d.ScheduleDate}-{d.TimeSlot}"));

var toRemove = candidates
    .Where(s => deleteKeys.Contains($"{s.InstructorId}-{s.ScheduleDate}-{s.TimeSlot}"))
    .ToList();
```
