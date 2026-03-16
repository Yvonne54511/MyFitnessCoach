# 請假系統資料庫設計文件

**專案**：MyFitnessCoach
**資料庫**：MyFitnessCoachDb (SQL Server 2025)
**設計日期**：2026-03-16
**版本**：v3

---

## 一、背景與設計原則

### 既有資料表（不修改）

| 表名 | 用途 |
| :--- | :--- |
| `Users` | 帳號、密碼、Email，所有角色共用 |
| `Roles` / `UserRoles` | 角色授權 |
| `Instructors` | 教練專屬資料（時薪、照片、簡介） |
| `Members` | 會員專屬資料（身體數據、飲食記錄） |

### 設計原則

1. **不動既有表**：透過 1-to-1 擴充表 (`Employees`) 橋接 `Users`，保持既有功能不受影響。
2. **教練也是員工**：`Instructors` 有 `UserId`，`Employees` 也有 `UserId`，兩者可同時存在，互不干擾。
3. **軟刪除**：`LeaveTypes.IsActive`、`Employees.IsActive` 採軟刪除，保留歷史申請單完整性。
4. **單層審核優先**：先實作直屬主管單層審核，預留 `LeaveApprovalLogs` 擴充點。

---

## 二、新增資料表總覽（共 6 張）

| # | 表名 | 中文說明 | 相依關係 |
| :--: | :--- | :--- | :--- |
| 1 | `Departments` | 部門表 | ← `Employees.ManagerId` |
| 2 | `Employees` | 員工擴充表 | → `Users`, `Departments`, 自我關聯 |
| 3 | `LeaveTypes` | 假別定義表 | 無外鍵依賴 |
| 4 | `LeaveRequests` | 請假申請單 | → `Employees`, `LeaveTypes` |
| 5 | `LeaveAttachments` | 請假附件表 | → `LeaveRequests` |
| 6 | `LeaveBalances` | 員工假期餘額表 | → `Employees`, `LeaveTypes` |

---

## 三、資料表詳細設計

### 1. Departments（部門表）

管理公司部門結構，記錄部門主管。

| 欄位名稱 | 資料類型 | 必填 | 說明 |
| :--- | :--- | :---: | :--- |
| `Id` | int IDENTITY(1,1) | ✓ | PK |
| `Name` | nvarchar(50) | ✓ | 部門名稱，例如：教練部、行政部、客服部 |
| `ManagerId` | int | — | FK → `Employees(Id)`，部門主管；建表後以 ALTER TABLE 補加，避免循環相依 |

> **循環相依處理**：建表順序為 `Departments`（ManagerId 暫為 NULL）→ `Employees` → `ALTER TABLE Departments ADD CONSTRAINT FK_Dept_Manager`。

---

### 2. Employees（員工擴充表）

以 1-to-1 方式擴充 `Users`，補充請假系統所需的 HR 屬性。

| 欄位名稱 | 資料類型 | 必填 | 說明 |
| :--- | :--- | :---: | :--- |
| `Id` | int IDENTITY(1,1) | ✓ | PK |
| `UserId` | int | ✓ | FK → `Users(Id)`，UNIQUE，一個 User 只能有一筆 |
| `DepartmentId` | int | ✓ | FK → `Departments(Id)` |
| `ManagerId` | int | — | FK → `Employees(Id)`，直屬主管（自我關聯） |
| `WorkDelegateId` | int | — | FK → `Employees(Id)`，主管出勤時的長期職務代理人 |
| `HiredDate` | date | ✓ | 到職日，用於計算特休年資 |
| `IsActive` | bit | ✓ | 是否在職，預設 1 |

**索引建議**：`IX_Employees_UserId`（雖已有 UNIQUE，加索引加速 JOIN）

---

### 3. LeaveTypes（假別定義表）

集中管理假別規則，方便後台維護。

| 欄位名稱 | 資料類型 | 必填 | 說明 |
| :--- | :--- | :---: | :--- |
| `Id` | int IDENTITY(1,1) | ✓ | PK |
| `Name` | nvarchar(30) | ✓ | 假別名稱 |
| `DaysPerYear` | int | ✓ | 每年配額天數；公假等無上限者填 0 |
| `CarryOver` | bit | ✓ | 是否可跨年遞延，預設 0 |
| `RequiresDoc` | bit | ✓ | 是否須上傳證明文件，預設 0 |
| `IsActive` | bit | ✓ | 是否啟用，預設 1（軟刪除） |

