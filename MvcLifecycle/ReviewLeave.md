# ReviewLeaveController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

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
│          ReviewLeaveController  [Authorize]               │
│  DI 注入:                                                 │
│    └── ReviewLeaveService                                 │
│         ├── ILeaveRepository (LeaveRepository)            │
│         └── MyFitnessCoachDbContext                       │
│              ├── LeaveRequests                            │
│              ├── LeaveBalances                            │
│              ├── LeaveBalanceHistories                    │
│              ├── LeaveApprovalDelegations                 │
│              └── Employees                               │
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────┐
│           LeaveRepository / DbContext                     │
│           (EF Core → SQL Server)                         │
└──────────────────────────────────────────────────────────┘
```

### 該 Controller 的 DI 注入對象
| 注入對象 | 類型 | 說明 |
|---------|------|------|
| `ReviewLeaveService` | 具象類別（直接注入） | 假單審核業務邏輯服務 |

`ReviewLeaveService` 內部再注入：
- `ILeaveRepository` → `LeaveRepository`（假單資料存取）
- `MyFitnessCoachDbContext` → 直接存取 `LeaveBalances`、`LeaveBalanceHistories`、`LeaveApprovalDelegations`、`Employees`

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊

```csharp
// Program.cs L106 — Leave 模組共用的 Repository
builder.Services.AddScoped<ILeaveRepository, LeaveRepository>();  // L106

// Program.cs L108 — ReviewLeaveService
builder.Services.AddScoped<ReviewLeaveService>();                  // L108

// DbContext (L24-25)
builder.Services.AddDbContext<MyFitnessCoachDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Cookie 認證 (L119-129)
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options => { ... });
```

**注意：** `ILeaveRepository`（L106）是 Leave 模組的共用 Repository，同時被 `LeaveService`（L107）和 `ReviewLeaveService`（L108）使用。

### 2.2 生命週期範圍

| 服務 | 生命週期 | 說明 |
|------|---------|------|
| `ReviewLeaveService` | **Scoped** | 每個 HTTP Request 建立一個實例 |
| `ILeaveRepository` / `LeaveRepository` | **Scoped** | 每個 HTTP Request 建立一個實例 |
| `MyFitnessCoachDbContext` | **Scoped** | `AddDbContext` 預設為 Scoped |

### 2.3 DI 注入鏈（由下往上）

```
SQL Server (資料庫)
    ↑
MyFitnessCoachDbContext (EF Core DbContext) ──── Scoped
    ↑                    ↑
LeaveRepository          │
(實作 ILeaveRepository)   │
    ↑                    │
    └────────────────────┤
                         │
               ReviewLeaveService ──────────── Scoped
                         ↑
              ReviewLeaveController
```

### 2.4 建構子程式碼

**ReviewLeaveController（L13-16）：**
```csharp
// Controllers/ReviewLeaveController.cs L13-16
public ReviewLeaveController(ReviewLeaveService reviewService)
{
    _reviewService = reviewService;
}
```

**ReviewLeaveService（L15-19）：**
```csharp
// Services/ReviewLeaveService.cs L15-19
public ReviewLeaveService(ILeaveRepository repo, MyFitnessCoachDbContext db)
{
    _repo = repo;
    _db = db;
}
```

**LeaveRepository（L29-32）：**
```csharp
// Repositories/LeaveRepository.cs L29-32
public LeaveRepository(MyFitnessCoachDbContext context)
{
    _context = context;
}
```

### 2.5 介面與實作對照表

| 介面 | 實作類別 | 檔案位置 |
|------|---------|---------|
| `ILeaveRepository` | `LeaveRepository` | `Repositories/LeaveRepository.cs` |
| （無介面，直接注入） | `ReviewLeaveService` | `Services/ReviewLeaveService.cs` |

---

## 三、完整 Request 生命週期（以 `Pending` Action 為例）

### 步驟 1：HTTP Request

```
GET /ReviewLeave/Pending HTTP/1.1
Host: localhost
Cookie: MyFitnessCoach.Auth=<加密的認證 Cookie>
```

主管或代審人員透過瀏覽器發送 GET 請求，查看待審核假單列表。

### 步驟 2：Middleware Pipeline

```
HTTP Request
    │
    ▼
UseHttpsRedirection()     ← 將 HTTP 重導向至 HTTPS
    │
    ▼
UseStaticFiles()          ← 檢查是否為靜態檔案
    │
    ▼
