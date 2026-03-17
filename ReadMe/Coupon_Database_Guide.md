# 優惠券資料庫設計與開發注意事項

這份文件旨在指導如何在 MyFitnessCoach 專案中實作健全的優惠券系統。

## 1. 資料表架構建議 (Schema)

### A. Coupons (優惠券定義表)
*   **代碼生成 (CouponCode)**: 應使用隨機且不具規律性的英數組合（例如 `FIT2024-X8R2`），避免使用者猜測代碼「刷券」。
*   **數量限制 (TotalQuantity)**: 設定總發放數量，並配合 `IssuedQuantity` 欄位追蹤，避免發放超額。
*   **金額門檻 (MinSpend)**: 務必設定「滿額才可使用」的欄位，防止小額訂單被全額抵扣。
*   **折扣上限 (MaxDiscount)**: 若為百分比折扣（例如 8 折），建議設定最高抵扣金額，以降低行銷成本風險。

### B. MemberCoupons (領取紀錄與狀態表)
*   **狀態管理 (IsUsed)**: 使用 Boolean 或 TinyInt 記錄狀態（未使用、已使用、已過期）。
*   **關聯追蹤 (OrderId)**: 必須記錄該優惠券最終用於哪一筆訂單，方便日後退貨審核。

---

## 2. 關鍵開發注意事項 (Critical Points)

### A. 並發處理 (Race Condition)
在多人同時領取或使用同一張限量優惠券時，必須防止「超賣」：
*   **SQL 層級**: 使用 `UPDATE Coupons SET IssuedQuantity = IssuedQuantity + 1 WHERE Id = 1 AND IssuedQuantity < TotalQuantity`。
*   **交易鎖定**: 領券與扣券動作必須包裹在 `DB Transaction` 中。

### B. 過期邏輯判斷
*   不要僅依賴 `IsActive` 欄位，在查詢時必須檢查 `GETDATE() BETWEEN StartDate AND EndDate`。
*   **時區問題**: 建議統一使用伺服器時間，並在 UI 上明確標示 `23:59:59` 為截止點。

### C. 金額計算順序
*   **計算順序**: 商品小計 -> **優惠券折扣** -> 運費計算 -> 最終支付金額。
*   **捨入誤差**: 對於百分比折扣（如 9 折），建議使用 `Math.Floor` 或 `Math.Round(amount, 0)` 處理小數點後的金額。

### D. 退貨處理 (Business Logic)
*   **是否退回優惠券？**: 若訂單退貨，該優惠券是否還給會員？通常邏輯是「已使用的優惠券不予退還」，需在系統說明中載明。

---

## 3. 安全性防範

1.  **防刷機制**: 針對「全站通用代碼」，應限制每個會員（MemberId）只能領取/使用一次。
2.  **資料完整性**: 在 `ProductOrders` 表中，除了儲存 `CouponId`，也應將當時扣抵的金額 `DiscountAmount` 固定下來，避免優惠券定義修改後導致歷史訂單金額對不起來。
3.  **防暴力猜測**: 針對手動輸入代碼的 API，應加入頻率限制 (Rate Limiting)，防止機器人嘗試所有代碼組合。

---

## 4. 推薦欄位擴充
*   `UsageDescription`: 在結帳頁面顯示的優惠說明。
*   `Scope`: 限制特定類別商品（如：僅限「教練課」使用）。
