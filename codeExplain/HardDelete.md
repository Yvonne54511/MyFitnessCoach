# 如何在 Entity Framework Core 實作硬刪除與連動刪除 (Cascade Delete)

當您想要刪除一筆資料（例如一個 `User`），且希望所有與該筆資料相關聯的記錄（例如 `UserRoles`, `Members` 等）也一併被刪除，而不是僅僅解除關聯或報錯時，您需要設定「串聯刪除 (Cascade Delete)」。

## 1. 修改 DbContext 設定 (Fluent API)

在您的 `MyFitnessCoachDbContext.cs` 中，目前的關聯設定通常如下：

```csharp
// 目前的設定：ClientSetNull (不允許刪除或需手動處理)
entity.HasOne(d => d.User).WithMany(p => p.UserRoles)
    .HasForeignKey(d => d.UserId)
    .OnDelete(DeleteBehavior.ClientSetNull) // <-- 關鍵點
    .HasConstraintName("FK_UserRoles_User");
```

### 修改方案：
將 `DeleteBehavior.ClientSetNull` 改為 `DeleteBehavior.Cascade`。

**範例：刪除 User 時一併刪除其角色關聯 (UserRoles)**

```csharp
modelBuilder.Entity<UserRole>(entity =>
{
    entity.HasOne(d => d.User).WithMany(p => p.UserRoles)
        .HasForeignKey(d => d.UserId)
        .OnDelete(DeleteBehavior.Cascade) // 修改為 Cascade
        .HasConstraintName("FK_UserRoles_User");
});
```

---

## 2. 資料庫層級同步 (SQL Server)

僅修改程式碼有時不足夠，特別是如果您直接在 SQL Server 執行刪除指令。您需要確保資料庫的外鍵約束也支援串聯刪除。

### SQL 修改指令：
如果您想手動更新資料庫中的外鍵，可以使用以下邏輯（以 `UserRoles` 為例）：

```sql
-- 1. 先刪除舊的外鍵
ALTER TABLE [UserRoles] DROP CONSTRAINT [FK_UserRoles_User];

-- 2. 建立新的具備 CASCADE 功能的外鍵
ALTER TABLE [UserRoles] 
ADD CONSTRAINT [FK_UserRoles_User] 
FOREIGN KEY ([UserId]) REFERENCES [Users]([Id]) 
ON DELETE CASCADE;
```

---

## 3. 在 Service/Repository 層執行硬刪除

當設定好上述 Cascade 關聯後，您在 C# 程式碼中只需要刪除「主表」資料：

```csharp
public void HardDeleteUser(int userId)
{
    var user = _context.Users.Find(userId);
    if (user != null)
    {
        // 只要刪除 User，EF Core 和資料庫會自動清理 UserRoles, Members 等設定了 Cascade 的子表
        _context.Users.Remove(user); 
        _context.SaveChanges();
    }
}
```

---

## 4. 注意事項

1. **危險性**：硬刪除是不可逆的。一旦執行，主表與所有關聯子表的資料都會消失。
2. **多重串聯路徑**：在複雜的資料庫設計中（如 A 關聯 B，B 關聯 C），SQL Server 可能會因為「多重串聯路徑」而限制 Cascade。此時可能需要在程式碼中手動處理部分刪除邏輯。
3. **效能**：如果要刪除的主資料關聯了成千上萬筆子資料，刪除操作可能會較慢並鎖定資料表。

## 5. 建議優先修改的關聯
根據您的專案結構，若要實作硬刪除，建議檢查並修改以下關聯：
- `User` -> `UserRoles`, `UserExternalLogins`, `Members`, `Instructors`
- `Member` -> `FoodRecords`, `UserWallet`
- `Food` -> `Nutrients`, `FoodRecords`
- `ProductCategory` -> `Products`

---

## 6. 在 SSMS 圖形介面操作 (GUI)

如果您不習慣寫 SQL 指令，也可以直接在 SQL Server Management Studio (SSMS) 的圖形介面中設定：

1. **展開子表**：在 SSMS 的物件總管 (Object Explorer) 中，找到包含外鍵的「子表」（例如 `UserRoles`）。
2. **進入設計模式**：右鍵點擊該資料表，選擇 **「設計」(Design)**。
3. **打開關聯視窗**：在設計檢視中，點擊工具列上的 **「關聯」(Relationships)** 圖示（或在資料表任意處按右鍵選擇「關聯」）。
4. **選擇外鍵**：在左側清單中，選中您要修改的外鍵約束（例如 `FK_UserRoles_User`）。
5. **設定刪除規則**：
   - 在右側屬性視窗中，展開 **「INSERT 和 UPDATE 規格」(INSERT and UPDATE Specification)**。
   - 將 **「刪除規則」(Delete Rule)** 從「無動作」(No Action) 或「設定為 Null」改為 **「串聯」(Cascade)**。
6. **儲存變更**：關閉關聯視窗，並按下 `Ctrl + S` 儲存資料表設計。若 SSMS 提示需要重建資料表，請點選「是」。

