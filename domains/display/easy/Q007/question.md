# CTS 面試題 - Display Type 錯誤

## 題目背景

你是 Android 系統團隊的工程師。QA 團隊報告以下 CTS 測試失敗：

```
android.display.cts.DisplayTest#testGetDisplays
```

## 失敗訊息

```
junit.framework.AssertionFailedError: 
    at android.display.cts.DisplayTest.testGetDisplays(DisplayTest.java:xxx)
```

測試日誌顯示 `hasSecondaryDisplay` 為 false，但應該為 true。

## 重現步驟

1. 啟用 overlay display（開發者選項 → 模擬輔助顯示器 → 181x161/214）
2. 執行 CTS 測試：
   ```bash
   atest CtsDisplayTestCases:DisplayTest#testGetDisplays
   ```

## 相關代碼路徑

- `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`
- CTS 測試使用 `display.getType() == Display.TYPE_OVERLAY` 來識別 overlay display

## 問題

1. 為什麼測試無法找到 secondary display？
2. 請找出 bug 的位置並說明根本原因
3. 如何修復這個問題？

## 提示

- 測試通過 `getType()` 方法判斷是否為 overlay display
- 檢查 OverlayDisplayAdapter 中設置 display type 的代碼
- `Display.TYPE_OVERLAY` 和 `Display.TYPE_VIRTUAL` 是不同的類型
