# CTS 題目：Display Override Info 更新異常

## 背景

你正在調試一個 Android 設備的 Display 子系統問題。使用者報告說，當 Window Manager 更新 display 的 override 資訊（如 rotation、insets）時，Display.getMetrics() 返回的值有時不會正確反映最新的變更。

## 症狀

- 執行 CTS 測試 `DisplayTest#testGetMetrics` 失敗
- Display metrics 在 override 資訊變更後沒有正確更新
- 螢幕旋轉或 inset 變更時，應用程式獲取的 metrics 可能是舊值

## 相關日誌

```
DisplayManagerService: setDisplayInfoOverrideFromWindowManagerLocked called for display 0
DisplayManagerService: Override info provided, checking against existing...
DisplayManagerService: setDisplayInfoOverrideFromWindowManagerLocked returning false
```

## 相關檔案

- `frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`

## 任務

1. 分析 `LogicalDisplay.java` 中的 `setDisplayInfoOverrideFromWindowManagerLocked()` 方法
2. 找出導致 override info 更新邏輯錯誤的 bug
3. 解釋為什麼這個 bug 會導致 CTS 測試失敗
4. 提供修復方案

## 提示

- 注意方法中的條件判斷邏輯
- 思考什麼情況下應該更新 override info，什麼情況下不應該
- 方法的返回值代表什麼意義？

## CTS 測試資訊

- **模組**: CtsDisplayTestCases
- **測試**: android.display.cts.DisplayTest#testGetMetrics
