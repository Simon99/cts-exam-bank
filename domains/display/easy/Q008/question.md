# CTS 面試題 - Display Flags 錯誤

## 題目背景

你是 Android 系統團隊的工程師。QA 團隊報告以下 CTS 測試在 overlay display 上失敗：

```
android.display.cts.DisplayTest#testFlags
```

## 失敗訊息

```
junit.framework.AssertionFailedError: expected:<36> but was:<32>
    at android.display.cts.DisplayTest.testFlags(DisplayTest.java:xxx)
```

## 重現步驟

1. 啟用 overlay display（開發者選項 → 模擬輔助顯示器 → 181x161/214）
2. 執行 CTS 測試：
   ```bash
   atest CtsDisplayTestCases:DisplayTest#testFlags
   ```

## 相關代碼路徑

- `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`
- `frameworks/base/core/java/android/view/Display.java`

## 問題

1. 這個錯誤訊息說明了什麼問題？（提示：36 = 0x24, 32 = 0x20）
2. 請找出 bug 的位置並說明根本原因
3. 如何修復這個問題？

## 提示

- `Display.FLAG_PRESENTATION = 0x04`
- `Display.FLAG_TRUSTED = 0x20`
- 測試期望的值是 `FLAG_PRESENTATION | FLAG_TRUSTED = 0x24 = 36`
- 實際回報的值是 32，缺少了 FLAG_PRESENTATION