UseRouting()              ← 路由比對
    │
    ▼
UseAuthentication()       ← 從 Cookie 解析 ClaimsPrincipal
    │                        解析出 EmployeeId, DepartmentId, Function Claims
    ▼
UseAuthorization()        ← 執行 [Authorize] + [FunctionOrDelegation] 過濾器
    │
    ▼
Endpoint Execution        ← 進入 Controller Action
```

### 步驟 3：路由匹配

```csharp
// Program.cs L185-187
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Account}/{action=Login}/{id?}");
```

路由解析結果：
- `controller` = `ReviewLeave`
- `action` = `Pending`
- Query String: `typeFilter` = 可選參數

### 步驟 4：DI 容器建立物件鏈

```
1. MyFitnessCoachDbContext     ← 已存在於 Scope 中則重用
2. LeaveRepository             ← new LeaveRepository(dbContext)
3. ReviewLeaveService          ← new ReviewLeaveService(leaveRepo, dbContext)
4. ReviewLeaveController       ← new ReviewLeaveController(reviewLeaveService)
```

### 步驟 5：Controller Action 執行

**授權過濾器 `[FunctionOrDelegation("review_LeaveRequests")]`（L19）：**

這是此 Controller 特有的雙重授權機制。與 `[Function]` 不同，它支援兩種授權方式：

```csharp
// Infra/FunctionOrDelegationAttribute.cs L24-53
public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
{
    // 條件一：Cookie Claims 中有 "review_LeaveRequests" Function → 放行
    var userFunctions = context.HttpContext.User.FindAll("Function")
                             .Select(c => c.Value);
    if (userFunctions.Contains(FunctionName))
        return; // 放行

    // 條件二：DB 查詢 LeaveApprovalDelegations → 有效代審授權 → 放行
    var employeeIdStr = context.HttpContext.User.FindFirst("EmployeeId")?.Value;
    if (int.TryParse(employeeIdStr, out var employeeId))
    {
        var db = context.HttpContext.RequestServices
            .GetRequiredService<MyFitnessCoachDbContext>();
        var hasActiveDelegation = await db.LeaveApprovalDelegations
            .AnyAsync(d => d.DelegateEmployeeId == employeeId
                && d.IsActive
                && d.StartDate <= now
                && d.EndDate >= now);
        if (hasActiveDelegation)
            return; // 放行
    }

    // 兩個條件都不符合 → 403
    context.Result = new ForbidResult();
}
```

**通過授權後，執行 Pending Action（L20-35）：**
```csharp
// Controllers/ReviewLeaveController.cs L20-35
[FunctionOrDelegation("review_LeaveRequests")]
public async Task<IActionResult> Pending(string typeFilter)
{
    var empId = User.GetEmployeeId();        // 擴展方法，從 Claims 取 EmployeeId
    if (empId == null) return Forbid();

    var vm = await _reviewService.GetPendingListAsync(empId.Value);
    vm.TypeFilter = typeFilter;

    // 依類型篩選
    if (typeFilter == "new")
        vm.Requests = vm.Requests.Where(r => !r.IsCancelRequest).ToList();
    else if (typeFilter == "cancel")
        vm.Requests = vm.Requests.Where(r => r.IsCancelRequest).ToList();

    return View(vm);
}
```

**`User.GetEmployeeId()` 擴展方法（Infra/ClaimExtensions.cs L7-8）：**
```csharp
public static int? GetEmployeeId(this ClaimsPrincipal user)
    => int.TryParse(user.FindFirst("EmployeeId")?.Value, out var id) ? id : null;
