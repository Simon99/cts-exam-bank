# DIS-M001: BrightnessTracker 亮度事件記錄異常

## 題目描述

團隊收到 bug report：在高負載情況下（如快速滑動亮度條），部分亮度調整事件似乎沒有被正確記錄到歷史記錄中。CTS 測試 `BrightnessTest#testBrightnessSliderTracking` 偶爾失敗。

失敗的 CTS Log 顯示：
```
FAILURE: Expected brightness events count >= 5, but got 3
Test was tracking user-initiated brightness changes over 10 seconds
```

問題出現在多核心設備上更頻繁，單核設備幾乎不會重現。

## 測試環境

- CTS Module: `CtsDisplayTestCases`
- 測試方法: `android.hardware.display.cts.BrightnessTest#testBrightnessSliderTracking`
- 相關檔案: `frameworks/base/services/core/java/com/android/server/display/BrightnessTracker.java`

## 任務

1. 分析 `BrightnessTracker.java` 中亮度事件記錄的邏輯
2. 找出導致事件遺失的 bug
3. 解釋為什麼這個 bug 在多核設備上更容易重現
4. 提供修復方案

## 提示

- 重點關注 `handleBrightnessChanged()` 方法
- 思考多線程環境下共享變數的存取安全性
- 注意 `mEventsDirty` 和 `mEvents` 這兩個變數的用途和保護方式
- 追蹤 `mEventsDirty` 在其他方法中如何被讀取使用

## 預計時間

25 分鐘
