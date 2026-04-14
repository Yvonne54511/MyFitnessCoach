# AdminLeaveController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

## 一、全局架構概覽

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                              Browser (管理員端)                                   │
│  GET /AdminLeave/List | GET /AdminLeave/Detail/{id} | POST /AdminLeave/BalanceGrant│
│  GET /AdminLeave/EmployeeList | POST /AdminLeave/EmployeeEdit                     │
│  GET /AdminLeave/HolidayList | POST /AdminLeave/HolidayCreate/Edit/Delete         │
└──────────────────────────────────┬───────────────────────────────────────────────┘
                                   │ HTTP Request
                                   ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                         ASP.NET Core Middleware Pipeline                          │
│  UseHttpsRedirection → UseStaticFiles → UseRouting                               │
│  → UseAuthentication (Cookie) → UseAuthorization                                 │
│  → [Authorize] + [Function("admin_xxx")] 過濾器                                   │
└──────────────────────────────────┬───────────────────────────────────────────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                        AdminLeaveController                                       │
│  DI 注入: AdminLeaveService, EmployeeService                                     │
│  功能群組:                                                                        │
│    ├── 假單管理 (List, Detail)          [Function("admin_LeaveRequests")]          │
│    ├── 員工管理 (EmployeeList/Edit)     [Function("admin_Employees")]              │
│    ├── 國定假日管理 (HolidayList/Create/Edit/Delete) [Function("admin_Holidays")]  │
│    └── 假別額度管理 (BalanceList/Grant/History) [Function("admin_LeaveBalances")]   │
└────────────┬─────────────────────────────┬──────────────────────────────────────┘
             │                             │
             ▼                             ▼
┌─────────────────────────────┐  ┌─────────────────────────────┐
│   AdminLeaveService         │  │   EmployeeService            │
│  DI: IAdminLeaveRepository, │  │  DI: IEmployeeRepository,    │
│      MyFitnessCoachDbContext│  │      MyFitnessCoachDbContext  │
└────────────┬────────────────┘  └────────────┬────────────────┘
             │                                │
             ▼                                ▼
┌─────────────────────────────┐  ┌─────────────────────────────┐
│  AdminLeaveRepository       │  │   EmployeeRepository         │
│  DI: MyFitnessCoachDbContext│  │  DI: MyFitnessCoachDbContext  │
└────────────┬────────────────┘  └────────────┬────────────────┘
             │                                │
             ▼                                ▼
┌──────────────────────────────────────────────────────────────┐
│                  EF Core DbContext                             │
│              MyFitnessCoachDbContext                           │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                       SQL Server                              │
│  LeaveRequests, Employees, Departments, Holidays,             │
│  LeaveTypes, LeaveBalances, LeaveBalanceHistories, Users       │
└──────────────────────────────────────────────────────────────┘
```

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊

| 行號 | 註冊程式碼 | 生命週期 |
|------|-----------|---------|
| L24-25 | `AddDbContext<MyFitnessCoachDbContext>` | **Scoped** |
| L110-111 | `AddScoped<IAdminLeaveRepository, AdminLeaveRepository>()` | **Scoped** |
| L112 | `AddScoped<AdminLeaveService>()` | **Scoped** |
| L114-115 | `AddScoped<IEmployeeRepository, EmployeeRepository>()` | **Scoped** |
| L116 | `AddScoped<EmployeeService>()` | **Scoped** |
| L119-129 | Cookie Authentication 服務配置 | **Singleton**（驗證方案） |

> **注意：** `AdminLeaveService` 和 `EmployeeService` 都是以**具體類別**方式註冊（無介面），Controller 直接注入具體類別。

### 2.2 生命週期範圍說明

所有 AdminLeave 相關服務皆為 **Scoped**：
- 每個 HTTP Request 建立一組獨立的物件實例
- 同一 Request 中 `AdminLeaveService` 和 `EmployeeService` 共用同一個 `MyFitnessCoachDbContext` 實例
- Request 結束後自動 Dispose

### 2.3 DI 注入鏈（由下往上）

```
SQL Server
  ↑
MyFitnessCoachDbContext (Scoped) ──── 同一實例被多個 Service/Repository 共享
  ↑                    ↑
  │                    │
AdminLeaveRepository   EmployeeRepository
  : IAdminLeaveRepository  : IEmployeeRepository
  ↑                    ↑
  │                    │
AdminLeaveService      EmployeeService
  ├── IAdminLeaveRepository    ├── IEmployeeRepository
  └── MyFitnessCoachDbContext  └── MyFitnessCoachDbContext
  ↑                    ↑
  └────────┬───────────┘
           │
     AdminLeaveController
       ├── AdminLeaveService
       └── EmployeeService