```

### 步驟 6：Service 層商業邏輯

```csharp
// Services/ReviewLeaveService.cs L41-70
public async Task<PendingReviewListViewModel> GetPendingListAsync(int managerEmployeeId)
{
    // 1. 透過 Repository 取得待審核假單
    var requests = await _repo.GetPendingByManagerIdAsync(managerEmployeeId);  // L43

    // 2. 轉換為 DTO
    var dtos = requests.Select(r => new PendingReviewDto                       // L45-61
    {
        Id = r.Id,
        ApplicantName = r.Employee?.User?.UserName,
        DepartmentName = r.Employee?.Department?.Name,
        LeaveTypeName = r.LeaveType?.Name,
        StartDate = r.StartDate,
        EndDate = r.EndDate,
        HoursUsed = r.HoursUsed ?? 0,
        DaysUsed = r.DaysUsed ?? 0,
        Reason = r.Reason,
        DelegateName = r.LeaveDelegate?.User?.UserName,
        CreatedAt = r.CreatedAt,
        IsCancelRequest = r.Status == "CancelPending",
        OriginalStatus = r.OriginalStatus,
        CancelReason = r.CancelReason
    }).ToList();

    // 3. 組裝 ViewModel（含統計數據）
    return new PendingReviewListViewModel                                      // L63-69
    {
        PendingCount = dtos.Count,
        NewLeaveCount = dtos.Count(d => !d.IsCancelRequest),
        CancelRequestCount = dtos.Count(d => d.IsCancelRequest),
        Requests = dtos
    };
}
```

### 步驟 7：Repository 層資料存取

```csharp
// Repositories/LeaveRepository.cs L112-134
public async Task<List<LeaveRequest>> GetPendingByManagerIdAsync(int reviewerEmployeeId)
{
    var now = DateTime.Now;
    return await _context.LeaveRequests
        .Include(r => r.Employee).ThenInclude(e => e.User)
        .Include(r => r.Employee).ThenInclude(e => e.Department)
        .Include(r => r.LeaveType)
        .Include(r => r.LeaveDelegate).ThenInclude(d => d.User)
        .Where(r => (r.Status == "Pending" || r.Status == "CancelPending")
            && (
                // 條件(1)：申請者的直屬主管就是 reviewer
                r.Employee.ManagerId == reviewerEmployeeId
                // 條件(2)：存在有效的代審授權
                || _context.LeaveApprovalDelegations.Any(d =>
                    d.ManagerEmployeeId == r.Employee.ManagerId
                    && d.DelegateEmployeeId == reviewerEmployeeId
                    && d.IsActive
                    && d.StartDate <= now
                    && d.EndDate >= now)
            ))
        .OrderByDescending(r => r.CreatedAt)
        .ToListAsync();
}
```

**關鍵查詢邏輯：**
- 查詢狀態為 `Pending` 或 `CancelPending` 的假單
- 雙重條件：直屬主管 OR 代審授權（子查詢 `LeaveApprovalDelegations`）
- Eager Loading：Employee → User/Department、LeaveType、LeaveDelegate → User

### 步驟 8：EF Core → SQL Server

EF Core 將 LINQ 轉譯為 SQL，大致如下：

```sql
SELECT lr.*, e.*, u.*, d.*, lt.*, ld.*, lu.*
FROM LeaveRequests lr
JOIN Employees e ON lr.EmployeeId = e.Id
JOIN Users u ON e.UserId = u.Id
JOIN Departments d ON e.DepartmentId = d.Id
JOIN LeaveTypes lt ON lr.LeaveTypeId = lt.Id
LEFT JOIN Employees ld ON lr.LeaveDelegateId = ld.Id
LEFT JOIN Users lu ON ld.UserId = lu.Id
WHERE (lr.Status = 'Pending' OR lr.Status = 'CancelPending')
  AND (
      e.ManagerId = @reviewerEmployeeId
      OR EXISTS (
          SELECT 1 FROM LeaveApprovalDelegations lad
          WHERE lad.ManagerEmployeeId = e.ManagerId
            AND lad.DelegateEmployeeId = @reviewerEmployeeId
            AND lad.IsActive = 1
            AND lad.StartDate <= @now
            AND lad.EndDate >= @now
      )
  )
ORDER BY lr.CreatedAt DESC
```

### 步驟 9：View 渲染

```
Controller 回傳: View(vm)
    │
    ▼
Razor 引擎載入: Views/ReviewLeave/Pending.cshtml
    │
    ▼
@model PendingReviewListViewModel
    │
    ▼
渲染 HTML：
  - 統計卡片（待審核總計、新假單數、取消請求數）
  - 類型篩選標籤（全部 / 新假單 / 取消請求）
  - 假單列表表格（申請人、部門、假別、日期、時數...）
  - 每列操作按鈕（核准 / 駁回）
  - TempData 訊息提示
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
ReviewLeaveController.Dispose()
    │
    ▼
ReviewLeaveService (Scoped, 生命週期結束)
    │
    ▼
LeaveRepository (Scoped, 生命週期結束)
    │
    ▼
MyFitnessCoachDbContext.Dispose()
  → 關閉 SQL Server 連線（歸還至連線池）
  → 釋放 Change Tracker 中的所有追蹤物件
