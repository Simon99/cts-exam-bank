# CTS 面試題：Display Mode 切換失敗分析

**題目編號**: DIS-H003  
**難度**: Hard  
**預估時間**: 35 分鐘

---

## 背景

Android Display 子系統負責管理螢幕的顯示模式（Display Mode），包括解析度和刷新率。`LogicalDisplay` 類別代表一個邏輯顯示器，透過 `DesiredDisplayModeSpecs` 來指定系統期望的顯示模式規格。

當應用程式或系統需要切換顯示模式（例如從 60Hz 切換到 90Hz 或 120Hz）時，會呼叫 `setDesiredDisplayModeSpecsLocked()` 方法來設定新的模式規格。

## CTS 測試失敗

執行以下 CTS 測試時發生失敗：

```
atest CtsDisplayTestCases:DisplayTest#testModeSwitchOnPrimaryDisplay
```

**失敗訊息**:
```
android.display.cts.DisplayTest#testModeSwitchOnPrimaryDisplay
FAIL: Display mode switch did not complete within timeout
Expected refresh rate range to be updated but observed stale values
junit.framework.AssertionFailedError: Mode switch request was not applied
  Primary refresh rate range remained unchanged after setDesiredDisplayModeSpecs
  Expected: min=90.0, max=120.0
  Actual: min=60.0, max=60.0
```

## 問題描述

開發團隊在進行效能優化時，修改了 `LogicalDisplay.java` 中的 `setDesiredDisplayModeSpecsLocked()` 方法。原始程式碼如下：

```java
public void setDesiredDisplayModeSpecsLocked(
        DisplayModeDirector.DesiredDisplayModeSpecs specs) {
    mDesiredDisplayModeSpecs = specs;
}
```

修改後的版本加入了「優化邏輯」，試圖避免重複的模式更新。

## 任務

1. **分析問題**：檢視修改後的程式碼，找出導致 CTS 測試失敗的 bug
2. **解釋原因**：說明為什麼這個修改會導致模式切換失敗
3. **提出修復**：提供正確的修復方案

## 提示

- `DesiredDisplayModeSpecs` 包含多個欄位：`baseModeId`、`allowGroupSwitching`、`primary`（RefreshRateRanges）、`appRequest`（RefreshRateRanges）
- 刷新率範圍（RefreshRateRanges）包含 physical 和 render 兩種範圍
- 即使 `baseModeId` 相同，刷新率範圍也可能不同
- 狀態標誌的管理可能導致競態條件

## 評分標準

| 項目 | 分數 |
|------|------|
| 正確識別 bug 類型（STATE/COND） | 20% |
| 解釋錯誤的比較邏輯 | 25% |
| 解釋狀態標誌的問題 | 25% |
| 提供完整的修復方案 | 20% |
| 解釋為何 CTS 測試能檢測到此問題 | 10% |

---

## 修改後的程式碼

```java
public void setDesiredDisplayModeSpecsLocked(
        DisplayModeDirector.DesiredDisplayModeSpecs specs) {
    // Optimization: skip update if base mode hasn't changed and we're in transition
    if (specs != null && mDesiredDisplayModeSpecs != null) {
        // Check if the base mode is the same - if so, assume specs are equivalent
        if (specs.baseModeId == mDesiredDisplayModeSpecs.baseModeId) {
            if (mPendingModeTransition) {
                // Already transitioning with same base mode, skip redundant update
                return;
            }
            // Mark that we're now in a pending transition
            mPendingModeTransition = true;
        } else {
            mPendingModeTransition = false;
        }
    }
    mDesiredDisplayModeSpecs = specs;
}
```

**新增的成員變數**：
```java
// Track if we're in a mode transition to avoid redundant updates
private boolean mPendingModeTransition = false;
```

---

*請在答題紙上完成您的分析與解答*
