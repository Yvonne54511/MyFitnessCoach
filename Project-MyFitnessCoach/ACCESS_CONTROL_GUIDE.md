# 預約系統存取控制與導向邏輯修改說明

為了實現「沒登入進不去預約頁面」、「登入成功導向預約頁面」以及「登入失敗返回首頁」的需求，我們進行了以下修改：

## 1. 設定存取權限控管 (Authorization)
在 `Controllers/ReservationController.cs` 中，我們加入了 `[Authorize]` 屬性。

*   **作用**：此屬性會強制要求所有進入 `ReservationController` 的請求必須經過驗證（登入）。
*   **行為**：若使用者未登入嘗試進入預約頁面，系統會自動將其導向至 `Program.cs` 中設定的 `LoginPath` (即 `/Login/Index`)。

```csharp
[Authorize]
public class ReservationController : Controller
{
    // ...
}
```

## 2. 修正驗證中介軟體順序
在 `Program.cs` 中，我們調整了 `app.UseAuthentication()` 與 `app.UseAuthorization()` 的執行順序。

*   **關鍵點**：在 ASP.NET Core 中，必須先執行 **驗證 (Authentication)** 識別使用者是誰，才能執行 **授權 (Authorization)** 判斷使用者是否有權限存取。
*   **修正前**：`UseAuthorization` 在前，會導致權限檢查失效或出現邏輯錯誤。
*   **修正後**：
    ```csharp
    app.UseRouting();
    app.UseAuthentication(); // 必須在前
    app.UseAuthorization();  // 必須在後
    ```

## 3. 實作登入後的導向邏輯
在 `Controllers/LoginController.cs` 的 `Index` POST 方法中，我們確認並實作了導向邏輯：

*   **登入成功**：使用 `RedirectToAction("ReservationForm", "Reservation")` 直接進入預約介面。
*   **登入失敗**：使用 `RedirectToAction("Index", "Home")` 返回首頁，並透過 `TempData` 傳遞錯誤訊息。

```csharp
if (result.IsSuccess == false)
{
    TempData["ErrorMessage"] = result.ErrorMessage;
    return RedirectToAction("Index", "Home"); // 失敗則返回 homepage
}

// ... 登入處理 ...

return RedirectToAction("ReservationForm", "Reservation"); // 登入後直接導進預約介面
```

## 4. 驗證配置 (Program.cs)
確保 Cookie 驗證已正確配置登入路徑：
```csharp
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.Cookie.Name = "ReservationDemo";
        options.LoginPath = "/Login/Index"; // 未登入時導向此處
    });
```

以上修改確保了系統的安全性，並符合您提出的導向流程。
