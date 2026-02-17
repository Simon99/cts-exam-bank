# Q002 Answer: Alarm Cancel Fails for Listener

## 正確答案
**B. `cancel()` 方法中傳遞給 service 的是 null 而非實際 listener**

## 問題根因
在 `AlarmManager.java` 的 `cancel(OnAlarmListener listener)` 方法中，
呼叫 service 取消時應該傳入 `mTargetHandler` 處理過的 listener wrapper，
但 bug 將 listener 參數寫成了 `null`，導致 service 無法識別要取消的鬧鐘。

## Bug 位置
`frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (行 855-865)

## 修復方式
```java
// 錯誤的代碼
public void cancel(OnAlarmListener listener) {
    if (listener == null) {
        throw new NullPointerException("listener cannot be null");
    }
    ListenerWrapper wrapper = new ListenerWrapper(listener);
    try {
        mService.remove(null, null);  // BUG: 應該傳入 wrapper
    } catch (RemoteException ex) {
        throw ex.rethrowFromSystemServer();
    }
}

// 正確的代碼
public void cancel(OnAlarmListener listener) {
    if (listener == null) {
        throw new NullPointerException("listener cannot be null");
    }
    ListenerWrapper wrapper = new ListenerWrapper(listener);
    try {
        mService.remove(null, wrapper);
    } catch (RemoteException ex) {
        throw ex.rethrowFromSystemServer();
    }
}
```

## 相關知識
- OnAlarmListener 需要透過 ListenerWrapper 包裝才能傳遞給 service
- 取消鬧鐘時 PendingIntent 和 listener 二選一，另一個為 null
- service.remove() 根據傳入的參數匹配對應的鬧鐘

## 難度說明
**Easy** - 從 fail log 可以看出 cancel 沒有生效，追蹤 cancel() 方法可以發現參數傳遞錯誤。
