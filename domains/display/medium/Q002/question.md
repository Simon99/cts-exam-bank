# CTS 題目：DIS-M002

## 題目資訊
- **難度**: Medium
- **領域**: Display / Display Metrics
- **預估時間**: 20 分鐘

## 情境描述

你是 Android Framework 團隊的工程師，負責維護 Display 子系統。QA 團隊回報 CTS 測試失敗：

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.display.cts.DisplayTest#testGetMetrics
java.lang.AssertionError: 
Expected: 214
Actual: 215
    at android.display.cts.DisplayTest.testGetMetrics(DisplayTest.java:648)
```

測試嘗試驗證 overlay display 的 DisplayMetrics，但 densityDpi 的值與預期不符。

## 測試說明

`DisplayTest#testGetMetrics` 執行以下步驟：
1. 創建一個 overlay display（透過 `settings put global overlay_display_devices 181x161/214`）
2. 呼叫 `display.getMetrics(outMetrics)` 取得 DisplayMetrics
3. 驗證 `outMetrics.densityDpi` 應為 214
4. 驗證 `outMetrics.xdpi` 和 `outMetrics.ydpi` 應為 214.0

## 呼叫鏈追蹤

```
CTS: display.getMetrics(outMetrics)
  → Display.getMetrics()                         [Display.java:1622]
    → mDisplayInfo.getAppMetrics(outMetrics, displayAdjustments)
      → getMetricsWithSize(outMetrics, ..., appWidth, appHeight)
        → outMetrics.densityDpi = ???
```

## 相關程式碼

**檔案**: `frameworks/base/core/java/android/view/DisplayInfo.java`

**功能說明**:
- `DisplayInfo` 類封裝了顯示器的各種資訊
- `getMetricsWithSize()` 方法負責將 DisplayInfo 的屬性填入 DisplayMetrics 物件
- 這是 Display.getMetrics() 的核心實作路徑

**關鍵欄位**:
- `logicalDensityDpi`: 邏輯 DPI 密度
- `physicalXDpi` / `physicalYDpi`: 物理 DPI

## 除錯提示

1. 注意錯誤訊息：densityDpi 預期 214，實際 215
2. 差異剛好是 1，這是典型的 off-by-one 錯誤
3. 追蹤 Display.getMetrics() → DisplayInfo.getAppMetrics() → getMetricsWithSize() 的呼叫鏈
4. 檢查 densityDpi 的賦值邏輯

## 任務

1. 找出導致 CTS 測試失敗的 bug
2. 說明 bug 的根本原因
3. 提供修復方案

## 評分標準

- 正確定位 bug 位置 (30%)
- 理解 bug 成因（為何 densityDpi 會多 1）(30%)
- 修復方案正確性 (30%)
- 說明清晰度 (10%)