```

---

## 四、其他 Action 生命週期

### 4.1 `Detail(int id)` (L39-48) — GET
```csharp
[FunctionOrDelegation("review_LeaveRequests")]
public async Task<IActionResult> Detail(int id)
{
    var empId = User.GetEmployeeId();
    if (empId == null) return Forbid();

    var dto = await _reviewService.GetDetailAsync(id, empId.Value);
    if (dto == null) return NotFound();

    return View(dto);
}
```
- **差異點：** 查詢單筆假單詳情，而非列表
- **Service 方法：** `GetDetailAsync(id, empId)` — 內部呼叫 `CanReviewAsync()` 驗證審核權限
- **權限驗證雙層：** Controller 層的 `[FunctionOrDelegation]` + Service 層的 `CanReviewAsync()`
- **回傳型別：** `LeaveRequestDto`（比 `PendingReviewDto` 包含更多欄位：Status、ApproverName、ApprovedAt 等）
- **View：** `Views/ReviewLeave/Detail.cshtml`

### 4.2 `Approve(int id)` (L54-67) — POST
```csharp
[HttpPost]
[ValidateAntiForgeryToken]
[FunctionOrDelegation("review_LeaveRequests")]
public async Task<IActionResult> Approve(int id)
{
    var empId = User.GetEmployeeId();
    if (empId == null) return Forbid();

    var result = await _reviewService.ApproveAsync(id, empId.Value);

    if (result.IsSuccess)
        TempData["SuccessMessage"] = "已核准該假單";
    else
        TempData["ErrorMessage"] = result.ErrorMessage;

    return RedirectToAction("Pending");
}
```
- **差異點：** HTTP POST + CSRF 防護
- **Service 邏輯（L93-112）：**
  1. 檢查假單狀態是否為 `Pending`
  2. 透過 `CanReviewAsync()` 驗證審核權限（直屬主管 OR 代審授權）
  3. 更新狀態為 `Approved`，記錄審核人和時間
  4. 呼叫 `_repo.UpdateAsync(request)` 儲存
- **回傳：** `Result` 物件（成功/失敗 + 錯誤訊息），使用 PRG 模式重導向

### 4.3 `Reject(int id, string rejectReason)` (L73-86) — POST
```csharp
[HttpPost]
[ValidateAntiForgeryToken]
[FunctionOrDelegation("review_LeaveRequests")]
public async Task<IActionResult> Reject(int id, string rejectReason)
```
- **差異點：** 需額外接收 `rejectReason` 參數
- **Service 邏輯（L114-166）：**
  1. 驗證 `rejectReason` 不可為空
  2. 更新狀態為 `Rejected`，記錄駁回原因
  3. **退還假期餘額：** 更新 `LeaveBalances.UsedDays -= DaysUsed`
  4. **寫入變動紀錄：** 新增 `LeaveBalanceHistory`（ChangeType = "Reject"）
- **關鍵差異：** 駁回時需要退還已扣除的假期天數，這是核准時不需要做的動作

### 4.4 `ApproveCancelRequest(int id)` (L92-105) — POST
```csharp
[HttpPost]
[ValidateAntiForgeryToken]
[FunctionOrDelegation("review_LeaveRequests")]
public async Task<IActionResult> ApproveCancelRequest(int id)
```
- **差異點：** 處理「取消請假」的核准，而非「請假」的核准
- **Service 邏輯（L170-218）：**
  1. 檢查狀態為 `CancelPending`（而非 `Pending`）
  2. 更新狀態為 `Cancelled`
  3. **退還假期餘額：** 與 Reject 相似的退還邏輯
  4. **寫入變動紀錄：** ChangeType = "CancelApproved"
- **與 Approve 的差異：** 狀態流從 `CancelPending` → `Cancelled`，且需退還天數

### 4.5 `RejectCancelRequest(int id, string rejectReason)` (L111-124) — POST
```csharp
[HttpPost]
[ValidateAntiForgeryToken]
[FunctionOrDelegation("review_LeaveRequests")]
public async Task<IActionResult> RejectCancelRequest(int id, string rejectReason)
```
- **差異點：** 駁回「取消請假」的請求
- **Service 邏輯（L220-245）：**
  1. 驗證 `rejectReason` 不可為空
  2. **恢復原狀態：** `request.Status = request.OriginalStatus`（不是設為新狀態，而是還原）
  3. 清除 `OriginalStatus`、`CancelRequestedAt`、`CancelReason`
  4. 記錄 `RejectReason`
- **不退還天數：** 因為是駁回取消，原假單維持有效，不需調整餘額

### 4.6 `List(string monthFilter, string employeeFilter, string statusFilter)` (L128-137) — GET
```csharp
[Function("view_DeptLeave")]
public async Task<IActionResult> List(string monthFilter, string employeeFilter, string statusFilter)
```
- **差異點：** 使用 `[Function("view_DeptLeave")]` 而非 `[FunctionOrDelegation]`
- **功能：** 部門請假總覽（非審核功能，只是查看）
- **Service 邏輯（L285-349）：**
  1. 查詢主管所在部門
  2. 取得該部門所有假單（`_repo.GetByDepartmentAsync`）
  3. 根據篩選條件（月份、員工、狀態）過濾
  4. 取得部門員工清單供下拉選單使用
- **回傳：** `DeptLeaveListViewModel`（含統計、篩選器、員工下拉選項）
- **View：** `Views/ReviewLeave/List.cshtml`

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── ReviewLeaveController.cs
├── Services/
│   └── ReviewLeaveService.cs
├── Repositories/
│   └── LeaveRepository.cs           (含 ILeaveRepository 介面，與 LeaveService 共用)
├── Models/
│   ├── EfModels/
│   │   ├── LeaveRequest.cs           (Entity)
│   │   ├── LeaveType.cs
│   │   ├── LeaveBalance.cs
│   │   ├── LeaveBalanceHistory.cs
│   │   ├── LeaveApprovalDelegation.cs
│   │   ├── LeaveAttachment.cs
│   │   ├── Employee.cs
│   │   ├── Department.cs
│   │   ├── User.cs
│   │   └── MyFitnessCoachDbContext.cs
│   ├── DTOs/
│   │   ├── PendingReviewDto.cs
│   │   ├── LeaveRequestDto.cs
│   │   ├── DeptLeaveOverviewDto.cs
│   │   └── Result.cs
│   └── ViewModels/
│       ├── PendingReviewListViewModel.cs
│       └── DeptLeaveListViewModel.cs
├── Infra/
│   ├── FunctionOrDelegationAttribute.cs
│   ├── FunctionAttribute.cs
│   └── ClaimExtensions.cs
└── Views/
    └── ReviewLeave/
        ├── Pending.cshtml
        ├── Detail.cshtml
        └── List.cshtml
```

