# Q001 Answer: Basic Alarm Not Firing

## 正確答案
**B. `set()` 方法中 `legacyExactLength()` 呼叫時傳入了錯誤的 type 參數**

## 問題根因
在 `AlarmManager.java` 的 `set()` 方法中，呼叫 `legacyExactLength()` 時應該傳入 `type` 參數，
但 bug 將參數寫成了 `0`，導致 `legacyExactLength()` 無法正確判斷鬧鐘類型，
最終計算出錯誤的 window 長度，使鬧鐘無法正確排程。

## Bug 位置
`frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (行 485-487)

## 修復方式
```java
// 錯誤的代碼
public void set(int type, long triggerAtMillis, PendingIntent operation) {
    setImpl(type, triggerAtMillis, legacyExactLength(0), 0, 0,  // BUG: 應該是 type
            operation, null, null, (Handler) null, null, null);
}

// 正確的代碼
public void set(int type, long triggerAtMillis, PendingIntent operation) {
    setImpl(type, triggerAtMillis, legacyExactLength(type), 0, 0,
            operation, null, null, (Handler) null, null, null);
}
```

## 相關知識
- `legacyExactLength()` 根據 alarm type 決定是否需要精確觸發
- RTC 和 ELAPSED_REALTIME 類型的處理方式不同
- 基本 set() 依賴正確的 window length 來排程

## 難度說明
**Easy** - 從 fail log 可以看出鬧鐘沒有觸發，只需追蹤 set() 呼叫鏈即可發現參數傳遞錯誤。