**預設種子資料（依勞基法）**：

| 假別 | 每年天數 | 可遞延 | 需文件 |
| :--- | :---: | :---: | :---: |
| 特休 | 15 | ✓ | — |
| 病假 | 30 | — | ✓ |
| 事假 | 14 | — | — |
| 婚假 | 8 | — | ✓ |
| 喪假 | 8 | — | ✓ |
| 公假 | 0 | — | ✓ |

> **注意**：特休天數依年資遞增（勞基法第 38 條），`DaysPerYear` 為預設值，實際配額寫入 `LeaveBalances`。

---

### 4. LeaveRequests（請假申請單）

記錄每筆申請的完整生命週期。

| 欄位名稱 | 資料類型 | 必填 | 說明 |
| :--- | :--- | :---: | :--- |
| `Id` | int IDENTITY(1,1) | ✓ | PK |
| `EmployeeId` | int | ✓ | FK → `Employees(Id)`，申請人 |
| `LeaveTypeId` | int | ✓ | FK → `LeaveTypes(Id)`，假別 |
| `StartDate` | datetime | ✓ | 請假開始時間（含時分，支援半天） |
| `EndDate` | datetime | ✓ | 請假結束時間 |
| `DaysUsed` | decimal(4,1) | ✓ | 本次扣除天數（0.5 = 半天） |
| `Reason` | nvarchar(500) | — | 請假事由 |
| `Status` | nvarchar(20) | ✓ | 狀態（見下方 CHECK 約束），預設 `'Pending'` |
| `LeaveDelegateId` | int | — | FK → `Employees(Id)`，本次請假的臨時職務代理人 |
| `ApprovedBy` | int | — | FK → `Employees(Id)`，審核人 |
| `ApprovedAt` | datetime2(0) | — | 審核完成時間 |
| `RejectReason` | nvarchar(300) | — | 拒絕原因 |
| `CreatedAt` | datetime2(0) | ✓ | 提交時間，預設 `GETDATE()` |

**Status 允許值（CHECK 約束）**：

| 值 | 說明 | 觸發條件 |
| :--- | :--- | :--- |
| `Pending` | 待審核 | 初始建立 |
| `Approved` | 已核准 | 主管核准 |
| `Rejected` | 已拒絕 | 主管拒絕 |
| `Cancelled` | 已撤回 | 申請人主動取消（僅限 Pending 狀態可撤回） |

**索引**：`IX_LeaveRequests_EmployeeId`、`IX_LeaveRequests_Status`

---

### 5. LeaveAttachments（請假附件表）

一張申請單可附多個檔案（一對多），適用病假診斷書、公假公文等。

| 欄位名稱 | 資料類型 | 必填 | 說明 |
| :--- | :--- | :---: | :--- |
| `Id` | int IDENTITY(1,1) | ✓ | PK |
| `RequestId` | int | ✓ | FK → `LeaveRequests(Id)` |
| `FileName` | nvarchar(200) | ✓ | 原始檔案名稱（顯示用） |
| `FileUrl` | nvarchar(500) | ✓ | 實際儲存路徑或雲端 URL |
| `UploadedAt` | datetime2(0) | ✓ | 上傳時間，預設 `GETDATE()` |

---

### 6. LeaveBalances（員工假期餘額表）

記錄每位員工每年度各假別的配額與使用狀況。

| 欄位名稱 | 資料類型 | 必填 | 說明 |
| :--- | :--- | :---: | :--- |
| `Id` | int IDENTITY(1,1) | ✓ | PK |
| `EmployeeId` | int | ✓ | FK → `Employees(Id)` |
| `LeaveTypeId` | int | ✓ | FK → `LeaveTypes(Id)` |
| `Year` | int | ✓ | 年度（例如 2026） |
| `TotalDays` | decimal(4,1) | ✓ | 年度配額總天數 |
| `UsedDays` | decimal(4,1) | ✓ | 已使用天數，預設 0 |
| `RemainingDays` | decimal(4,1) PERSISTED | — | **計算欄位**：`TotalDays - UsedDays`，由資料庫維護 |

