# DIS-H003 參考答案

## Bug 類型

**STATE（狀態管理錯誤）+ COND（條件判斷錯誤）**

這是一個複合型 bug，結合了：
1. 錯誤的狀態標誌管理（mPendingModeTransition）
2. 不完整的條件判斷邏輯（僅比較 baseModeId）

---

## 問題分析

### 問題 1：不完整的相等性比較

```java
if (specs.baseModeId == mDesiredDisplayModeSpecs.baseModeId) {
```

**錯誤**：僅比較 `baseModeId` 來判斷 specs 是否「等效」是不正確的。

`DesiredDisplayModeSpecs` 包含多個重要欄位：
- `baseModeId` - 基礎模式 ID
- `allowGroupSwitching` - 是否允許跨組切換
- `primary` - 主要刷新率範圍（RefreshRateRanges）
- `appRequest` - 應用請求刷新率範圍

**即使 baseModeId 相同，其他欄位可能不同**：
- 相同解析度下可能支援多種刷新率（60Hz、90Hz、120Hz）
- 刷新率範圍可以獨立於 baseModeId 變化
- 應用可能請求不同的 appRequest 範圍

### 問題 2：狀態標誌永不重置

```java
mPendingModeTransition = true;
// ... 但在何處設為 false？
```

一旦 `mPendingModeTransition` 被設為 `true`，它只會在 `baseModeId` 變化時才會重置為 `false`。這意味著：

1. 第一次設定 specs（baseModeId = X）→ `mPendingModeTransition = true`
2. 第二次設定 specs（baseModeId = X，但刷新率範圍不同）→ 直接 return，**specs 未更新**

### 問題 3：錯誤的優化假設

程式碼假設「相同 baseModeId = 無需更新」，但實際上：
- 模式切換可能只改變刷新率範圍，不改變 baseModeId
- 例如：維持 1080p 解析度，但從 60Hz 範圍擴展到 60-120Hz 範圍

---

## CTS 測試失敗原因

`testModeSwitchOnPrimaryDisplay` 測試流程：

1. 查詢當前顯示模式規格
2. 請求切換到不同的刷新率範圍（相同 baseModeId）
3. 驗證刷新率範圍是否正確更新

**失敗原因**：
- 測試請求切換刷新率範圍（min=90, max=120）
- 由於 baseModeId 相同且 `mPendingModeTransition = true`
- 新的 specs 被跳過，`mDesiredDisplayModeSpecs` 保持舊值
- 導致刷新率範圍仍然是舊的（min=60, max=60）

---

## 修復方案

### 方案 1：完全移除錯誤的優化（推薦）

恢復原始的簡潔實作：

```java
public void setDesiredDisplayModeSpecsLocked(
        DisplayModeDirector.DesiredDisplayModeSpecs specs) {
    mDesiredDisplayModeSpecs = specs;
}
```

同時移除 `mPendingModeTransition` 成員變數。

**理由**：
- 原始設計沒有問題，setter 應該無條件設定值
- 如果需要優化，應該在呼叫端處理，而非 setter 內部
- 保持單一職責原則（SRP）

### 方案 2：正確的相等性檢查（如果真的需要優化）

```java
public void setDesiredDisplayModeSpecsLocked(
        DisplayModeDirector.DesiredDisplayModeSpecs specs) {
    // Use proper equality check including all fields
    if (Objects.equals(specs, mDesiredDisplayModeSpecs)) {
        return;
    }
    mDesiredDisplayModeSpecs = specs;
}
```

**注意**：這依賴於 `DesiredDisplayModeSpecs.equals()` 正確實作。

---

## 關鍵學習要點

1. **完整的相等性比較**：比較物件時應使用 `equals()` 或比較所有相關欄位，而非只比較部分欄位

2. **狀態標誌管理**：任何狀態標誌都必須有明確的生命週期
   - 何時設為 true？
   - 何時設為 false？
   - 是否有遺漏的重置路徑？

3. **優化的副作用**：「優化」可能改變語義
   - 原始：無條件設定
   - 修改後：有條件設定（可能跳過）
   - 這改變了 API 的契約

4. **Setter 設計原則**：
   - Setter 應該簡單直接
   - 避免在 setter 中加入複雜邏輯
   - 如需條件更新，考慮使用不同的方法名稱（如 `updateIfChanged()`）

---

## 差異比較

**有 Bug 的版本**：
```diff
+ private boolean mPendingModeTransition = false;
  
  public void setDesiredDisplayModeSpecsLocked(
          DisplayModeDirector.DesiredDisplayModeSpecs specs) {
+     if (specs != null && mDesiredDisplayModeSpecs != null) {
+         if (specs.baseModeId == mDesiredDisplayModeSpecs.baseModeId) {
+             if (mPendingModeTransition) {
+                 return;  // BUG: 跳過了必要的更新！
+             }
+             mPendingModeTransition = true;
+         } else {
+             mPendingModeTransition = false;
+         }
+     }
      mDesiredDisplayModeSpecs = specs;
  }
```

**修復後的版本**：
```java
public void setDesiredDisplayModeSpecsLocked(
        DisplayModeDirector.DesiredDisplayModeSpecs specs) {
    mDesiredDisplayModeSpecs = specs;
}
```
