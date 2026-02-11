# 答案：BrightnessTracker Lux 數據邊界檢查錯誤

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/BrightnessTracker.java`  
**方法**: `handleBrightnessChanged()`  
**行號**: 約 377 行

## Bug 程式碼

```java
// 錯誤的程式碼
if (luxValues.length <= 1) {
    // No sensor data so ignore this.
    return;
}
```

## 正確程式碼

```java
// 正確的程式碼
if (luxValues.length == 0) {
    // No sensor data so ignore this.
    return;
}
```

## 根本原因分析

### 邊界檢查過於嚴格 (Off-by-One Error)

1. **原始意圖**: 當沒有光線感測器數據時，不記錄亮度調整事件
2. **Bug 行為**: 將條件從 `== 0` 改成 `<= 1`，導致只有一個數據點時也被錯誤拒絕
3. **影響**: 在光線穩定環境下（感測器只回報單一讀數），合法的亮度調整事件不會被記錄

### 問題情境

當用戶在以下情況調整亮度時會觸發 bug：
- 室內光線穩定
- 感測器回報頻率低
- 快速調整亮度（感測器來不及回報多個讀數）

### 為什麼 CTS 測試會失敗

`testBrightnessSliderTracking` 測試驗證：
1. 模擬用戶調整亮度滑桿
2. 檢查系統是否正確記錄 `BrightnessChangeEvent`
3. 測試環境可能只提供單一光線數據點

由於邊界檢查錯誤，合法的事件被丟棄，導致測試期望的事件數量為 0。

## 修復方案

```diff
-            if (luxValues.length <= 1) {
+            if (luxValues.length == 0) {
                 // No sensor data so ignore this.
                 return;
             }
```

## 驗證修復

修復後，重新運行 CTS 測試：

```bash
adb shell am instrument -w -e class android.hardware.display.cts.BrightnessTest#testBrightnessSliderTracking \
    android.hardware.display.cts/androidx.test.runner.AndroidJUnitRunner
```

## Bug 分類

- **類型**: BOUND (邊界條件錯誤)
- **嚴重性**: Medium
- **影響範圍**: 自動亮度學習功能
- **難度**: Easy - 單純的比較運算符錯誤

## 學習要點

1. **邊界條件要精確**: `== 0` 和 `<= 1` 在語意上完全不同
2. **空陣列 vs 單元素陣列**: 是常見的邊界錯誤來源
3. **注意代碼意圖**: 註解說 "No sensor data"，但 `<= 1` 包含了有一個數據點的情況
