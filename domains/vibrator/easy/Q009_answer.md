# Q009 Answer: Remove Vibrator State Listener Failed

## 正確答案
**D**

## 問題根因
在 `SystemVibrator.java` 的 `removeVibratorStateListener()` 方法中，
錯誤地呼叫了 `add()` 而非 `remove()`，導致移除操作實際上又新增了一次監聽器。

## Bug 位置
`frameworks/base/core/java/android/os/SystemVibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public void removeVibratorStateListener(OnVibratorStateChangedListener listener) {
    mStateListeners.add(listener);  // BUG: 應該是 remove
}

// 正確的代碼
public void removeVibratorStateListener(OnVibratorStateChangedListener listener) {
    mStateListeners.remove(listener);
}
```

## 選項分析
- **A** 監聽器比較使用錯誤的 equals — 錯誤，問題不在比較邏輯
- **B** 服務端快取未清除 — 錯誤，錯誤在客戶端
- **C** 多執行緒同步問題 — 錯誤，會有不同的錯誤模式
- **D** 內部呼叫了 add() 而非 remove() — ✅ 正確

## 相關知識
- VibratorStateListener 用於監聽振動狀態變更（開始/停止）
- 監聽器模式是 Android 常見的事件處理方式
- 正確管理監聽器生命週期避免記憶體洩漏

## 難度說明
**Easy** - 監聽器完全無法移除是很明顯的錯誤，檢查 remove 方法實作即可。