### 5.2 Entity 關聯鏈

```
LeaveRequest (請假單)
├── EmployeeId → Employee (申請人)
│                 ├── UserId → User (使用者帳號)
│                 ├── DepartmentId → Department (部門)
│                 ├── ManagerId → Employee (直屬主管, 自參考)
│                 └── WorkDelegateId → Employee (職務代理人, 自參考)
├── LeaveTypeId → LeaveType (假別)
├── LeaveDelegateId → Employee (請假代理人)
├── ApprovedBy → Employee (審核人)
├── LeaveAttachments (附件, 1:N)
└── LeaveApprovalDelegations (代審授權, 1:N)

LeaveBalance (假期餘額)
├── EmployeeId → Employee
├── LeaveTypeId → LeaveType
├── Year
├── TotalDays / UsedDays
└── LeaveBalanceHistories (變動紀錄, 1:N)
     ├── ChangeType ("Reject", "CancelApproved")
     ├── ChangeDays, OldUsedDays, NewUsedDays
     └── OperatorId (審核人)

LeaveApprovalDelegation (代審授權)
├── ManagerEmployeeId → Employee (原主管)
├── DelegateEmployeeId → Employee (代審人)
├── IsActive, StartDate, EndDate
```

---

## 六、重要概念總整理

### 6.1 自訂授權過濾器 `[FunctionOrDelegation]`
- 與 `[Function]` 的差異：`[FunctionOrDelegation]` 提供兩種授權路徑
  1. **Claims 授權：** Cookie 中包含指定 Function Claim → 直接放行
  2. **DB 代審授權：** 查詢 `LeaveApprovalDelegations` 表，若存在有效（IsActive、日期範圍內）的代審記錄 → 放行
- 此設計使得即使沒有 `review_LeaveRequests` Function Claim 的員工，只要有代審授權，也能執行審核操作

