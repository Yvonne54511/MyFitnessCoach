# KeyWordsController 完整 MVC 生命週期說明（含 DI 注入與重要概念）

## 一、全局架構概覽

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Browser (HTTP Request)                             │
│                     GET /KeyWords/Index                                          │
│                     POST /KeyWords/Create                                        │
│                     POST /KeyWords/UpdateCategory                                │
└─────────────────────────┬───────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          ASP.NET Core Middleware Pipeline                        │
│  ┌──────────────────┐ ┌──────────────────┐ ┌────────────────┐ ┌──────────────┐ │
│  │UseHttpsRedirection│→│ UseStaticFiles   │→│UseAuthentication│→│UseAuthorization│
│  └──────────────────┘ └──────────────────┘ └────────────────┘ └──────────────┘ │
│                                                                                 │
│  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────────────────────┐ │
│  │  UseRouting       │→│ [Authorize]      │→│ [Function("view_KeyWords")]      │ │
│  └──────────────────┘ └──────────────────┘ └──────────────────────────────────┘ │
└─────────────────────────┬───────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        DI 容器建立物件鏈 (Scoped)                                │
│                                                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────┐   │
│  │ KeyWordsController                                                       │   │
│  │   └── IKeyWordService  → KeyWordService                                  │   │
│  │           └── IKeyWordRepository → KeyWordRepository                     │   │
│  │                   └── MyFitnessCoachDbContext                            │   │
│  └──────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────┬───────────────────────────────────────────────────────┘
                          │
                          ▼
┌───────────────────┐   ┌───────────────────┐   ┌───────────────────┐
│  Controller       │──▶│  Service 層        │──▶│  Repository 層    │
│  (Action 執行)    │   │  (商業邏輯/映射)   │   │  (資料存取)       │
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
                                                │  (KeyWords 資料表) │
                                                └───────────────────┘
```

**DI 注入對象：**
- `IKeyWordService` → 負責關鍵字的 CRUD 商業邏輯與 Entity ↔ DTO 轉換

---

## 二、DI（依賴注入）機制

### 2.1 Program.cs 中的註冊（附行號）

```csharp
// Program.cs L89-90：KeyWord 模組
builder.Services.AddScoped<IKeyWordRepository, KeyWordRepository>();  // L89
builder.Services.AddScoped<IKeyWordService, KeyWordService>();        // L90

// Program.cs L24-25：DbContext 註冊
builder.Services.AddDbContext<MyFitnessCoachDbContext>(options =>      // L24
    options.UseSqlServer(...));                                        // L25

// Program.cs L119-129：Cookie Authentication
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)  // L119
    .AddCookie(options => { ... });                                                    // L120-129
```

### 2.2 生命週期範圍

| 服務                       | 生命週期   | 說明                                     |
| -------------------------- | ---------- | ---------------------------------------- |
| `IKeyWordService`          | **Scoped** | 每次 HTTP Request 建立一個實例           |
| `IKeyWordRepository`       | **Scoped** | 每次 HTTP Request 建立一個實例           |
| `MyFitnessCoachDbContext`  | **Scoped** | EF Core 預設為 Scoped，同一 Request 共用 |

### 2.3 DI 注入鏈（由下往上）

```
SQL Server
    ↑
MyFitnessCoachDbContext (Scoped)
    ↑
KeyWordRepository (Scoped)
    ↑
KeyWordService (Scoped)
    ↑
KeyWordsController
```

這是一條標準的三層式架構注入鏈，Controller → Service → Repository → DbContext，每一層僅依賴下一層的介面。

### 2.4 建構子程式碼（附行號）

**KeyWordsController 建構子** (`Controllers/KeyWordsController.cs` L15-20)：

```csharp
// L15: private readonly IKeyWordService _service;

// L17-20
public KeyWordsController(IKeyWordService service)
{
    _service = service;
}
```

**KeyWordService 建構子** (`Services/KeyWordService.cs` L19-24)：

```csharp
// L19: private readonly IKeyWordRepository _repository;

