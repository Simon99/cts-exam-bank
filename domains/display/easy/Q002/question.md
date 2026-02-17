# CTS 題目：BrightnessTracker Lux 數據邊界檢查錯誤

## 題目 ID
DIS-E002

## 難度
Easy (15 分鐘)

## 情境描述

開發團隊收到用戶反饋：「手動調整螢幕亮度滑桿後，系統似乎沒有正確記錄這次調整。特別是在光線穩定的室內環境，亮度學習功能完全無效。」

QA 團隊確認這個問題在光線感測器只有單一讀數時會發生。當環境光線穩定，感測器只回報一個數據點時，亮度調整事件就不會被記錄。

## 相關 CTS 測試

```
adb shell am instrument -w -e class android.hardware.display.cts.BrightnessTest#testBrightnessSliderTracking \
    android.hardware.display.cts/androidx.test.runner.AndroidJUnitRunner
```

**模組**: `CtsDisplayTestCases`

## CTS 測試失敗訊息

```
android.hardware.display.cts.BrightnessTest#testBrightnessSliderTracking FAILED

junit.framework.AssertionFailedError: Expected brightness change event to be recorded
Expected: at least 1 event recorded
Actual: 0 events recorded
    at android.hardware.display.cts.BrightnessTest.testBrightnessSliderTracking(BrightnessTest.java:198)
```

## 問題範圍

- **檔案路徑**: `frameworks/base/services/core/java/com/android/server/display/BrightnessTracker.java`
- **相關區域**: `handleBrightnessChanged()` 方法中的 lux 數據驗證邏輯

## 提示

1. 問題與光線感測器數據的邊界條件檢查有關
2. 注意 "empty" 和 "single element" 的邊界處理
3. 比較運算符的選擇很重要
4. 搜尋 `luxValues.length` 相關的條件判斷

## 任務

1. 找出導致 CTS 測試失敗的 bug
2. 解釋為什麼這個 bug 會導致測試失敗
3. 提供修復方案

## 評估標準

- 正確定位 bug 位置 (40%)
- 解釋 bug 的根本原因 (30%)
- 提供正確的修復方案 (30%)