```

### 2.4 建構子程式碼

**AdminLeaveController** (`Controllers/AdminLeaveController.cs` L15-19)：
```csharp
public AdminLeaveController(AdminLeaveService adminLeaveService, EmployeeService employeeService)
{
    _adminLeaveService = adminLeaveService;
    _employeeService = employeeService;
}
```

**AdminLeaveService** (`Services/AdminLeaveService.cs` L15-19)：
```csharp
public AdminLeaveService(IAdminLeaveRepository repo, MyFitnessCoachDbContext db)
{
    _repo = repo;
    _db = db;
}
```

**EmployeeService** (`Services/EmployeeService.cs` L15-19)：
```csharp
public EmployeeService(IEmployeeRepository repo, MyFitnessCoachDbContext db)
{
    _repo = repo;
    _db = db;
}
```

**AdminLeaveRepository** (`Repositories/AdminLeaveRepository.cs` L18-21)：
```csharp
public AdminLeaveRepository(MyFitnessCoachDbContext context)
{
    _context = context;
}
```

**EmployeeRepository** (`Repositories/EmployeeRepository.cs` L18-20)：
```csharp
public EmployeeRepository(MyFitnessCoachDbContext context)
{
    _context = context;
}
```

### 2.5 介面與實作對照表

| 介面 | 實作類別 | 檔案路徑 |
|------|---------|---------|
| `IAdminLeaveRepository` | `AdminLeaveRepository` | `Repositories/AdminLeaveRepository.cs` |
| `IEmployeeRepository` | `EmployeeRepository` | `Repositories/EmployeeRepository.cs` |
| （無介面） | `AdminLeaveService` | `Services/AdminLeaveService.cs` |
| （無介面） | `EmployeeService` | `Services/EmployeeService.cs` |

---

## 三、完整 Request 生命週期（以 List Action 為例）

### 步驟 1：HTTP Request

```
GET /AdminLeave/List?departmentFilter=1&statusFilter=Pending&monthFilter=2026-03&searchKeyword=王 HTTP/1.1
Cookie: MyFitnessCoach.Auth=CfDJ8...
```

管理員已登入，瀏覽器自動攜帶 Authentication Cookie，存取假單管理列表並帶有篩選條件。

### 步驟 2：Middleware Pipeline

請求依序經過以下中介軟體（`Program.cs` L147-181）：

```
HttpsRedirection (L147)
  → StaticFiles (L149-176)   ← 非靜態檔案，略過
  → Routing (L178)            ← 解析路由，匹配 AdminLeave/List
  → Authentication (L180)     ← 從 Cookie 還原 ClaimsPrincipal（含 Function Claims）
  → Authorization (L181)      ← 通過 [Authorize]（類別級別）
  → FunctionAttribute Filter  ← 檢查 "admin_LeaveRequests" Function Claim
  → Endpoint Execution
