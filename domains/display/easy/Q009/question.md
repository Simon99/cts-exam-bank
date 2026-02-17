# CTS 題目：Display 屬性獲取條件判斷錯誤

## 情境

你是 Android Framework 團隊的工程師。一位 OEM 客戶反映，他們的裝置在啟動時經常發生 `NullPointerException`，崩潰日誌指向 DisplayManagerService。

進一步調查發現，CTS 測試 `android.display.cts.DisplayTest#testGetDisplayAttrs` 也失敗，錯誤訊息顯示無法獲取顯示屬性。

## CTS 失敗訊息

```
android.display.cts.DisplayTest#testGetDisplayAttrs

FAILURE: java.lang.NullPointerException
    at android.view.Display.getDisplayInfo(Display.java:540)
    at android.view.Display.getName(Display.java:595)
    at android.display.cts.DisplayTest.testGetDisplayAttrs(DisplayTest.java:112)

Expected: Display info should be available
Actual: getDisplayInfo() returned null
```

## 可能的問題區域

根據堆疊追蹤，問題可能在 DisplayManagerService 的顯示資訊獲取邏輯：
- `frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`

重點關注 `getDisplayInfoLocked()` 方法的快取邏輯。

## 任務

1. 找出導致 CTS 測試失敗的 bug
2. 解釋 bug 為什麼會導致 `NullPointerException`
3. 提出修復方案

## 提示

- 檢查條件判斷的邏輯是否正確
- 快取（cache）邏輯應該在什麼情況下初始化？
- 考慮首次呼叫 vs. 後續呼叫的行為差異