### 6.2 雙層權限驗證
- **第一層（Controller）：** `[FunctionOrDelegation]` 過濾器 — 在 Action 執行前攔截
- **第二層（Service）：** `CanReviewAsync()` — 在業務邏輯中再次驗證具體假單的審核權限
- 兩層驗證確保即使繞過 Controller 層（如直接 API 呼叫），Service 層仍能阻擋未授權操作

### 6.3 `CanReviewAsync()` 審核權限判斷
```
Service 層的 CanReviewAsync() 判斷邏輯：
├── 條件一：申請人的 ManagerId == 審核人 EmployeeId（直屬主管）
└── 條件二：DB LeaveApprovalDelegations 有效代審授權
```

另有同步版 `CanReview()` 方法（L75-89），增加第三種情境：
```
├── 情境一：一般員工 — 由 ManagerId 審核
└── 情境二：主管本人（ManagerId 為 NULL）— 由 WorkDelegateId 審核
```

### 6.4 假單狀態機
```
┌─────────┐     核准      ┌──────────┐
│ Pending │─────────────→│ Approved  │
│（待審核）│               │（已核准） │
└────┬────┘               └─────┬────┘
     │                          │
     │ 駁回                      │ 申請取消
     │                          │
     ▼                          ▼
┌──────────┐            ┌──────────────┐
│ Rejected │            │ CancelPending│
│（已駁回） │            │（取消審核中） │
└──────────┘            └──────┬───────┘
                               │
                    ┌──────────┼──────────┐
                    │ 核准取消   │          │ 駁回取消
                    ▼          │          ▼
             ┌───────────┐    │   ┌──────────────┐
             │ Cancelled  │    │   │ 恢復原狀態     │
             │（已取消）   │    │   │ (OriginalStatus)│
             └───────────┘    │   └──────────────┘
```

### 6.5 假期餘額退還機制
- **駁回時退還（Reject）：** `balance.UsedDays -= request.DaysUsed`
- **核准取消時退還（ApproveCancelAsync）：** 同樣 `balance.UsedDays -= request.DaysUsed`
- **變動紀錄（LeaveBalanceHistory）：** 每次餘額變動都寫入歷史，記錄 ChangeType、ChangeDays、OldUsedDays、NewUsedDays

### 6.6 ClaimExtensions 擴展方法
- `User.GetEmployeeId()` — 從 ClaimsPrincipal 中解析 `EmployeeId` Claim
- `User.GetDepartmentId()` — 從 ClaimsPrincipal 中解析 `DepartmentId` Claim
- 所有 Action 都使用 `GetEmployeeId()` 取得當前使用者的員工 ID

### 6.7 PRG（Post-Redirect-Get）模式
- 所有 POST Action 都使用 `RedirectToAction("Pending")` 回傳
- 使用 `TempData["SuccessMessage"]` / `TempData["ErrorMessage"]` 傳遞結果訊息
- `Result` DTO 封裝操作結果（`IsSuccess` + `ErrorMessage`）

---

## 七、完整資料流圖

### 7.1 Pending 列表資料流

```
[Browser]
    │ GET /ReviewLeave/Pending?typeFilter=new
    ▼
[Middleware] ── Cookie 認證 → ClaimsPrincipal (含 EmployeeId Claim)
    │
    ▼
[FunctionOrDelegationAttribute]
    │ 檢查 "review_LeaveRequests" Claim
    │ OR 查詢 LeaveApprovalDelegations 代審授權
    │ (通過)
    ▼
[ReviewLeaveController.Pending("new")]
    │ empId = User.GetEmployeeId()
    ▼
[ReviewLeaveService.GetPendingListAsync(empId)]
    │
    ▼
[LeaveRepository.GetPendingByManagerIdAsync(empId)]
    │ WHERE Status IN ('Pending','CancelPending')
    │ AND (ManagerId = empId OR 代審授權存在)
    ▼
[DbContext] ──→ SQL Server
    │
    ▼
[List<LeaveRequest>] → 轉換為 List<PendingReviewDto>
    │
    ▼
[PendingReviewListViewModel] (含統計: PendingCount, NewLeaveCount, CancelRequestCount)
    │
    ▼
[Controller 層篩選] typeFilter="new" → 過濾掉 IsCancelRequest=true 的項目
    │
    ▼
[View: Pending.cshtml] → HTML Response → Browser
```

### 7.2 Approve 審核流程

