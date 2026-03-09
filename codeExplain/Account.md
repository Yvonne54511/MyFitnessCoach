# AccountController 與身份驗證機制詳細說明

本文件旨在解釋 `AccountController` 的核心功能，包括登入、登出、密碼找回以及系統如何處理使用者的身份驗證。

---

## 1. AccountController 核心動作

`AccountController` 是系統的門戶，負責處理所有與「帳號安全」相關的請求。

### A. 登入 (Login)
*   **[GET] Login**: 
    *   檢查使用者是否已經過驗證（`User.Identity.IsAuthenticated`）。如果已登入，則自動跳轉至 `Dashboard`，避免重複登入。
    *   利用 `ViewData["ReturnUrl"]` 記錄使用者原本想去的頁面，登入後可自動導回。
*   **[POST] Login**:
    *   呼叫 `IAccountService.Login` 驗證帳號密碼。
    *   **核心機制**：登入成功後，建立 `Claims`（宣告），包含使用者的 ID、姓名與 Email。
    *   使用 `HttpContext.SignInAsync` 產生加密的 **Authentication Cookie** 並存入瀏覽器。

### B. 登出 (Logout)
*   呼叫 `HttpContext.SignOutAsync`。這會立即作廢瀏覽器中的驗證 Cookie，並將使用者導回登入頁面。

### C. 忘記密碼與重設 (Password Recovery)
*   **ForgetPassword**: 接收使用者的 Email，產生一個唯一的 `code`（確認碼），並透過 `IEmailService` 發送重設連結。
*   **ResetPassword**: 驗證連結中的 `code` 是否有效且未過期（通常為 30 分鐘）。驗證通過後，允許使用者設定新密碼。

---

## 2. 身份驗證流程 (Authentication Flow)

本系統採用 **ASP.NET Core Cookie Authentication**，流程如下：

1.  **提交表單**：使用者輸入帳號密碼。
2.  **驗證密碼**：Service 層使用 `PasswordHasher<User>` 對輸入的明文進行雜湊比對。
3.  **建立憑證 (Principal)**：
    *   `Claim`：使用者的基本資訊（例如：`NameIdentifier` = ID）。
    *   `ClaimsIdentity`：這組資訊的集合，並指定驗證方案（Cookie）。
    *   `ClaimsPrincipal`：代表當前使用者的身份實體。
4.  **發放 Cookie**：系統將加密後的 Identity 資訊寫入瀏覽器 Cookie。
5.  **後續請求**：之後每次切換頁面時，瀏覽器會自動帶上 Cookie，由 `app.UseAuthentication()` 中間件自動解碼並填充 `User` 物件。

---

## 3. 視圖 (View) 設計與前端邏輯

### A. Login.cshtml
*   **視覺設計**：採用了與後台主色調一致的溫馨風格（Nutrition/Warm theme）。
*   **密碼顯示切換**：利用原生 JavaScript 監聽「眼睛圖示」的點擊事件，切換 `<input>` 的 `type` 屬性（`password` <-> `text`），提升使用者體驗。
*   **防護機制**：表單包含 `@Html.AntiForgeryToken()`，防止跨站請求偽造（CSRF）攻擊。

### B. 驗證腳本 (_ValidationScriptsPartial)
*   登入與重設密碼頁面均引入了 jQuery Validation，在資料送往後端前，先在前端進行格式檢查（例如：Email 格式、必填檢查），減少不必要的伺服器負擔。

---

## 4. 密碼安全性 (Security)

系統不儲存明文密碼，而是使用 `Microsoft.AspNetCore.Identity.PasswordHasher`：
*   **雜湊 (Hashing)**：採用 PBKDF2 演算法。
*   **加鹽 (Salting)**：每個使用者都有隨機生成的鹽值，即使兩個人密碼相同，資料庫存儲的雜湊值也會完全不同。
*   **不可逆性**：即使資料庫外洩，攻擊者也無法直接看出原始密碼。

---
*文件產生日期：2026-03-09*
