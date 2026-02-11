# Q010: Display Flag 條件判斷錯誤

## 問題描述

在 Android Display 子系統中，`DisplayDeviceInfo` 類別負責描述物理顯示設備的特性，包括各種 FLAG 常數來表示顯示器的功能。

某位開發者回報：使用圓形顯示器（如智慧手錶）的設備在調試輸出中，`FLAG_ROUND` 的顯示行為異常：
- 當顯示器**實際是圓形**時，調試輸出**沒有**顯示 `FLAG_ROUND`
- 當顯示器**不是圓形**時，調試輸出**反而顯示** `FLAG_ROUND`

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

- `frameworks/base/services/core/java/com/android/server/display/DisplayDeviceInfo.java`

## 任務

1. 找出導致 `FLAG_ROUND` 狀態報告錯誤的 bug
2. 說明這個 bug 的根本原因
3. 提供修復方案

## 提示

- 問題出在 flag 的條件判斷邏輯
- 檢查 `flagsToString()` 方法中的位元運算條件
- 比較其他 flag 的檢查方式

## 預計時間

15 分鐘
