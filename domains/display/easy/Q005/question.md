# CTS 面試題 - Display xDpi 錯誤

## 題目背景

你是 Android 系統團隊的工程師。QA 團隊報告以下 CTS 測試在 overlay display 上失敗：

```
android.display.cts.DisplayTest#testGetMetrics
```

## 失敗訊息

```
junit.framework.AssertionFailedError: expected:<214.0> but was:<215.0>
    at android.display.cts.DisplayTest.testGetMetrics(DisplayTest.java:xxx)
```

## 重現步驟

1. 啟用 overlay display（開發者選項 → 模擬輔助顯示器 → 181x161/214）
2. 執行 CTS 測試：
   ```bash
   atest CtsDisplayTestCases:DisplayTest#testGetMetrics
   ```

## 相關代碼路徑

- `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`
- `frameworks/base/services/core/java/com/android/server/display/DisplayDeviceInfo.java`

## 問題

1. 這個錯誤訊息說明了什麼問題？
2. 請找出 bug 的位置並說明根本原因
3. 如何修復這個問題？

## 提示

- 測試期望 xdpi 值為 214，但實際回報的是 215
- 這是一個典型的 off-by-one 錯誤
- 檢查 OverlayDisplayAdapter 中設置 xDpi 的代碼
