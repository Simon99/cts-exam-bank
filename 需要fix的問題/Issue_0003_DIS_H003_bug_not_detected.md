# Issue 0003: DIS-H003 Bug 未被 CTS 測試偵測

## 基本資訊
- **題目 ID**: DIS-H003 (display/hard/Q003)
- **發現日期**: 2026-02-11
- **嚴重程度**: High（題目無效）

## 問題描述

Bug patch 套用後，CTS 測試 **PASSED**（應該 FAIL）。

- **測試方法**: `android.display.cts.DisplayTest#testModeSwitchOnPrimaryDisplay`
- **測試結果**: PASSED (9.881s)

## Bug Patch 內容

```java
public void setDesiredDisplayModeSpecsLocked(DesiredDisplayModeSpecs specs) {
    // Bug: 只檢查 baseModeId，忽略其他欄位
    if (specs != null && mDesiredDisplayModeSpecs != null) {
        if (specs.baseModeId == mDesiredDisplayModeSpecs.baseModeId) {
            if (mPendingModeTransition) {
                return;  // 錯誤跳過更新
            }
            mPendingModeTransition = true;
        } else {
            mPendingModeTransition = false;
        }
    }
    mDesiredDisplayModeSpecs = specs;
}
```

## 問題分析

Bug 設計假設：
- 當 baseModeId 相同但其他欄位（如 refresh rate ranges）不同時，會錯誤跳過更新

CTS 測試實際行為：
- `testModeSwitchOnPrimaryDisplay` 可能只測試 mode 切換，不涉及同 baseModeId 下的其他屬性變更
- 或者 CTS 測試的驗證邏輯無法觸發這個 bug 路徑

## 建議修復方案

### 方案 A：找更匹配的 CTS 測試
尋找會測試 refresh rate range 變更的 CTS 測試

### 方案 B：修改 Bug 設計
讓 bug 更容易被現有 CTS 測試觸發

### 方案 C：重新設計題目
基於 CTS 測試的實際驗證邏輯設計新的 bug

## 相關檔案
- Bug Patch: `domains/display/hard/Q003_bug.patch`
- 修改檔案: `LogicalDisplay.java`

## 狀態
- [ ] 待修復
