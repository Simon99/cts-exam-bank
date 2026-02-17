# Issue 0005: DIS-H005 Bug 未被 CTS 測試偵測

## 基本資訊
- **題目 ID**: DIS-H005 (display/hard/Q005)
- **發現日期**: 2026-02-11
- **嚴重程度**: High（題目無效）

## 問題描述

Bug patch 套用後，CTS 測試 **PASSED**（應該 FAIL）。

- **測試方法**: `android.display.cts.DisplayTest#testGetSupportedModesOnDefaultDisplay`
- **測試結果**: PASSED (3.295s)

## Bug Patch 內容

```java
// 原始
float numPeriodsRound = Math.round(numPeriods);
if (Math.abs(numPeriods - numPeriodsRound) > THRESHOLD_FOR_REFRESH_RATES_DIVISORS) {

// Bug（兩個錯誤）
float numPeriodsRound = (float) Math.floor(numPeriods + 0.4999);  // Bug 1: floor+0.4999 ≠ round
if (Math.abs(numPeriods - numPeriodsRound) >= THRESHOLD_FOR_REFRESH_RATES_DIVISORS) {  // Bug 2: > 變 >=
```

## 問題分析

Bug 涉及兩個浮點數計算錯誤：
1. `Math.floor(x + 0.4999)` 不完全等於 `Math.round(x)`
2. `>` 改成 `>=` 改變了邊界條件

然而這個 CTS 測試只檢查 supportedModes 的基本屬性，不涉及 frame rate override 的精確計算。

## 建議修復方案

### 方案 A：找更匹配的 CTS 測試
尋找會測試 frame rate override 精確值的 CTS 測試

### 方案 B：修改 Bug 位置
將 bug 放在更容易被 CTS 驗證的程式碼路徑

## 相關檔案
- Bug Patch: `domains/display/hard/Q005_bug.patch`
- 修改檔案: `DisplayManagerService.java`

## 狀態
- [x] 標記為無法修復 (2026-02-12)

---

## 嘗試記錄

### 1st Trial (2026-02-12)

**修改方向**：將 bug 移到 `LocalDisplayAdapter.java` 的 `alternativeRefreshRates` 計算

**設計思路**：
- 原 bug 位置（`getDisplayInfoForFrameRateOverride`）不會被 `testGetSupportedModesOnDefaultDisplay` 觸發
- 改為在 `alternativeRefreshRates` 陣列複製時引入 off-by-one 錯誤

**實際 Patch**：
```java
// 分配少一個元素，導致最後一個 alternative 被丟棄
float[] alternativeRates = new float[Math.max(0, alternativeRefreshRates.size() - 1)];
```

**結果**：❌ 測試 PASSED（bug 未被偵測）

**失敗原因**：
- 測試設備只有 2 個 modes（60Hz 和 90Hz）
- 每個 mode 只有 1 個 alternative
- `size() - 1 = 0` 時，alternatives 陣列為空
- 但這不會破壞對稱性（兩邊都是空的）

**結論**：
此題目無法修復的原因：
1. 原始 bug 位置（frame rate override）不在 CTS 測試路徑上
2. 改到其他位置會與 Q004 太相似（都是破壞 alternativeRefreshRates）
3. 在只有 2 modes 的設備上，很難設計能被偵測的 off-by-one 錯誤

**決定**：標記為 Unfixable，建議刪除此題或完全重新設計
