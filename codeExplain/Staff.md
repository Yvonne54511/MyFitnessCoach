# StaffController 與 View 程式碼詳細說明

本文件旨在解釋 `StaffController` 的設計邏輯、視圖架構，以及如何利用 AJAX 與 Modal 實現不跳頁的資料處理機制。

---

## 1. StaffController 核心邏輯

`StaffController` 負責管理後台員工（User 實體）的生命週期，其設計遵循 **AJAX + JSON/PartialView** 的模式。

### 主要 Action 說明：
*   **Index()**: 初始進入頁面。它會載入所有的員工資料與角色清單（用於邀請 Modal 的角色勾選），並回傳 `Index.cshtml`。
*   **GetStaffList()**: **關鍵動作**。它只回傳 `_StaffListPartial`（局部視圖）。當資料有變動（新增/修改/刪除）後，前端 JS 會呼叫此動作來「刷新」表格，而不需要重新整理整個網頁。
*   **Invite(model)**: 接收邀請表單資料。處理成功後回傳 `Json({ success: true })`，讓前端知道可以關閉視窗並刷新列表。
*   **Edit(id) [GET]**: **Modal 抓取資料的核心**。根據 ID 取得員工資料，並填入 `StaffEditViewModel`，最後回傳 `_EditStaffPartial`。
*   **Delete(id)**: 接收刪除請求並操作資料庫，同樣回傳 Json 結果。

---

## 2. 視圖 (View) 結構

視圖被拆分為三個層級，以提高重用性與維護性：

1.  **Index.cshtml (主容器)**：
    *   定義了「邀請」與「編輯」兩個 Modal 的 HTML 外框。
    *   包含了核心的 JavaScript 邏輯。
    *   定義了一個 `#staffListContainer` 區塊，用來承載動態載入的表格。

2.  **_StaffListPartial.cshtml (資料列表)**：
    *   純粹的 `<table>` 內容。
    *   這部分被獨立出來，是因為它會被頻繁地透過 AJAX 重新載入，以達成「自動更新列表」的效果。

3.  **_EditStaffPartial.cshtml (編輯表單)**：
    *   這是 Modal 「內層」的表單。
    *   當管理員點擊編輯時，這段 HTML（帶有該員工的舊資料）會被動態載入到主頁面的 Modal 中。

---

## 3. Modal 抓取與載入資料的方法 (重點)

系統使用了兩套不同的 Modal 處理策略：

### A. 靜態 Modal (邀請功能)
*   **方法**：表單內容預先寫在 `Index.cshtml` 中。
*   **流程**：點擊「邀請」按鈕後，Modal 直接顯示（Data-toggle），送出時透過 `$('#inviteForm').serialize()` 將內容打包給後端。

### B. 動態 Modal (編輯功能)
這是您最感興趣的部分，它解決了「如何讓 Modal 知道我要編輯哪一筆資料」的問題。

**核心流程如下：**

1.  **觸發事件**：
    在 `_StaffListPartial` 的每一列中，編輯按鈕帶有一個 `data-id="@item.Id"` 屬性。
    ```html
    <button class="btn-edit" data-id="15">編輯</button>
    ```

2.  **前端 AJAX 抓取**：
    當點擊按鈕時，JavaScript 會攔截事件，並取得該 ID，隨後發送 `$.get` 請求到 `Staff/Edit/15`。
    ```javascript
    $(document).on('click', '.btn-edit', function () {
        var id = $(this).data('id'); // 取得 15
        $.get('/Staff/Edit/' + id, function (html) {
            $('#editModalContent').html(html); // 將後端傳回的 HTML 塞入 Modal
            $('#editModal').modal('show');     // 顯示 Modal
        });
    });
    ```

3.  **後端 PartialView 回傳**：
    `StaffController` 的 `Edit(int id)` 動作會去資料庫抓資料，並回傳 `PartialView("_EditStaffPartial", model)`。這時回傳的是一段**已經填好資料的 HTML 表單**。

4.  **注入與顯示**：
    前端收到 HTML 後，利用 `.html(html)` 把表單塞進 Modal 的 `<div>` 中，管理員看到的 Modal 裡就已經有該員工的姓名和 Email 了。

---

## 4. 自動更新資料的機制

當您在 Modal 點擊「儲存」或「送出邀請」後：
1.  AJAX 送出資料給 Controller。
2.  Controller 回傳 `Json({ success: true })`。
3.  前端 JavaScript 執行 `refreshList()` 函式。
    ```javascript
    function refreshList() {
        $.get('/Staff/GetStaffList', function (html) {
            $('#staffListContainer').html(html); // 重新載入表格區塊
        });
    }
    ```
4.  列表更新完成，使用者完全不需要手動重新整理瀏覽器。

---
*文件產生日期：2026-03-09*