```

### 步驟 3：路由匹配

`Program.cs` L185-187 預設路由模板：
```csharp
pattern: "{controller=Account}/{action=Login}/{id?}"
```

- `GET /AdminLeave/List` → Controller = `AdminLeave`, Action = `List`
- Query string 參數自動繫結到方法參數：`departmentFilter`, `statusFilter`, `monthFilter`, `searchKeyword`

### 步驟 4：DI 容器建立物件鏈

MVC 框架透過 DI 建立 `AdminLeaveController`，連鎖觸發：

```
1. MyFitnessCoachDbContext       (Scoped - 新建)
2. AdminLeaveRepository          (Scoped - 注入 DbContext)
3. AdminLeaveService             (Scoped - 注入 Repository + DbContext)
4. EmployeeRepository            (Scoped - 注入同一 DbContext)
5. EmployeeService               (Scoped - 注入 Repository + 同一 DbContext)
6. AdminLeaveController          (注入 AdminLeaveService + EmployeeService)
```

> **關鍵：** 所有元件共用同一個 `MyFitnessCoachDbContext` 實例（Scoped 特性）。

### 步驟 5：Controller Action 執行

`Controllers/AdminLeaveController.cs` L24-29：

```csharp
[Function("admin_LeaveRequests")]
public async Task<IActionResult> List(string departmentFilter, string statusFilter,
    string monthFilter, string searchKeyword)
{
    var vm = await _adminLeaveService.GetAllRequestsAsync(
        departmentFilter, statusFilter, monthFilter, searchKeyword);
    return View(vm);
}
```

**執行流程：**
1. `[Function("admin_LeaveRequests")]` Filter 已在步驟 2 通過
2. 呼叫 `AdminLeaveService.GetAllRequestsAsync()` 取得 ViewModel
3. 回傳 `View(vm)` 渲染列表頁面

### 步驟 6：Service 層商業邏輯

`Services/AdminLeaveService.cs` L21-63（`GetAllRequestsAsync` 方法）：

```csharp
public async Task<AdminLeaveListViewModel> GetAllRequestsAsync(
    string? deptFilter, string? statusFilter, string? monthFilter, string? keyword)
{
    // L24: 透過 Repository 查詢（含篩選）
    var requests = await _repo.GetAllAsync(deptFilter, statusFilter, monthFilter, keyword);
    // L25: 統計資料
    var stats = await _repo.GetStatsAsync(monthFilter);

    // L28-30: 直接用 DbContext 查部門（非透過 Repository）
    var departments = await _db.Departments
        .OrderBy(d => d.Name)
        .ToListAsync();

    // L32-44: Entity → DTO 轉換
    var dtos = requests.Select(r => new AdminLeaveListItemDto
    {
        Id = r.Id,
        ApplicantName = r.Employee?.User?.UserName,
        DepartmentName = r.Employee?.Department?.Name,
        LeaveTypeName = r.LeaveType?.Name,
        StartDate = r.StartDate,
        EndDate = r.EndDate,
        HoursUsed = r.HoursUsed ?? 0,
        DaysUsed = r.DaysUsed ?? 0,
        Status = r.Status,
        ApproverName = r.ApprovedByNavigation?.User?.UserName
    }).ToList();

    // L46-62: 組裝 ViewModel（含下拉選單）
    return new AdminLeaveListViewModel { ... };
}
```

### 步驟 7：Repository 層資料存取

`Repositories/AdminLeaveRepository.cs` L23-61（`GetAllAsync` 方法）：

```csharp
public async Task<List<LeaveRequest>> GetAllAsync(string? dept, string? status, string? month, string? keyword)
{
    var query = _context.LeaveRequests
        .Include(r => r.Employee).ThenInclude(e => e.User)
        .Include(r => r.Employee).ThenInclude(e => e.Department)
        .Include(r => r.LeaveType)
        .Include(r => r.ApprovedByNavigation).ThenInclude(a => a.User)
        .AsQueryable();

    // L33-56: 動態組合篩選條件
    if (!string.IsNullOrEmpty(dept) && int.TryParse(dept, out var deptId))
        query = query.Where(r => r.Employee.DepartmentId == deptId);
    if (!string.IsNullOrEmpty(status))
        query = query.Where(r => r.Status == status);
    if (!string.IsNullOrEmpty(month) && DateTime.TryParse(month + "-01", out var filterDate))
        query = query.Where(r => r.StartDate.Year == filterDate.Year && r.StartDate.Month == filterDate.Month);
    if (!string.IsNullOrEmpty(keyword))
        query = query.Where(r => r.Employee.User.UserName.Contains(keyword)
            || r.Employee.User.Account.Contains(keyword));

    // L58-60: 排序後執行查詢
    return await query.OrderByDescending(r => r.CreatedAt).ToListAsync();
}
```

`Repositories/AdminLeaveRepository.cs` L63-91（`GetStatsAsync` 方法）：
```csharp
public async Task<AdminLeaveStatsDto> GetStatsAsync(string? monthFilter)
{
    // 根據月份篩選或預設本月，統計各狀態的假單數量
    var monthRequests = await query
        .Where(r => r.StartDate.Year == targetDate.Year && r.StartDate.Month == targetDate.Month)
        .ToListAsync();

    return new AdminLeaveStatsDto
    {
        TotalThisMonth = monthRequests.Where(r => r.Status == "Approved").Sum(r => r.DaysUsed ?? 0),
        PendingCount = monthRequests.Count(r => r.Status == "Pending"),
        ApprovedCount = monthRequests.Count(r => r.Status == "Approved"),
        RejectedCount = monthRequests.Count(r => r.Status == "Rejected"),
        CancelPendingCount = monthRequests.Count(r => r.Status == "CancelPending")
    };
}
```

### 步驟 8：EF Core → SQL Server

EF Core 將 LINQ 轉譯為 SQL。List 流程產生的核心查詢：

```sql
-- 查詢假單列表（含多層 Include + 動態 WHERE）
SELECT lr.*, e.*, u.*, d.*, lt.*, approver.*, au.*
FROM [LeaveRequests] lr
LEFT JOIN [Employees] e ON lr.EmployeeId = e.Id
LEFT JOIN [Users] u ON e.UserId = u.Id
LEFT JOIN [Departments] d ON e.DepartmentId = d.Id
LEFT JOIN [LeaveTypes] lt ON lr.LeaveTypeId = lt.Id
LEFT JOIN [Employees] approver ON lr.ApprovedBy = approver.Id
LEFT JOIN [Users] au ON approver.UserId = au.Id
WHERE e.DepartmentId = @deptId          -- 條件篩選（動態組合）
  AND lr.Status = @status
  AND YEAR(lr.StartDate) = @year AND MONTH(lr.StartDate) = @month
  AND (u.UserName LIKE '%' + @keyword + '%' OR u.Account LIKE '%' + @keyword + '%')
ORDER BY lr.CreatedAt DESC

-- 統計查詢
SELECT lr.*
FROM [LeaveRequests] lr
WHERE YEAR(lr.StartDate) = @year AND MONTH(lr.StartDate) = @month

-- 部門下拉選單
SELECT d.* FROM [Departments] d ORDER BY d.Name
```

### 步驟 9：View 渲染 / JSON 回傳

Razor 引擎渲染 `Views/AdminLeave/List.cshtml`：
- 接收 `AdminLeaveListViewModel` 作為 Model
- 渲染統計卡片（待審核、已核准、已駁回數量）
- 渲染篩選下拉選單（部門、狀態、月份、關鍵字搜尋）
- 渲染假單列表表格（每筆含申請人、部門、假別、起迄日期、狀態等）
- 每列含「檢視詳情」連結，導向 `/AdminLeave/Detail/{id}`

### 步驟 10：HTTP Response

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<html>... (List.cshtml 渲染結果) ...</html>
```

### 步驟 11：Scoped 物件 Dispose

```
AdminLeaveController.Dispose()
AdminLeaveService（無 IDisposable）
EmployeeService（無 IDisposable）
AdminLeaveRepository（無 IDisposable）
EmployeeRepository（無 IDisposable）
MyFitnessCoachDbContext.Dispose()  ← 釋放資料庫連線回連線池
```

