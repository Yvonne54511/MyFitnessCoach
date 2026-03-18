# ProductOrder 功能與資料結構解析報告

本報告針對 `MyFitnessCoach` 專案中的商品訂單（ProductOrder）模組進行深入解析，涵蓋其功能邏輯、資料庫結構及資料流轉。

## 1. 功能概述 (Functionality Overview)

`ProductOrder` 模組負責管理系統中所有商品的訂購流程，主要功能包括：

- **訂單管理看板 (Dashboard)**：
    - 統計本月總訂單量與增長率。
    - 追蹤待出貨與待處理（退貨/爭議）訂單。
    - 視覺化圖表：14天訂單趨勢、訂單縣市分布、熱銷商品類別排行。
    - 即時列出今日訂單與待處理清單（包含退貨與爭議）。
- **訂單列表與篩選 (Order Management)**：
    - 提供所有訂單的概覽。
    - 支援依「訂單狀態」篩選及「會員/收件人姓名」關鍵字查詢。
- **訂單詳情 (Order Details)**：
    - 顯示詳細的收件人資訊、商品明細（名稱、價格、數量、小計）。
    - 包含折扣與總額計算邏輯。
- **狀態管理與審核 (Status Lifecycle)**：
    - 系統支援完整的訂單生命週期：待處理 -> 已出貨 -> 已送達 -> (申請退貨 -> 退貨申請中/爭議) 或 已取消。
    - 管理員可手動變更訂單狀態或執行退貨審核。

---

## 2. 資料結構解析 (Data Structure Analysis)

### A. 資料庫模型 (EF Models)

#### **ProductOrder (主表)**
儲存訂單的主體資訊與金額統計。
- `Id` (int): 主鍵，自動增量。
- `MemberId` (int): 關聯會員。
- `CreateAt` (DateTime): 下單時間。
- `OriginalAmount` (decimal): 原始總金額。
- `DiscountAmount` (decimal): 折扣金額。
- `Receiver` (string): 收件人姓名。
- `Address` (string): 配送地址（亦用於縣市分布統計）。
- `Mobile` (string): 聯絡電話。
- `Status` (int): 狀態碼（0-6，詳見下方解析）。
- `Memo` (string): 備註（通常用於退貨原因）。

#### **ProductOrderDetail (明細表)**
記錄訂單中具體的商品項目。
- `Id` (int): 主鍵。
- `ProductOrderId` (int): 關聯訂單主表。
- `ProductId` (int): 關聯產品。
- `ProductName` (string): 產品名稱（快照，防止產品改名影響歷史紀錄）。
- `UnitPrice` (decimal): 成交單價。
- `Qty` (int): 購買數量。
- `SubTotal` (decimal): 該品項小計。
- `DiscountedPrice` (decimal): 折扣後的價格。

---

### B. 狀態定義 (Magic Numbers)
系統採用統一的狀態碼管理訂單流程：
- `0`: 待處理
- `1`: 已出貨
- `2`: 已送達
- `3`: 已取消
- `4`: 退貨申請
- `5`: 退貨申請中
- `6`: 爭議

---

### C. 傳輸對象 (DTOs / ViewModels)

- **ProductOrderDto**: 用於 Service 層與 Repository 層之間的資料傳遞，封裝了訂單及其明細。
- **ProductOrderDashboardViewModel**: 專門為看板設計，包含各種統計數值與 `Chart.js` 所需的資料數組。
- **ProductOrderViewModel**: 負責視圖呈現，並包含 `StatusName` 轉換邏輯與總金額計算邏輯。

---

## 3. 架構設計 (Architectural Design)

專案遵循典型的 **Repository -> Service -> Controller** 三層式架構：

1.  **Repository 層 (`ProductOrderRepository`)**：
    - 使用 LINQ 執行資料庫操作。
    - 負責複雜的統計運算（如 `GroupBy` 縣市、分組統計熱銷排行）。
    - 執行 `Include` 預加載（Eager Loading）以解決 N+1 查詢問題。
2.  **Service 層 (`ProductOrderService`)**：
    - 封裝業務規則。目前主要作為轉接層，未來可擴充自動化邏輯（如：更改狀態時觸發 Email 通知）。
3.  **Controller 層 (`ProductOrdersController`)**：
    - 接收前端請求。
    - 將 DTO 轉換為適合 View 的 ViewModel。
    - 控制視圖轉向與錯誤處理。

---

## 4. 關鍵運算邏輯

- **金額計算**：`TotalAmount = OriginalAmount - DiscountAmount`。
- **百分比變動率**：`((本月 - 上月) / 上月) * 100`，處理了分母為零的例外情況。
- **待處理訂單定義**：在 SQL 層面篩選 `Status` 為 1, 4, 5, 6 的資料，並依時間排序。