**唯一鍵**：`UQ_LeaveBalances_Key (EmployeeId, LeaveTypeId, Year)` — 同員工同年同假別只有一筆。

---

## 四、ER 關係圖

```
Users (既有)
  │ 1:1
  ▼
Employees ◄──────────────── Employees (ManagerId / WorkDelegateId，自我關聯)
  │ N              │ N
  │                │
  ▼ 1              ▼ 1
Departments    LeaveRequests ─────► LeaveTypes
(ManagerId          │ N
 回指 Employees)    │
              ┌─────┴──────┐
              ▼            ▼
    LeaveAttachments   LeaveBalances ◄── LeaveTypes
```

---

## 五、設計考量與 Gemini Review 建議討論點

### 1. Employees vs. Instructors 的關係
目前 `Instructors` 表有 `UserId`，`Employees` 表也有 `UserId`。
- 教練需要請假時，需同時在 `Instructors` 和 `Employees` 中各有一筆。
- **待討論**：是否應在 `Employees` 中加入 `InstructorId` 作為橋接，或允許兩張表獨立共存？

### 2. 單層 vs. 多層審核
目前 `LeaveRequests` 只有一個 `ApprovedBy`，支援**單層審核**。
若日後需要「主管 → 店長」兩層審核，需新增：
```sql
LeaveApprovalLogs (
    Id          INT IDENTITY,
    RequestId   INT NOT NULL,  -- FK → LeaveRequests
    ApproverId  INT NOT NULL,  -- FK → Employees
    Level       INT NOT NULL,  -- 1 = 直屬主管, 2 = 店長
    Action      NVARCHAR(20),  -- 'Approved' | 'Rejected'
    Comment     NVARCHAR(300),
    ActionAt    DATETIME2(0)
)
```

### 3. 職務代理人區分
| 欄位 | 層級 | 用途 |
| :--- | :--- | :--- |
| `Employees.WorkDelegateId` | 員工資料層 | 主管「長期」指定的代理人 |
| `LeaveRequests.LeaveDelegateId` | 申請單層 | 本次請假「臨時」指定的代理人 |

兩者目的不同，請勿混用。

### 4. RemainingDays 計算欄位
`LeaveBalances.RemainingDays` 為 `PERSISTED` 計算欄位，後端**只需更新 `UsedDays`**，資料庫自動維護餘額，不需手動計算。

### 5. 特休年資計算
`Employees.HiredDate` 是計算特休天數的依據（勞基法第 38 條）：

| 年資 | 特休天數 |
| :---: | :---: |
| 滿 6 個月 | 3 天 |
| 滿 1 年 | 7 天 |
| 滿 2 年 | 10 天 |
| 滿 3 年 | 14 天 |
| 滿 5 年 | 15 天 |
| 滿 10 年起 | 每年 +1 天，上限 30 天 |

建議實作一支 Stored Procedure 或後端 Service，在年度更新時批次寫入 `LeaveBalances`。

### 6. 與排班系統整合
請假核准（`Status = 'Approved'`）後，是否需要異動排班表 (`Shifts`) 對應時段？
**建議**：以事件（Application Event）方式觸發，避免在請假 Transaction 中直接操作排班表造成耦合。

### 7. 並發控制
員工同時提交多筆請假可能導致 `UsedDays` 超額。
**建議**：在服務層加入 `WITH (UPDLOCK)` 或樂觀鎖（`RowVersion`）確保餘額扣減的原子性。

---

## 六、建表腳本

對應建表腳本：`SqlCodes/Setup_LeaveRequestSystem_v3.sql`

執行順序：
1. 刪除舊表（若存在）
2. 建立 `Departments`（`ManagerId` 暫 NULL）
3. 建立 `Employees`
4. `ALTER TABLE Departments` 補加 FK
5. 建立 `LeaveRequests`
6. 建立 `LeaveAttachments`
7. 建立 `LeaveTypes` + 種子資料
8. 建立 `LeaveBalances`
9. `ALTER TABLE LeaveRequests` 補加 LeaveTypeId FK