---

## 四、其他 Action 生命週期

### 4.1 Detail GET (`L32-39`)

| 項目 | 與 List 的差異 |
|------|---------------|
| 路由 | `GET /AdminLeave/Detail/{id}` |
| 權限 | `[Function("admin_LeaveRequests")]` — 同 List |
| Service | `_adminLeaveService.GetDetailAsync(id)` |
| Repository | `_repo.GetByIdAsync(id)` — 含更多 Include（LeaveDelegate, LeaveAttachments）（L94-104） |
| 回傳 | `View(dto)` — 單筆假單詳情頁；若找不到回傳 `NotFound()` |

### 4.2 EmployeeList GET (`L44-49`)

| 項目 | 差異 |
|------|------|
| 權限 | `[Function("admin_Employees")]` — 不同功能權限 |
| Service | `_employeeService.GetListAsync(departmentFilter, searchKeyword)` |
| Repository | `EmployeeRepository.GetAllAsync()` — 含 Include User, Department, Manager, WorkDelegate（L23-48） |
| ViewModel | `EmployeeListViewModel` — 含員工列表 + 部門下拉選單 |

### 4.3 EmployeeEdit GET (`L52-60`)

| 項目 | 差異 |
|------|------|
| 權限 | `[Function("admin_Employees")]` |
| Service | `_employeeService.GetForEditAsync(id)` |
| Service 邏輯 | 查詢員工 + 建立部門 / 主管 / 代理人下拉選單（`EmployeeService.cs` L59-107） |
| 回傳 | `View(EmployeeEditViewModel)` — 含可編輯的表單 |

### 4.4 EmployeeEdit POST (`L63-100`)

| 項目 | 差異 |
|------|------|
| HTTP Method | POST + `[ValidateAntiForgeryToken]` |
| 權限 | `[Function("admin_Employees")]` |
| ModelState 驗證 | 失敗時重新載入下拉選單（L70-79） |
| Service | `_employeeService.UpdateAsync(vm)` — 更新部門 / 主管 / 代理人 / 啟用狀態 |
| 成功回傳 | `RedirectToAction("EmployeeList")` + `TempData["SuccessMessage"]` |
| 失敗回傳 | 重新載入 View + `TempData["ErrorMessage"]` |

### 4.5 HolidayList GET (`L106-110`)

| 項目 | 差異 |
|------|------|
| 權限 | `[Function("admin_Holidays")]` |
| Service | `_adminLeaveService.GetHolidayListAsync(year)` |
| Service 邏輯 | 直接操作 `_db.Holidays`（非透過 Repository），查詢指定年度國定假日（L96-130） |
| ViewModel | `HolidayListViewModel` — 含假日列表 + 年份下拉選單 |

### 4.6 HolidayCreate GET (`L113-117`)

| 項目 | 差異 |
|------|------|
| Service 呼叫 | **無**，直接 `new HolidayEditViewModel()` |
| 回傳 | 空白建立表單 |

### 4.7 HolidayCreate POST (`L120-136`)

| 項目 | 差異 |
|------|------|
| Service | `_adminLeaveService.CreateHolidayAsync(vm)` |
| Service 邏輯 | 檢查日期重複 → 新增 Holiday Entity → SaveChanges（L146-166） |
| 成功回傳 | `RedirectToAction("HolidayList", new { year })` |

### 4.8 HolidayEdit GET (`L139-145`)

| 項目 | 差異 |
|------|------|
| Service | `_adminLeaveService.GetHolidayForEditAsync(id)` |
| 回傳 | `View(HolidayEditViewModel)` — 預填現有資料 |

### 4.9 HolidayEdit POST (`L148-164`)

| 項目 | 差異 |
|------|------|
| Service | `_adminLeaveService.UpdateHolidayAsync(vm)` |
| Service 邏輯 | 檢查日期重複（排除自身）→ 更新 → SaveChanges（L168-188） |

### 4.10 HolidayDelete POST (`L167-179`)

| 項目 | 差異 |
|------|------|
| HTTP Method | POST + `[ValidateAntiForgeryToken]` |
| 額外參數 | `int id, int year` — year 用於刪除後返回正確的年度列表 |
| Service | `_adminLeaveService.DeleteHolidayAsync(id)` |
| Service 邏輯 | `_db.Holidays.Remove()` → SaveChanges（L190-200） |

### 4.11 BalanceList GET (`L184-189`)

| 項目 | 差異 |
|------|------|
| 權限 | `[Function("admin_LeaveBalances")]` |
| Service | `_adminLeaveService.GetBalanceListAsync(departmentFilter, searchKeyword, year)` |
| Service 邏輯 | 查詢所有啟用員工 × 所有啟用假別的交叉組合，產生額度矩陣（L204-271） |
| 效能考量 | 先載入所有 Employees 和 LeaveBalances，在記憶體中做交叉比對 |

### 4.12 BalanceGrant GET (`L192-198`)

| 項目 | 差異 |
|------|------|
| 參數 | `employeeId, leaveTypeId, year` |
| Service | `_adminLeaveService.GetBalanceGrantViewModelAsync(employeeId, leaveTypeId, year)` |
| 回傳 | `View(BalanceGrantViewModel)` — 顯示目前額度 + 給假表單 |

