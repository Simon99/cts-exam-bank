# Q003 Answer: setExact Alarm Treated as Inexact

## 正確答案
**B. `setExact()` 傳入的 window 長度使用了 `legacyExactLength()` 而非 0**

## 問題根因
在 `AlarmManager.java` 的 `setExact()` 方法中，呼叫 `setImpl()` 時
window 長度參數應該傳入 `WINDOW_EXACT` (0)，表示需要精確觸發。
但 bug 錯誤地使用了 `legacyExactLength(type)`，這會返回一個非零的 window，
導致精確鬧鐘被當成普通鬧鐘處理。

## Bug 位置
`frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (行 671-673)

## 修復方式
```java
// 錯誤的代碼
public void setExact(int type, long triggerAtMillis, PendingIntent operation) {
    setImpl(type, triggerAtMillis, legacyExactLength(type), 0, 0,  // BUG
            operation, null, null, (Handler) null, null, null);
}

// 正確的代碼
public void setExact(int type, long triggerAtMillis, PendingIntent operation) {
    setImpl(type, triggerAtMillis, WINDOW_EXACT, 0, 0,
            operation, null, null, (Handler) null, null, null);
}
```

## 相關知識
- `WINDOW_EXACT` 常數值為 0，表示精確鬧鐘無彈性窗口
- `legacyExactLength()` 是為舊版 SDK 相容設計，會返回非零 window
- 精確鬧鐘需要 SCHEDULE_EXACT_ALARM 權限（API 31+）

## 難度說明
**Easy** - 從 fail log 可以看出延遲問題，只需比對 set() 和 setExact() 的實作差異即可發現。