```
[Browser]
    │ POST /ReviewLeave/Approve (id=10, __RequestVerificationToken=...)
    ▼
[Middleware] ── Cookie 認證 + CSRF Token 驗證
    │
    ▼
[FunctionOrDelegationAttribute] ── 授權檢查
    │
    ▼
[ReviewLeaveController.Approve(10)]
    │ empId = User.GetEmployeeId()
    ▼
[ReviewLeaveService.ApproveAsync(10, empId)]
    │
    ├──→ [LeaveRepository.GetByIdAsync(10)]
    │         ▼
    │    LeaveRequest entity (Status = "Pending")
    │
    ├──→ [CanReviewAsync(request, empId)]
    │         ▼
    │    true (直屬主管 OR 代審授權)
    │
    ├──→ request.Status = "Approved"
    │    request.ApprovedBy = empId
    │    request.ApprovedAt = DateTime.Now
    │
    └──→ [LeaveRepository.UpdateAsync(request)]
              ▼
         UPDATE LeaveRequests SET Status='Approved', ApprovedBy=..., ApprovedAt=...
    │
    ▼
[Result.Success(null)]
    │
    ▼
[TempData["SuccessMessage"] = "已核准該假單"]
    │
    ▼
[RedirectToAction("Pending")]
    │
    ▼
[HTTP 302] → Browser 重新 GET /ReviewLeave/Pending
```

### 7.3 Reject 駁回流程（含餘額退還）

```
[Browser]
    │ POST /ReviewLeave/Reject (id=10, rejectReason="出勤紀錄不符")
    ▼
[ReviewLeaveService.RejectAsync(10, empId, "出勤紀錄不符")]
    │
    ├──→ 驗證 rejectReason 不為空
    ├──→ GetByIdAsync(10) → 取得假單
    ├──→ CanReviewAsync() → 權限驗證
    │
    ├──→ request.Status = "Rejected"
    │    request.RejectReason = "出勤紀錄不符"
    │    [LeaveRepository.UpdateAsync(request)]
    │
    └──→ 退還假期餘額：
         │
         ├──→ [DbContext.LeaveBalances] → 查詢對應餘額
         │         WHERE EmployeeId AND LeaveTypeId AND Year
         │
         ├──→ balance.UsedDays -= request.DaysUsed
         │
         └──→ [DbContext.LeaveBalanceHistories.Add()]
                   ChangeType = "Reject"
                   ChangeDays = request.DaysUsed
                   Reason = "假單駁回退還：{假別名稱}"
              │
              ▼
         [DbContext.SaveChangesAsync()] → SQL Server
```

---

## 八、涉及的關鍵檔案清單

| 檔案 | 路徑 | 說明 |
|------|------|------|
| ReviewLeaveController.cs | `Controllers/ReviewLeaveController.cs` | 控制器，7 個 Action |
| ReviewLeaveService.cs | `Services/ReviewLeaveService.cs` | 業務邏輯層（審核、餘額退還） |
| LeaveRepository.cs | `Repositories/LeaveRepository.cs` | 資料存取層（含 ILeaveRepository 介面） |
| LeaveRequest.cs | `Models/EfModels/LeaveRequest.cs` | EF Core Entity（假單） |
| PendingReviewDto.cs | `Models/DTOs/PendingReviewDto.cs` | 待審核列表 DTO |
| LeaveRequestDto.cs | `Models/DTOs/LeaveRequestDto.cs` | 假單詳情 DTO |
| DeptLeaveOverviewDto.cs | `Models/DTOs/DeptLeaveOverviewDto.cs` | 部門總覽 DTO |
| Result.cs | `Models/DTOs/Result.cs` | 操作結果封裝 |
| PendingReviewListViewModel.cs | `Models/ViewModels/PendingReviewListViewModel.cs` | 待審核列表 ViewModel |
| DeptLeaveListViewModel.cs | `Models/ViewModels/DeptLeaveListViewModel.cs` | 部門請假總覽 ViewModel |
| FunctionOrDelegationAttribute.cs | `Infra/FunctionOrDelegationAttribute.cs` | 自訂雙重授權過濾器 |
| FunctionAttribute.cs | `Infra/FunctionAttribute.cs` | 自訂功能授權過濾器 |
| ClaimExtensions.cs | `Infra/ClaimExtensions.cs` | ClaimsPrincipal 擴展方法 |
| Pending.cshtml | `Views/ReviewLeave/Pending.cshtml` | 待審核列表頁面 |
| Detail.cshtml | `Views/ReviewLeave/Detail.cshtml` | 假單詳情頁面 |
| List.cshtml | `Views/ReviewLeave/List.cshtml` | 部門請假總覽頁面 |
| Program.cs | `Program.cs` | DI 註冊（L106, L108） |