### 4.13 BalanceGrant POST (`L201-235`)

| 項目 | 差異 |
|------|------|
| 特殊邏輯 | 從 `User.GetEmployeeId()` 取得操作者 ID（L221-222） |
| Service | `_adminLeaveService.GrantBalanceAsync(employeeId, leaveTypeId, year, grantDays, reason, operatorId)` |
| Service 邏輯 | 若無 Balance 則新建 → 增加 TotalDays → 寫入 LeaveBalanceHistory（L305-360） |
| 歷史追蹤 | `ChangeType = "AdminGrant"` 記錄管理員手動給假 |

### 4.14 BalanceHistory GET (`L238-244`)

| 項目 | 差異 |
|------|------|
| Service | `_adminLeaveService.GetBalanceHistoryAsync(employeeId, leaveTypeId, year)` |
| Service 邏輯 | 查詢 LeaveBalanceHistories → 加入 ChangeType 中文對照表（L362-429） |
| 回傳 | `View(BalanceHistoryViewModel)` — 額度變動紀錄列表 |

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── AdminLeaveController.cs
├── Services/
│   ├── AdminLeaveService.cs
│   └── EmployeeService.cs
├── Repositories/
│   ├── AdminLeaveRepository.cs    (含 IAdminLeaveRepository)
│   └── EmployeeRepository.cs      (含 IEmployeeRepository)
├── Models/
│   ├── EfModels/
│   │   ├── LeaveRequest.cs
│   │   ├── Employee.cs
│   │   ├── User.cs
│   │   ├── Department.cs
│   │   ├── LeaveType.cs
│   │   ├── LeaveBalance.cs
│   │   ├── LeaveBalanceHistory.cs
│   │   ├── Holiday.cs
│   │   ├── LeaveApprovalDelegation.cs
│   │   └── LeaveAttachment.cs
│   ├── DTOs/
│   │   ├── AdminLeaveListItemDto.cs
│   │   ├── AdminLeaveStatsDto.cs
│   │   ├── LeaveRequestDto.cs
│   │   ├── AdminEmployeeDto.cs
│   │   ├── HolidayItemDto.cs
│   │   ├── BalanceListItemDto.cs
│   │   ├── BalanceHistoryItemDto.cs
│   │   └── Result.cs
│   └── ViewModels/
│       ├── AdminLeaveListViewModel.cs
│       ├── EmployeeListViewModel.cs
│       ├── EmployeeEditViewModel.cs
│       ├── HolidayListViewModel.cs
│       ├── HolidayEditViewModel.cs
│       ├── BalanceListViewModel.cs
│       ├── BalanceGrantViewModel.cs
│       └── BalanceHistoryViewModel.cs
├── Infra/
│   ├── FunctionAttribute.cs
│   └── ClaimExtensions.cs
└── Views/
    └── AdminLeave/
        ├── List.cshtml
        ├── Detail.cshtml
        ├── EmployeeList.cshtml
        ├── EmployeeEdit.cshtml
        ├── HolidayList.cshtml
        ├── HolidayCreate.cshtml
        ├── HolidayEdit.cshtml
        ├── BalanceList.cshtml
        ├── BalanceGrant.cshtml
        └── BalanceHistory.cshtml
```

### 5.2 Entity 關聯鏈

```
LeaveRequest ──── EmployeeId → Employee ──── UserId → User
  │                  │                          │
  │                  ├── DepartmentId → Department
  │                  ├── ManagerId → Employee (self-ref, 主管)
  │                  └── WorkDelegateId → Employee (self-ref, 代理人)
  │
  ├── LeaveTypeId → LeaveType
  │                    │
  │                    ├── QuotaType (PreAllocated / Unlimited / ApprovalRequired)
  │                    ├── DaysPerYear
  │                    └── WarnThresholdDays
  │
  ├── LeaveDelegateId → Employee (請假代理人)
  ├── ApprovedBy → Employee (審核者)
  ├── (*) LeaveAttachment
  └── (*) LeaveApprovalDelegation

LeaveBalance ──── EmployeeId → Employee
  │           └── LeaveTypeId → LeaveType
  │
  └── (*) LeaveBalanceHistory
              └── OperatorId → Employee (操作者)

Holiday (獨立表，無 FK 關聯)
  ├── HolidayDate (DateOnly)
  ├── Year
  └── IsActive
