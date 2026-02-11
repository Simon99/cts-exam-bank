# Q004 Answer: Cancel Vibration Not Working

## 正確答案
**D**

## 問題根因
在 `Vibrator.java` 的 `cancel()` 方法中，有一個錯誤的 early return，
導致方法在執行實際取消操作之前就返回了。

## Bug 位置
`frameworks/base/core/java/android/os/Vibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public void cancel() {
    return;  // BUG: 提前返回，後續取消邏輯不會執行
    cancelVibration(VibrationAttributes.USAGE_FILTER_MATCH_ALL);
}

// 正確的代碼
public void cancel() {
    cancelVibration(VibrationAttributes.USAGE_FILTER_MATCH_ALL);
}
```

## 選項分析
- **A** 振動器硬體不支援中途取消 — 錯誤，這是標準功能
- **B** 權限不足無法取消 — 錯誤，取消自己啟動的振動不需要額外權限
- **C** cancelVibration 被錯誤過濾 — 錯誤，根本沒有呼叫到
- **D** 方法內有 early return — ✅ 正確，return 語句阻止了實際取消

## 相關知識
- cancel() 會取消所有正在進行的振動
- 內部呼叫 cancelVibration() 與服務通訊
- USAGE_FILTER_MATCH_ALL 表示取消所有類型的振動

## 難度說明
**Easy** - 方法完全無效果，檢查實作時很容易發現 return 語句。