// L21-24
public KeyWordService(IKeyWordRepository repository)
{
    _repository = repository;
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

| 介面                   | 實作類別           | 註冊位置        |
| ---------------------- | ------------------ | --------------- |
| `IKeyWordService`      | `KeyWordService`   | Program.cs L90  |
| `IKeyWordRepository`   | `KeyWordRepository`| Program.cs L89  |

---

## 三、完整 Request 生命週期（以 `Index` Action 為例）

### 步驟 1：HTTP Request

```
使用者在瀏覽器輸入或點擊連結：
GET https://localhost:xxxx/KeyWords/Index HTTP/1.1
Cookie: MyFitnessCoach.Auth=<加密 Token>
```

- 瀏覽器發送 GET 請求，攜帶 Cookie 認證資訊
- 此 Controller 需要認證 `[Authorize]` 且需要權限 `[Function("view_KeyWords")]`

### 步驟 2：Middleware Pipeline

請求依序通過以下中介軟體（`Program.cs` L131-187）：

1. **UseExceptionHandler** (L136/142)：全域例外處理
2. **UseStatusCodePagesWithReExecute** (L145)：HTTP 狀態碼錯誤頁面
3. **UseHttpsRedirection** (L147)：強制 HTTPS
4. **UseStaticFiles** (L149-176)：靜態檔案處理
5. **UseRouting** (L178)：路由中介軟體
6. **UseAuthentication** (L180)：Cookie 認證，解析 Cookie → `ClaimsPrincipal`
7. **UseAuthorization** (L181)：授權檢查

授權後，進入 `[Authorize]` 檢查（Controller 層級 L11）和 `[Function("view_KeyWords")]` 檢查（Controller 層級 L12）：

- `[Authorize]`：驗證使用者是否已登入，未登入導向 `/Account/Login`
- `[Function("view_KeyWords")]`：自訂 `FunctionAttribute` 檢查使用者 Claims 中是否包含 `Function = "view_KeyWords"`
  - 若無權限，回傳 `ForbidResult` → 導向 `/Home/Error/403`

### 步驟 3：路由匹配

```
路由範本 (Program.cs L185-187):
"{controller=Account}/{action=Login}/{id?}"

匹配結果:
  controller = "KeyWords"
  action     = "Index"
```

### 步驟 4：DI 容器建立物件鏈

```
1. 建立 MyFitnessCoachDbContext (Scoped)
2. 建立 KeyWordRepository(MyFitnessCoachDbContext)
3. 建立 KeyWordService(IKeyWordRepository)
4. 建立 KeyWordsController(IKeyWordService)
```

### 步驟 5：Controller Action 執行

**`KeyWordsController.Index`** (`Controllers/KeyWordsController.cs` L23-34)：

```csharp
// L23-34
public async Task<IActionResult> Index()
{
    var dtos = await _service.GetAllAsync();                           // L25
    // 只顯示正向 (1) 和 負向 (-1) 的關鍵字，忽略類別 0
    var vms = dtos.Where(d => d.Category != 0).Select(d => new KeyWordViewModel {  // L27-32
        Id = d.Id,
        Word = d.Word,
        Category = d.Category,
        Weight = d.Weight
    });
    return View(vms);                                                  // L33
}
```

**注意：** Controller 層負責 DTO → ViewModel 的轉換，並過濾掉 Category == 0 的項目。

### 步驟 6：Service 層商業邏輯

**`KeyWordService.GetAllAsync`** (`Services/KeyWordService.cs` L26-35)：

```csharp
// L26-35
public async Task<IEnumerable<KeyWordDto>> GetAllAsync()
{
    var entities = await _repository.GetAllAsync();                     // L28
    return entities.Select(e => new KeyWordDto {                       // L29-34
        Id = e.Id,
        Word = e.Word,
        Category = e.Category,
        Weight = e.Weight
    });
}
```

**Service 層職責：** 將 Entity 轉換為 DTO（Entity → DTO 映射）。

### 步驟 7：Repository 層資料存取

**`KeyWordRepository.GetAllAsync`** (`Repositories/KeyWordRepository.cs` L25-28)：

```csharp
// L25-28
public async Task<IEnumerable<KeyWord>> GetAllAsync()
{
    return await _context.KeyWords.ToListAsync();                      // L27
}
```

### 步驟 8：EF Core → SQL Server

EF Core 產生 SQL：

```sql
SELECT [k].[Id], [k].[Word], [k].[Category], [k].[Weight]
FROM [KeyWords] AS [k]
```

### 步驟 9：View 渲染

框架將 `IEnumerable<KeyWordViewModel>` 傳入 `Views/KeyWords/Index.cshtml`：

- **Model 型別**：`@model IEnumerable<Project_MyFitnessCoach.Models.ViewModels.KeyWordViewModel>`
- **前端功能**：
  - DataTables jQuery 外掛（分頁、搜尋、排序）
  - SweetAlert2 刪除確認對話框
  - AJAX 即時更新類別（`updateCategory` 呼叫 `/KeyWords/UpdateCategory`）
  - AJAX 即時更新權重（`updateWeight` 呼叫 `/KeyWords/UpdateWeight`）
  - 動態色彩：根據 Category 和 Weight 計算 HSL 色相的明度

### 步驟 10：HTTP Response

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<html>
  <!-- 關鍵字詞管理列表 + DataTables + AJAX 操作 -->
</html>
```

### 步驟 11：Scoped 物件 Dispose

Request 結束後，DI 容器依序 Dispose：
1. `KeyWordsController`
2. `KeyWordService`
3. `KeyWordRepository`
4. `MyFitnessCoachDbContext`（釋放資料庫連線回 Connection Pool）

---

## 四、其他 Action 生命週期

### 4.1 `Create` GET Action (`Controllers/KeyWordsController.cs` L37-40)

```csharp
// L37-40
public IActionResult Create()
{
    return View();
}
```

**與 Index 的差異：**
- **不呼叫 Service**：純粹回傳空的 Create 表單
- **不需要額外權限**：繼承 Controller 層級的 `[Function("view_KeyWords")]`
- **View**：`Create.cshtml` 包含 Word、Category（下拉選單）、Weight（數字輸入）欄位

### 4.2 `Create` POST Action (`Controllers/KeyWordsController.cs` L43-59)

```csharp
// L43-59
[HttpPost]
[ValidateAntiForgeryToken]
[Function("create_KeyWords")]
public async Task<IActionResult> Create(KeyWordViewModel vm)
{
    if (ModelState.IsValid)                                            // L48
    {
        var dto = new KeyWordDto {                                     // L50-54
            Word = vm.Word,
            Category = vm.Category,
            Weight = vm.Weight
        };
        await _service.CreateAsync(dto);                               // L55
        return RedirectToAction(nameof(Index));                        // L56
    }
    return View(vm);                                                   // L58
}
```

**與 Index 的差異：**

| 差異項目                | Index                              | Create POST                                |
| ----------------------- | ---------------------------------- | ------------------------------------------ |
| **HTTP 方法**           | GET                                | POST                                       |
| **CSRF 防護**           | 無（GET 不需要）                   | `[ValidateAntiForgeryToken]` (L44)         |
| **額外權限**            | `[Function("view_KeyWords")]`      | `[Function("create_KeyWords")]` (L45)      |
| **Model Binding**       | 無參數                             | `KeyWordViewModel vm`                      |
| **Model Validation**    | 無                                 | `ModelState.IsValid` 檢查 (L48)            |
| **轉換方向**            | Entity → DTO → ViewModel          | ViewModel → DTO → Entity                  |
| **回傳**                | `View(vms)`                        | 成功：`RedirectToAction`；失敗：`View(vm)` |

**Service 層呼叫** (`Services/KeyWordService.cs` L49-57)：

```csharp
// L49-57
public async Task CreateAsync(KeyWordDto dto)
{
    var entity = new KeyWord {                                         // L51-55
        Word = dto.Word.Trim(),          // 注意：Service 層做了 Trim()
        Category = dto.Category,
        Weight = dto.Weight
    };
    await _repository.CreateAsync(entity);                             // L56
}
```

**Repository 層** (`Repositories/KeyWordRepository.cs` L35-39)：

```csharp
// L35-39
public async Task CreateAsync(KeyWord keyWord)
{
    _context.KeyWords.Add(keyWord);                                    // L37
    await _context.SaveChangesAsync();                                 // L38
}
```

### 4.3 `DeleteConfirmed` Action (`Controllers/KeyWordsController.cs` L62-68)

```csharp
// L62-68
[HttpPost, ActionName("Delete")]
[ValidateAntiForgeryToken]
public async Task<IActionResult> DeleteConfirmed(int id)
{
    await _service.DeleteAsync(id);                                    // L66
    return RedirectToAction(nameof(Index));                            // L67
}
```

**與 Index 的差異：**
- **HTTP 方法**：POST（透過前端隱藏 form 提交）
- **`[ActionName("Delete")]`**：URL 路由為 `/KeyWords/Delete`，但方法名為 `DeleteConfirmed`（避免與 GET Delete 衝突的 ASP.NET MVC 慣例）
- **無額外 `[Function]`**：繼承 Controller 層級權限
- **前端觸發**：SweetAlert2 確認後提交 `<form asp-action="Delete">`
- **Service → Repository**：`DeleteAsync` 使用 `FindAsync` 找到後 `Remove` + `SaveChangesAsync`

### 4.4 `UpdateCategory` Action (`Controllers/KeyWordsController.cs` L71-82)

```csharp
// L71-82
[HttpPost]
[Function("edit_KeyWords")]
public async Task<IActionResult> UpdateCategory(int id, int category)
{
    if (category == 0)                                                 // L75
    {
        await _service.DeleteAsync(id);                                // L77
        return Ok(new { deleted = true });                             // L78
    }
    await _service.UpdateCategoryAsync(id, category);                  // L80
    return Ok(new { deleted = false });                                // L81
}
```

**與 Index 的差異：**
- **AJAX JSON 回傳**：使用 `Ok(new { ... })` 回傳 JSON
- **權限控制**：Action 層級 `[Function("edit_KeyWords")]` (L72)
- **特殊邏輯**：Category == 0 時執行刪除而非更新（忽略 = 刪除）
- **前端處理**：jQuery AJAX `$.post()` + Toast 通知 + 動態移除 DOM 列

### 4.5 `UpdateWeight` Action (`Controllers/KeyWordsController.cs` L85-91)

```csharp
// L85-91
[HttpPost]
[Function("edit_KeyWords")]
public async Task<IActionResult> UpdateWeight(int id, int weight)
{
    await _service.UpdateWeightAsync(id, weight);                      // L89
    return Ok();                                                       // L90
}
```

**與 Index 的差異：**
- **最簡 AJAX Action**：僅呼叫 Service 更新權重，回傳 200 OK
- **權限控制**：`[Function("edit_KeyWords")]` (L86)
- **Repository 層** (`Repositories/KeyWordRepository.cs` L51-58)：使用 `FindAsync` + 修改屬性 + `SaveChangesAsync`

---

## 五、資料模型層級關係

### 5.1 檔案目錄樹

```
Project-MyFitnessCoach/
├── Controllers/
│   └── KeyWordsController.cs
├── Services/
│   └── KeyWordService.cs               (IKeyWordService + KeyWordService)
├── Repositories/
│   └── KeyWordRepository.cs            (IKeyWordRepository + KeyWordRepository)
├── Models/
│   ├── EfModels/
│   │   ├── MyFitnessCoachDbContext.cs
│   │   └── KeyWord.cs                  (Entity)
│   ├── ViewModels/
│   │   └── KeyWordViewModel.cs
│   ├── DTOs/
│   │   └── KeyWordDto.cs
│   └── Infra/
│       └── FunctionAttribute.cs        (自訂授權過濾器)
├── Infra/
│   └── FunctionAttribute.cs            (同上，實際位置)
├── Views/
│   └── KeyWords/
│       ├── Index.cshtml
│       └── Create.cshtml
└── Program.cs
```

### 5.2 Entity 關聯鏈

```
KeyWord (Models/EfModels/KeyWord.cs)
├── Id       : int       // 主鍵
├── Word     : string    // 關鍵字詞內容
├── Category : int       // 分類 (1: 正向, -1: 負向, 0: 忽略)
└── Weight   : int       // 權重 (1-5)

轉換鏈：
KeyWord (Entity) ←→ KeyWordDto (DTO) ←→ KeyWordViewModel (ViewModel)
```

三層轉換對照：

| Entity (KeyWord) | DTO (KeyWordDto) | ViewModel (KeyWordViewModel) |
| ----------------- | ---------------- | ---------------------------- |
| `Id`              | `Id`             | `Id`                         |
| `Word`            | `Word`           | `Word` + `[Required]` + `[StringLength(50)]` |
| `Category`        | `Category`       | `Category` + `[Display]`     |
| `Weight`          | `Weight`         | `Weight` + `[Display]`       |

---

## 六、重要概念總整理

### 6.1 雙層授權機制：`[Authorize]` + `[Function]`

```csharp
[Authorize]                        // L11: 第一層 - 登入檢查
[Function("view_KeyWords")]        // L12: 第二層 - 功能權限檢查
public class KeyWordsController : Controller
```

**第一層 `[Authorize]`：**
- 檢查 Cookie 認證是否有效
- 未登入 → 導向 `/Account/Login` (Program.cs L123)

**第二層 `[Function("view_KeyWords")]`：**
- 自訂的 `FunctionAttribute` (`Infra/FunctionAttribute.cs` L11-39)
- 實作 `IAsyncAuthorizationFilter`
- 檢查 `ClaimsPrincipal` 中是否包含 `Function = "view_KeyWords"` 的 Claim
- 無權限 → `ForbidResult` → 導向 `/Home/Error/403`

**Action 層級額外權限：**
- `Create POST`：需要 `[Function("create_KeyWords")]` (L45)
- `UpdateCategory`：需要 `[Function("edit_KeyWords")]` (L72)
- `UpdateWeight`：需要 `[Function("edit_KeyWords")]` (L86)

### 6.2 三層式轉換模式

KeyWordsController 嚴格遵循三層式架構的資料轉換模式：

```
Controller 層：ViewModel ↔ DTO 轉換
Service 層：DTO ↔ Entity 轉換
Repository 層：Entity ↔ 資料庫

完整流程 (Create)：
前端 form → Model Binding → KeyWordViewModel
    → Controller 手動映射 → KeyWordDto
    → Service 手動映射 → KeyWord (Entity)
    → Repository → EF Core → SQL INSERT

完整流程 (Index)：
SQL SELECT → EF Core → KeyWord (Entity)
    → Repository 回傳 → IEnumerable<KeyWord>
    → Service 映射 → IEnumerable<KeyWordDto>
    → Controller 映射 + 過濾 → IEnumerable<KeyWordViewModel>
    → View 渲染
```

### 6.3 Category 值的語義設計

| Category 值 | 語義     | 在 Index 中的處理            | 在 UpdateCategory 中的處理   |
| ----------- | -------- | ---------------------------- | ---------------------------- |
| `1`         | 正向詞彙 | 顯示（綠色 Badge）           | 正常更新                     |
| `-1`        | 負向詞彙 | 顯示（紅色 Badge）           | 正常更新                     |
| `0`         | 忽略     | 被 `Where(d.Category != 0)` 過濾 | 執行**刪除**而非更新 (L75-78) |

### 6.4 動態色彩計算

View 中的 Badge 色彩根據 Category 和 Weight 動態計算 HSL 值：

```csharp
// Index.cshtml L69-70
int lightness = Math.Max(10, 50 - (item.Weight * 8));
badgeStyle = $"background-color: hsl(120, 70%, {lightness}%); color: white;";  // 正向：綠色
// 權重 1 → lightness=42 (淺綠)
// 權重 5 → lightness=10 (深綠)
```

這讓使用者能直觀地從顏色深淺判斷權重高低。

### 6.5 前端即時操作（AJAX 模式）

KeyWords Index 頁面大量使用 AJAX 進行無刷新操作：

1. **更新類別**：`<select onchange="updateCategory(id, value, this)">` → `$.post('/KeyWords/UpdateCategory')` → Toast 通知
2. **更新權重**：`<input type="range" onchange="updateWeight(id, value)">` → `$.post('/KeyWords/UpdateWeight')` → Toast 通知
3. **刪除**：SweetAlert2 確認 → `<form>.submit()` → 傳統 POST + 重導向

---

## 七、完整資料流圖

### 7.1 Index Action 資料流

```
Browser                 Controller              Service                  Repository              EF Core / DB
  │                        │                       │                        │                       │
  │ GET /KeyWords/Index    │                       │                        │                       │
  │ ──────────────────────▶│                       │                        │                       │
  │                        │                       │                        │                       │
  │                        │ [Authorize] 通過      │                        │                       │
  │                        │ [Function] 通過       │                        │                       │
  │                        │                       │                        │                       │
  │                        │  GetAllAsync()        │                        │                       │
  │                        │──────────────────────▶│                        │                       │
  │                        │                       │  GetAllAsync()         │                       │
  │                        │                       │───────────────────────▶│  SELECT * FROM        │
  │                        │                       │                        │  KeyWords              │
  │                        │                       │                        │──────────────────────▶│
  │                        │                       │                        │◀── List<KeyWord> ────│
  │                        │                       │◀─ IEnumerable<Entity> │                       │
  │                        │                       │                        │                       │
  │                        │                       │  Entity → DTO 映射     │                       │
  │                        │◀─ IEnumerable<DTO> ──│                        │                       │
  │                        │                       │                        │                       │
  │                        │  DTO → ViewModel 映射  │                        │                       │
  │                        │  + Where(Category!=0)  │                        │                       │
  │                        │                       │                        │                       │
  │                        │  return View(vms)     │                        │                       │
  │ ◀── HTML Response ────│                       │                        │                       │
  │                        │                       │                        │                       │
```

### 7.2 Create POST Action 資料流

```
Browser                 Controller              Service                  Repository              EF Core / DB
  │                        │                       │                        │                       │
  │ POST /KeyWords/Create  │                       │                        │                       │
  │ {Word,Category,Weight} │                       │                        │                       │
  │ + AntiForgeryToken     │                       │                        │                       │
  │ ──────────────────────▶│                       │                        │                       │
  │                        │                       │                        │                       │
  │                        │ [Authorize] 通過      │                        │                       │
  │                        │ [Function(create)] 通過│                       │                       │
  │                        │ [ValidateAntiForgery]  │                        │                       │
  │                        │ ModelState.IsValid     │                        │                       │
  │                        │                       │                        │                       │
  │                        │  ViewModel → DTO      │                        │                       │
  │                        │  CreateAsync(dto)      │                        │                       │
  │                        │──────────────────────▶│                        │                       │
  │                        │                       │  DTO → Entity         │                       │
  │                        │                       │  (Word.Trim())        │                       │
  │                        │                       │  CreateAsync(entity)   │                       │
  │                        │                       │───────────────────────▶│  INSERT INTO          │
  │                        │                       │                        │  KeyWords              │
  │                        │                       │                        │──────────────────────▶│
  │                        │                       │                        │◀────── OK ──────────│
  │                        │                       │◀────── Task ─────────│                       │
  │                        │◀────── Task ─────────│                        │                       │
  │                        │                       │                        │                       │
  │                        │ RedirectToAction(Index)│                        │                       │
  │ ◀── 302 Redirect ─────│                       │                        │                       │
  │                        │                       │                        │                       │
  │ GET /KeyWords/Index    │                       │                        │                       │
  │ ──────────────────────▶│  (PRG Pattern)        │                        │                       │
  │                        │                       │                        │                       │
```

### 7.3 UpdateCategory AJAX 資料流

```
Browser (AJAX)          Controller              Service                  Repository              EF Core / DB
  │                        │                       │                        │                       │
  │ POST /KeyWords/        │                       │                        │                       │
  │ UpdateCategory         │                       │                        │                       │
  │ {id: 5, category: -1} │                       │                        │                       │
  │ ──────────────────────▶│                       │                        │                       │
  │                        │                       │                        │                       │
  │                        │ [Function(edit)] 通過  │                        │                       │
  │                        │                       │                        │                       │
  │                        │ category != 0         │                        │                       │
  │                        │ UpdateCategoryAsync()  │                        │                       │
  │                        │──────────────────────▶│                        │                       │
  │                        │                       │ UpdateCategoryAsync()   │                       │
  │                        │                       │───────────────────────▶│  UPDATE KeyWords      │
  │                        │                       │                        │  SET Category=-1      │
  │                        │                       │                        │  WHERE Id=5           │
  │                        │                       │                        │──────────────────────▶│
  │                        │                       │                        │◀────── OK ──────────│
  │                        │                       │◀────── Task ─────────│                       │
  │                        │◀────── Task ─────────│                        │                       │
  │                        │                       │                        │                       │
  │ ◀── JSON {deleted:false}│                      │                        │                       │
  │                        │                       │                        │                       │
  │ jQuery: Toast 通知     │                       │                        │                       │
  │ + 更新 Badge 色彩      │                       │                        │                       │
```

---

## 八、涉及的關鍵檔案清單

| 檔案路徑                                             | 角色                 | 說明                                                     |
| ---------------------------------------------------- | -------------------- | -------------------------------------------------------- |
| `Controllers/KeyWordsController.cs`                  | Controller           | 5 個 Action：Index、Create(GET)、Create(POST)、DeleteConfirmed、UpdateCategory、UpdateWeight |
| `Services/KeyWordService.cs`                         | Service (介面+實作)  | CRUD 商業邏輯 + Entity ↔ DTO 轉換                       |
| `Repositories/KeyWordRepository.cs`                  | Repository (介面+實作)| EF Core 資料存取（CRUD）                                 |
| `Models/EfModels/KeyWord.cs`                         | Entity               | KeyWord 資料表實體（Id, Word, Category, Weight）         |
| `Models/ViewModels/KeyWordViewModel.cs`              | ViewModel            | 前端顯示模型（含 DataAnnotations 驗證）                  |
| `Models/DTOs/KeyWordDto.cs`                          | DTO                  | Service ↔ Controller 資料傳輸物件                        |
| `Models/EfModels/MyFitnessCoachDbContext.cs`         | DbContext            | EF Core 資料庫上下文                                     |
| `Infra/FunctionAttribute.cs`                         | Authorization Filter | 自訂功能權限授權過濾器                                   |
| `Views/KeyWords/Index.cshtml`                        | View                 | 關鍵字管理列表（DataTables + AJAX + SweetAlert2）        |
| `Views/KeyWords/Create.cshtml`                       | View                 | 新增關鍵字表單                                           |
| `Program.cs`                                         | 啟動設定             | DI 註冊 (L89-90)、Middleware、路由                       |

---

## 九、程式碼優化建議

### 9.1 Controller 層手動映射可抽取為擴展方法

**問題：** `Index` Action (L27-32) 和 `Create` POST Action (L50-54) 中的 DTO ↔ ViewModel 映射是手動撰寫的匿名 Select 或物件初始化。

**原因：** 若 ViewModel 新增屬性，需要在多處同步修改映射邏輯，容易遺漏。

**建議改法：** 建立擴展方法或靜態映射方法集中管理：

```csharp
public static class KeyWordMappings
{
    public static KeyWordViewModel ToViewModel(this KeyWordDto dto) => new()
    {
        Id = dto.Id, Word = dto.Word, Category = dto.Category, Weight = dto.Weight
    };

    public static KeyWordDto ToDto(this KeyWordViewModel vm) => new()
    {
        Word = vm.Word, Category = vm.Category, Weight = vm.Weight
    };
}
```

### 9.2 `UpdateCategory` 和 `UpdateWeight` 缺少 `[ValidateAntiForgeryToken]`

**問題：** `UpdateCategory` (L71) 和 `UpdateWeight` (L85) 是 `[HttpPost]` 但未標記 `[ValidateAntiForgeryToken]`。對比 `Create POST` (L44) 和 `DeleteConfirmed` (L63) 都有此標記。

**原因：** AJAX POST 請求沒有 CSRF 防護，攻擊者可以構造惡意頁面修改已登入使用者的關鍵字設定。

**建議改法：** 在 AJAX 呼叫中加入 AntiForgeryToken：

```javascript
// 前端加入 header
$.ajaxSetup({
    headers: { 'RequestVerificationToken': $('input[name="__RequestVerificationToken"]').val() }
});
```

```csharp
// Action 加入
[HttpPost]
[ValidateAntiForgeryToken]
[Function("edit_KeyWords")]
public async Task<IActionResult> UpdateCategory(int id, int category)
```

### 9.3 `DeleteConfirmed` 缺少 `[Function]` 權限控制

**問題：** `DeleteConfirmed` Action (L62-68) 沒有標記 `[Function("delete_KeyWords")]` 或 `[Function("edit_KeyWords")]`，僅繼承 Controller 層級的 `[Function("view_KeyWords")]`。

**原因：** 只有「檢視」權限的使用者理論上不應該能執行刪除操作。但由於 Delete 按鈕在前端會顯示，且後端沒有額外權限檢查，具有 `view_KeyWords` 權限的使用者可以刪除資料。

**建議改法：**

```csharp
[HttpPost, ActionName("Delete")]
[ValidateAntiForgeryToken]
[Function("edit_KeyWords")]  // 至少需要編輯權限才能刪除
public async Task<IActionResult> DeleteConfirmed(int id)
```

### 9.4 Repository 的 `UpdateCategoryAsync` 和 `UpdateWeightAsync` 無回傳值

**問題：** `UpdateCategoryAsync` (L41-48) 和 `UpdateWeightAsync` (L51-58) 在 `FindAsync` 找不到實體時靜默返回，不會通知呼叫方操作是否成功。

**原因：** 若傳入不存在的 `id`，前端會收到 200 OK，但實際上什麼都沒發生，使用者不知道操作失敗。

**建議改法：** 回傳 `bool` 或拋出 `NotFoundException`：

```csharp
public async Task<bool> UpdateCategoryAsync(int id, int category)
{
    var entity = await _context.KeyWords.FindAsync(id);
    if (entity == null) return false;
    entity.Category = category;
    await _context.SaveChangesAsync();
    return true;
}
```

Controller 中根據回傳值決定回應：

```csharp
var success = await _service.UpdateCategoryAsync(id, category);
if (!success) return NotFound();
return Ok(new { deleted = false });
```

### 9.5 Index Action 的全表載入效能

**問題：** `GetAllAsync()` (L25) 將所有 KeyWords 一次載入記憶體，然後在 Controller 層做 `Where(d.Category != 0)` 過濾。

**原因：** 過濾邏輯在記憶體端執行（LINQ to Objects），而非在資料庫端。若 KeyWords 資料量增長，會載入不必要的 Category == 0 資料。

**建議改法：** 在 Repository 層加入帶條件查詢的方法：

```csharp
// Repository
public async Task<IEnumerable<KeyWord>> GetActiveCategoriesAsync()
{
    return await _context.KeyWords.Where(k => k.Category != 0).ToListAsync();
}
```