```

---

## 六、重要概念總整理

### 6.1 類別級別的 [Authorize] 屬性

`AdminLeaveController` 在類別上標記 `[Authorize]`（L9），表示所有 Action 都需要已驗證的使用者。搭配各 Action 上的 `[Function("xxx")]`，實現雙層授權：
1. **第一層**：使用者必須已登入（Cookie 驗證通過）
2. **第二層**：使用者必須擁有對應的功能權限 Claim

### 6.2 FunctionAttribute 四大功能區塊

| Function 名稱 | 適用 Action | 說明 |
|---------------|------------|------|
| `admin_LeaveRequests` | List, Detail | 假單管理：檢視所有假單 |
| `admin_Employees` | EmployeeList, EmployeeEdit | 員工管理：編輯部門/主管/代理人 |
| `admin_Holidays` | HolidayList/Create/Edit/Delete | 國定假日管理 |
| `admin_LeaveBalances` | BalanceList/Grant/History | 假別額度管理 |

### 6.3 Service 直接操作 DbContext 的混合模式

`AdminLeaveService` 同時注入 `IAdminLeaveRepository` 和 `MyFitnessCoachDbContext`：
- **Repository** 負責 `LeaveRequest` 相關的複雜查詢（含多層 Include）
- **DbContext** 直接操作 `Departments`、`Holidays`、`LeaveTypes`、`LeaveBalances`、`LeaveBalanceHistories` 等表

這是一種「混合三層」模式，避免為每張表都建立 Repository，在簡單 CRUD 場景提供更直接的存取。

### 6.4 假別額度管理的 QuotaType 分類

| QuotaType | 說明 | 額度來源 |
|-----------|------|---------|
| `PreAllocated` | 特休假 | 系統預設 `DaysPerYear`，年初自動配額 |
| `Unlimited` | 病假/事假/公假 | 無上限，僅追蹤使用量 |
| `ApprovalRequired` | 婚假/喪假 | 需管理員手動核定額度（BalanceGrant） |

### 6.5 LeaveBalanceHistory 變動追蹤

每次額度變動都會寫入歷史紀錄，包含：
- `ChangeType`：AdminGrant / Apply / Reject / CancelApproved
- `ChangeDays`：變動天數
- `OldTotalDays` / `NewTotalDays`：額度變動前後
- `OldUsedDays` / `NewUsedDays`：使用量變動前後
- `OperatorId`：操作者 Employee ID
- `Reason`：變動原因

### 6.6 ClaimExtensions 擴充方法

`Infra/ClaimExtensions.cs` 提供 `User.GetEmployeeId()` 和 `User.GetDepartmentId()` 擴充方法，從 `ClaimsPrincipal` 中提取自訂 Claims。在 `BalanceGrant POST`（L221）中用於取得管理員自己的 EmployeeId 作為操作者紀錄。

### 6.7 統計資料 (AdminLeaveStatsDto)

`List` Action 除了列表資料外，還透過 `GetStatsAsync()` 取得統計卡片數據：
- `TotalThisMonth`：當月已核准的總請假天數
- `PendingCount`：待審核數量
- `ApprovedCount`：已核准數量
- `RejectedCount`：已駁回數量
- `CancelPendingCount`：待取消審核數量

---

## 七、完整資料流圖

### 7.1 List 資料流

```
[Browser] ─── GET /AdminLeave/List?deptFilter=1&statusFilter=Pending ───
    │
    ▼
[Middleware] ─── Cookie Auth ─── [Authorize] ─── [Function("admin_LeaveRequests")]
    │
    ▼
[AdminLeaveController.List]
    │  呼叫 AdminLeaveService.GetAllRequestsAsync()
    ▼
[AdminLeaveService]
    │  1. _repo.GetAllAsync(dept, status, month, keyword)
    │     └→ [AdminLeaveRepository.GetAllAsync]
    │         └→ EF Core → SQL: SELECT LeaveRequests + Employees + Users + Departments + LeaveTypes
    │                           WITH dynamic WHERE + ORDER BY CreatedAt DESC
    │
    │  2. _repo.GetStatsAsync(monthFilter)
    │     └→ [AdminLeaveRepository.GetStatsAsync]
    │         └→ EF Core → SQL: SELECT LeaveRequests WHERE month = @month
    │                           → In-memory: Count by Status
    │
    │  3. _db.Departments.OrderBy(d => d.Name).ToListAsync()
    │     └→ EF Core → SQL: SELECT Departments ORDER BY Name
    │
    │  4. Entity → AdminLeaveListItemDto 轉換
    │  5. 組裝 AdminLeaveListViewModel (含 Stats, Requests, DepartmentOptions)
    ▼
[Razor View: List.cshtml]
    │  渲染統計卡片 + 篩選工具列 + 假單列表表格
    ▼
[HTTP Response] ─── 200 OK ─── HTML
```

### 7.2 BalanceGrant POST 資料流

```
[Browser] ─── POST /AdminLeave/BalanceGrant ───
    │  { EmployeeId, LeaveTypeId, Year, GrantDays, Reason }
    ▼
[AdminLeaveController.BalanceGrant POST]
    │  1. ModelState 驗證
    │  2. User.GetEmployeeId() → 取得操作者 ID
    │  3. 呼叫 AdminLeaveService.GrantBalanceAsync()
    ▼
[AdminLeaveService.GrantBalanceAsync]
    │  1. 驗證 grantDays > 0
    │  2. _db.LeaveTypes.FindAsync(leaveTypeId) → 驗證假別存在
    │  3. _db.LeaveBalances.FirstOrDefaultAsync() → 查詢現有餘額
    │  4. 若無 Balance → 新建；若有 → TotalDays += grantDays
    │  5. _db.LeaveBalanceHistories.Add() → 寫入變動紀錄
    │     { ChangeType="AdminGrant", ChangeDays, OldTotal, NewTotal, Operator }
    │  6. _db.SaveChangesAsync()
    ▼
[AdminLeaveController]
    │  成功: TempData["SuccessMessage"] + RedirectToAction("BalanceList")
    │  失敗: TempData["ErrorMessage"] + RedirectToAction("BalanceGrant")
    ▼
