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
- [ ] 待修復
