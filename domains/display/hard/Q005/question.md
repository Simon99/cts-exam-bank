# CTS 除錯題目：Display Mode Frame Rate Override 計算錯誤

## 題目資訊
- **難度**: Hard
- **預估時間**: 35 分鐘
- **領域**: Display / Frame Rate

## 情境描述

你在 Android 顯示服務團隊工作。一位資深工程師最近對 `DisplayManagerService.java` 中的 frame rate override 計算邏輯進行了「優化」，聲稱新的實現「更高效且能避免浮點數精度問題」。

在這次變更之後，QA 團隊報告了一個詭異的問題：
- 某些應用程式在請求特定 frame rate 時會出現意外的顯示行為
- 問題只在特定的 refresh rate 組合下發生
- 例如：當顯示器運行在 120Hz，應用請求 48fps 或 72fps 時

## 失敗的 CTS 測試

```
android.display.cts.DisplayTest#testGetSupportedModesOnDefaultDisplay
```

### 測試失敗日誌

```
INSTRUMENTATION_STATUS: class=android.display.cts.DisplayTest
INSTRUMENTATION_STATUS: current=3
INSTRUMENTATION_STATUS: numtests=15
INSTRUMENTATION_STATUS: test=testGetSupportedModesOnDefaultDisplay
INSTRUMENTATION_STATUS: stack=java.lang.AssertionError: Frame rate override mode selection failed
Expected refresh rate override to be applied for valid divisor combinations
  at android.display.cts.DisplayTest.testGetSupportedModesOnDefaultDisplay(DisplayTest.java:287)
  
Additional info:
  Display refresh rate: 120.0 Hz
  Requested frame rate: 48.0 fps
  Expected: Mode with 48.0 Hz or override to be applied
  Actual: Frame rate override was rejected when it should have been accepted
  
  numPeriods calculation: 2.5 (120/48)
  numPeriodsRound expected: 3 (Math.round(2.5))
  numPeriodsRound actual: 2 (floor(2.5 + 0.4999) = floor(2.9999) = 2)
```

## 你的任務

1. 定位有問題的 frame rate override 計算邏輯
2. 理解原本的計算意圖與新的「優化」之間的差異
3. 分析為什麼這個變更導致邊界情況失敗
4. 修復這個 bug

## 提示

- 問題涉及 `getDisplayInfoForFrameRateOverride()` 方法
- 檢查 `numPeriodsRound` 的計算邏輯
- 注意 `Math.round()` vs `Math.floor()` 在邊界值的行為差異
- 思考 `>` vs `>=` 在閾值比較中的影響
- 考慮 `floor(x + 0.4999)` 是否等價於 `round(x)`

## 相關檔案

- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

## 評分標準

| 項目 | 分數 |
|------|------|
| 找出 bug 位置 | 25% |
| 理解計算錯誤的數學原理 | 25% |
| 分析邊界條件問題 | 25% |
| 正確修復 bug | 25% |