[HTTP Response] ─── 302 Redirect
```

### 7.3 EmployeeEdit POST 資料流

```
[Browser] ─── POST /AdminLeave/EmployeeEdit ───
    │  { Id, DepartmentId, ManagerId, WorkDelegateId, IsActive }
    ▼
[AdminLeaveController.EmployeeEdit POST]
    │  1. ModelState 驗證 → 失敗則重載下拉選單
    │  2. 呼叫 EmployeeService.UpdateAsync(vm)
    ▼
[EmployeeService.UpdateAsync]
    │  1. _repo.GetByIdAsync(vm.Id) → 查詢員工
    │  2. 更新 DepartmentId, ManagerId, WorkDelegateId, IsActive
    │  3. _repo.UpdateAsync(employee) → DbContext.SaveChangesAsync()
    ▼
[AdminLeaveController]
    │  成功: TempData["SuccessMessage"] + RedirectToAction("EmployeeList")
    │  失敗: 重載下拉選單 + TempData["ErrorMessage"] + View(vm)
    ▼
[HTTP Response] ─── 302 Redirect 或 200 OK + HTML
```

---

## 八、涉及的關鍵檔案清單

| 層級 | 檔案 | 說明 |
|------|------|------|
| 啟動配置 | `Program.cs` | DI 註冊（L110-116）、Cookie Auth、路由 |
| Controller | `Controllers/AdminLeaveController.cs` | 15 個 Action（假單/員工/假日/額度管理） |
| Service | `Services/AdminLeaveService.cs` | 假單查詢 + 假日 CRUD + 額度管理 |
| Service | `Services/EmployeeService.cs` | 員工列表 + 編輯 |
| Repository | `Repositories/AdminLeaveRepository.cs` | LeaveRequest 查詢（含 IAdminLeaveRepository） |
| Repository | `Repositories/EmployeeRepository.cs` | Employee CRUD（含 IEmployeeRepository） |
| Entity | `Models/EfModels/LeaveRequest.cs` | 假單實體 |
| Entity | `Models/EfModels/Employee.cs` | 員工實體（含 Manager / WorkDelegate self-ref） |
| Entity | `Models/EfModels/User.cs` | 用戶實體 |
| Entity | `Models/EfModels/LeaveType.cs` | 假別類型 |
| Entity | `Models/EfModels/LeaveBalance.cs` | 假別額度 |
| Entity | `Models/EfModels/LeaveBalanceHistory.cs` | 額度變動歷史 |
| Entity | `Models/EfModels/Holiday.cs` | 國定假日 |
| DTO | `Models/DTOs/AdminLeaveListItemDto.cs` | 假單列表項目 |
| DTO | `Models/DTOs/AdminLeaveStatsDto.cs` | 統計資料 |
| DTO | `Models/DTOs/LeaveRequestDto.cs` | 假單詳情 |
| DTO | `Models/DTOs/Result.cs` | 通用操作結果 |
| ViewModel | `Models/ViewModels/AdminLeaveListViewModel.cs` | 假單列表 VM |
| ViewModel | `Models/ViewModels/EmployeeListViewModel.cs` | 員工列表 VM |
| ViewModel | `Models/ViewModels/EmployeeEditViewModel.cs` | 員工編輯 VM |
| ViewModel | `Models/ViewModels/HolidayListViewModel.cs` | 假日列表 VM |
| ViewModel | `Models/ViewModels/HolidayEditViewModel.cs` | 假日編輯 VM |
| ViewModel | `Models/ViewModels/BalanceListViewModel.cs` | 額度列表 VM |
| ViewModel | `Models/ViewModels/BalanceGrantViewModel.cs` | 額度給假 VM |
| ViewModel | `Models/ViewModels/BalanceHistoryViewModel.cs` | 額度歷史 VM |
| Infra | `Infra/FunctionAttribute.cs` | 功能權限過濾器 |
| Infra | `Infra/ClaimExtensions.cs` | Claims 擴充方法 |
| View | `Views/AdminLeave/List.cshtml` | 假單管理列表 |
| View | `Views/AdminLeave/Detail.cshtml` | 假單詳情 |
| View | `Views/AdminLeave/EmployeeList.cshtml` | 員工列表 |
| View | `Views/AdminLeave/EmployeeEdit.cshtml` | 員工編輯 |
| View | `Views/AdminLeave/HolidayList.cshtml` | 假日列表 |
| View | `Views/AdminLeave/HolidayCreate.cshtml` | 假日新增 |
| View | `Views/AdminLeave/HolidayEdit.cshtml` | 假日編輯 |
| View | `Views/AdminLeave/BalanceList.cshtml` | 額度列表 |
| View | `Views/AdminLeave/BalanceGrant.cshtml` | 額度給假 |
| View | `Views/AdminLeave/BalanceHistory.cshtml` | 額度歷史 |

---

## 九、程式碼優化建議

### 9.1 BalanceList 的 N+1 式記憶體交叉比對效能問題

**問題位置：** `Services/AdminLeaveService.cs` L204-271（`GetBalanceListAsync`）

**問題原因：** 方法先載入所有啟用員工、所有啟用假別、所有年度餘額到記憶體，然後用巢狀 `foreach` 產生交叉組合：

```csharp
// L231-254
foreach (var emp in employees)
{
    foreach (var lt in leaveTypes)
    {
        var b = balances.FirstOrDefault(x => x.EmployeeId == emp.Id && x.LeaveTypeId == lt.Id);
        items.Add(new BalanceListItemDto { ... });
    }
}
```

當員工 100 人 x 假別 6 種 = 600 筆 DTO，且每次都用 `FirstOrDefault` 線性搜尋 `balances` List。

**建議改法：** 將 `balances` 轉為 Dictionary 以提升查詢效率：

```csharp
var balanceDict = balances.ToDictionary(
    b => (b.EmployeeId, b.LeaveTypeId),
    b => b);