---

## 九、程式碼優化建議

### 9.1 ReviewLeaveService 中直接使用 DbContext

**問題：** `ReviewLeaveService` 同時注入了 `ILeaveRepository` 和 `MyFitnessCoachDbContext`。在 `RejectAsync()` (L138-163) 和 `ApproveCancelAsync()` (L190-215) 中直接查詢並更新 `_db.LeaveBalances` 和 `_db.LeaveBalanceHistories`，繞過了 Repository 層。

**原因：** 這破壞了三層式架構的一致性。假期餘額的退還邏輯屬於資料存取層的職責，不應在 Service 層直接操作 DbContext。

**建議改法：**
- 在 `ILeaveRepository` 新增方法（如 `RefundLeaveBalanceAsync(int employeeId, int leaveTypeId, int year, decimal daysToRefund, string reason, int operatorId)`）
- 或新增 `ILeaveBalanceRepository` 負責餘額相關操作
- Service 層透過 Repository 介面完成餘額退還

### 9.2 餘額退還邏輯重複

**問題：** `RejectAsync()` (L137-163) 和 `ApproveCancelAsync()` (L188-215) 中的餘額退還邏輯幾乎完全相同，僅 `ChangeType` 和 `Reason` 字串不同。

**原因：** 若需修改退還邏輯（例如增加日誌記錄或驗證），需同時修改兩處。

**建議改法：** 抽取為私有方法：
```csharp
private async Task RefundLeaveBalanceAsync(LeaveRequest request, int operatorId, string changeType, string reasonPrefix)
{
    var year = request.StartDate.Year;
    var balance = await _db.LeaveBalances
        .FirstOrDefaultAsync(b => b.EmployeeId == request.EmployeeId
            && b.LeaveTypeId == request.LeaveTypeId && b.Year == year);
    if (balance != null)
    {
        var oldUsed = balance.UsedDays ?? 0;
        balance.UsedDays = (balance.UsedDays ?? 0) - (request.DaysUsed ?? 0);
        _db.LeaveBalanceHistories.Add(new LeaveBalanceHistory { ... });
        await _db.SaveChangesAsync();
    }
}
```

### 9.3 Controller 層的篩選邏輯

**問題：** `Pending()` Action (L29-33) 在 Controller 層對 `vm.Requests` 進行篩選（typeFilter == "new" 或 "cancel"），這是業務邏輯混入了 Controller 層。

**原因：** Controller 應只負責接收參數和回傳結果，篩選邏輯應在 Service 層處理。當前設計意味著 Service 先從資料庫取回全部資料，Controller 再做記憶體篩選，效率較低。

**建議改法：** 將 `typeFilter` 參數傳入 Service 方法：
```csharp
var vm = await _reviewService.GetPendingListAsync(empId.Value, typeFilter);
return View(vm);
```

### 9.4 `CanReviewAsync` 和 `CanReview` 方法並存

**問題：** 存在非同步版本 `CanReviewAsync()` (L23-37) 和同步版本 `CanReview()` (L75-89) 兩個方法，邏輯類似但不完全相同。

**原因：**
- `CanReviewAsync()` 支援直屬主管 + DB 代審授權查詢
- `CanReview()` 支援直屬主管 + 職務代理人（`WorkDelegateId`）
- 兩者的授權邏輯不一致，可能造成混淆。且 `CanReview()` 在目前程式碼中未被呼叫。

**建議改法：**
- 若 `CanReview()` 確實未使用，可移除以減少維護負擔
- 若兩種授權邏輯都需要，統一為一個方法，合併所有授權條件

### 9.5 `GetDeptOverviewAsync` 的記憶體篩選

**問題：** `GetDeptOverviewAsync()` (L285-349) 先取回部門所有假單再在記憶體中篩選月份、員工、狀態（L298-310）。

**原因：** 當部門假單數量大時，每次請求都取回全部資料再篩選，會造成不必要的資料庫 IO 和記憶體消耗。

**建議改法：** 在 Repository 層新增支援篩選參數的查詢方法，讓篩選條件在 SQL 層級執行：
```csharp
Task<List<LeaveRequest>> GetByDepartmentFilteredAsync(
    int departmentId, int? year, int? month, int? employeeId, string status);
```
