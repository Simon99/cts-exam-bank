# Q010: Overlay Display 信任標記遺失

## 問題描述

在 Android Display 子系統中，`OverlayDisplayAdapter` 負責建立用於開發測試的 overlay 顯示設備。這些設備由系統建立，應該被標記為「受信任」的顯示器。

某位開發者回報：在進行 overlay display 相關的功能測試時，發現測試失敗。測試預期 overlay display 應該同時具有 `FLAG_PRESENTATION` 和 `FLAG_TRUSTED` 標記，但實際上只檢測到 `FLAG_PRESENTATION`。

錯誤訊息：
```
expected: <8256> but was: <64>
```
（8256 = FLAG_PRESENTATION | FLAG_TRUSTED，64 = FLAG_PRESENTATION）

## CTS 測試

以下 CTS 測試會失敗：
```
android.display.cts.DisplayTest#testFlags
```

執行指令：
```bash
atest CtsDisplayTestCases:DisplayTest#testFlags
```

## 相關檔案

- `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`

## 任務

1. 找出導致 `FLAG_TRUSTED` 遺失的原因
2. 說明這個 bug 的根本原因
3. 提供修復方案

## 提示

- 問題出在 `OverlayDisplayDevice` 類別的 `getDisplayDeviceInfoLocked()` 方法
- 檢查 flags 的設置流程
- 看看是否有關鍵的 flag 設置被註解掉了

## 預計時間

15 分鐘