foreach (var emp in employees)
{
    foreach (var lt in leaveTypes)
    {
        balanceDict.TryGetValue((emp.Id, lt.Id), out var b);
        items.Add(new BalanceListItemDto { ... });
    }
}
```

### 9.2 GetStatsAsync 載入整月資料到記憶體再統計

**問題位置：** `Repositories/AdminLeaveRepository.cs` L63-91（`GetStatsAsync`）

**問題原因：** 將整月的 LeaveRequest 全部載入記憶體後，用 LINQ-to-Objects 做 Count 和 Sum。當資料量大時效率低。

```csharp
var monthRequests = await query
    .Where(r => r.StartDate.Year == targetDate.Year && r.StartDate.Month == targetDate.Month)
    .ToListAsync();  // 全部載入記憶體

return new AdminLeaveStatsDto
{
    TotalThisMonth = monthRequests.Where(r => r.Status == "Approved").Sum(r => r.DaysUsed ?? 0),
    PendingCount = monthRequests.Count(r => r.Status == "Pending"),
    // ...
};
```

**建議改法：** 使用 `GroupBy` 在 SQL Server 端完成統計：

```csharp
var stats = await query
    .Where(r => r.StartDate.Year == targetDate.Year && r.StartDate.Month == targetDate.Month)
    .GroupBy(r => r.Status)
    .Select(g => new { Status = g.Key, Count = g.Count(), TotalDays = g.Sum(r => r.DaysUsed ?? 0) })
    .ToListAsync();
```

### 9.3 AdminLeaveService 和 EmployeeService 缺少介面

**問題位置：** `Program.cs` L112, L116

```csharp
builder.Services.AddScoped<AdminLeaveService>();
builder.Services.AddScoped<EmployeeService>();
```

**問題原因：** Service 以具體類別註冊，Controller 也直接依賴具體類別。這使得：
- 無法在單元測試中輕易 Mock Service
- 違反依賴反轉原則（DIP）

**建議改法：** 若未來有單元測試需求，建議抽出介面：

```csharp
// 註冊改為
builder.Services.AddScoped<IAdminLeaveService, AdminLeaveService>();
builder.Services.AddScoped<IEmployeeService, EmployeeService>();
```

### 9.4 HolidayCreate/Update/Delete 直接操作 DbContext 未經 Repository

**問題位置：** `Services/AdminLeaveService.cs` L146-200

**問題原因：** Holiday 的 CRUD 直接使用 `_db.Holidays`，而 LeaveRequest 的查詢則透過 `IAdminLeaveRepository`。這種混合模式雖然可運作，但風格不一致。

**建議：** 若團隊習慣 Repository 模式，可考慮將 Holiday 操作也封裝到 Repository。但若團隊認為簡單 CRUD 直接操作 DbContext 更清晰，則保持現狀也是合理的選擇，此處不強制修改。

### 9.5 EmployeeEdit POST 在失敗時重複查詢兩次

**問題位置：** `Controllers/AdminLeaveController.cs` L66-100

**問題原因：** ModelState 驗證失敗時（L70-79）和 Service 更新失敗時（L91-99）都各自呼叫 `_employeeService.GetForEditAsync(vm.Id)` 重新載入下拉選單，造成兩處幾乎相同的程式碼。

**建議改法：** 抽取為私有方法減少重複：

```csharp
private async Task<EmployeeEditViewModel?> ReloadEditViewModel(EmployeeEditViewModel vm)
{
    var reload = await _employeeService.GetForEditAsync(vm.Id);
    if (reload == null) return null;
    vm.UserName = reload.UserName;
    vm.Account = reload.Account;
    vm.DepartmentOptions = reload.DepartmentOptions;
    vm.ManagerOptions = reload.ManagerOptions;
    vm.DelegateOptions = reload.DelegateOptions;
    return vm;
}
```

### 9.6 BalanceGrant POST 中 operatorId 的 fallback 值為 0

**問題位置：** `Controllers/AdminLeaveController.cs` L221-222

```csharp
var empId = User.GetEmployeeId();
var operatorId = empId ?? 0;
```

**問題原因：** 若登入用戶沒有對應的 Employee（例如純管理員帳號），`operatorId` 會是 0，寫入 `LeaveBalanceHistory.OperatorId = 0` 可能導致外鍵約束錯誤或無效資料。

**建議改法：** 在此處做明確檢查：

```csharp
var empId = User.GetEmployeeId();
if (empId == null) return Forbid(); // 或返回錯誤訊息
var operatorId = empId.Value;
```
