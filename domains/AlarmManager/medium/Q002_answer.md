# Q002 Answer: setWindow Ignores Window Length

## 正確答案
**A. `setWindow()` 將 windowLengthMillis 傳遞到錯誤的參數位置**

## 問題根因
在 `AlarmManager.java` 的 `setWindow()` 方法中，
呼叫 `setImpl()` 時，window 長度應該傳遞到第三個參數位置，
但 bug 將 `windowLengthMillis` 放到了 interval 參數位置（第四個參數），
而 window 長度位置傳入了 0 (WINDOW_EXACT)，導致鬧鐘被當成精確鬧鐘處理。

## Bug 位置
`frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (行 637-639)

## 修復方式
```java
// 錯誤的代碼
public void setWindow(int type, long windowStartMillis, long windowLengthMillis,
        PendingIntent operation) {
    setImpl(type, windowStartMillis, 0, windowLengthMillis, 0,  // BUG: 參數位置錯誤
            operation, null, null, (Handler) null, null, null);
}

// 正確的代碼
public void setWindow(int type, long windowStartMillis, long windowLengthMillis,
        PendingIntent operation) {
    setImpl(type, windowStartMillis, windowLengthMillis, 0, 0,
            operation, null, null, (Handler) null, null, null);
}
```

## 相關知識
- `setImpl()` 簽名：setImpl(type, triggerAt, windowLength, interval, flags, ...)
- windowLength 控制 batching 彈性範圍
- WINDOW_EXACT (0) 表示精確觸發，無彈性

## 難度說明
**Medium** - 需要理解 setImpl() 的參數順序，以及 window 和 interval 的區別。
