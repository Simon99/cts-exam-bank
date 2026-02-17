# Q004 Answer: Add Vibrator State Listener Executor Not Used

## 正確答案
**A**

## 問題根因
在 `SystemVibrator.java` 的 `addVibratorStateListener(executor, listener)` 方法中，
儲存監聽器時忽略了 executor 參數，直接使用主執行緒的 Handler。

## Bug 位置
`frameworks/base/core/java/android/os/SystemVibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public void addVibratorStateListener(
        @NonNull Executor executor,
        @NonNull OnVibratorStateChangedListener listener) {
    // BUG: executor 被忽略，直接使用 mHandler
    mStateListeners.put(listener, new ListenerDelegate(mHandler, listener));
}

// 正確的代碼
public void addVibratorStateListener(
        @NonNull Executor executor,
        @NonNull OnVibratorStateChangedListener listener) {
    mStateListeners.put(listener, new ListenerDelegate(executor, listener));
}
```

## 選項分析
- **A** Executor 參數被忽略，使用預設 Handler — ✅ 正確
- **B** ListenerDelegate 不支援 Executor — 錯誤，有對應的建構函數
- **C** Executor 參數驗證失敗 — 錯誤，會有 NPE
- **D** 回呼在註冊時就執行 — 錯誤，回呼是狀態變更時觸發

## 相關知識
- Executor 允許控制回呼執行的執行緒
- 避免在主執行緒做繁重工作影響 UI
- ListenerDelegate 封裝了 executor 和 listener

## 難度說明
**Medium** - 需要追蹤 executor 參數的使用流程，理解 ListenerDelegate 的運作。
