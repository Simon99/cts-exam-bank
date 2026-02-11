# Q005 Answer: Alarm Cancel with PendingIntent Fails

## 正確答案
**A. `cancel()` 呼叫 service 時參數順序錯誤，將 listener 和 operation 位置互換**

## 問題根因
在 `AlarmManager.java` 的 `cancel(PendingIntent operation)` 方法中，
呼叫 `mService.remove()` 時，第一個參數應該是 PendingIntent，第二個是 listener (null)。
但 bug 將順序寫反，傳入 `remove(null, operation)`，導致 service 找不到對應的鬧鐘。

## Bug 位置
`frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (行 840-845)

## 修復方式
```java
// 錯誤的代碼
public void cancel(PendingIntent operation) {
    if (operation == null) {
        throw new NullPointerException("operation");
    }
    try {
        mService.remove(null, operation);  // BUG: 參數順序錯誤
    } catch (RemoteException ex) {
        throw ex.rethrowFromSystemServer();
    }
}

// 正確的代碼
public void cancel(PendingIntent operation) {
    if (operation == null) {
        throw new NullPointerException("operation");
    }
    try {
        mService.remove(operation, null);
    } catch (RemoteException ex) {
        throw ex.rethrowFromSystemServer();
    }
}
```

## 相關知識
- `remove(PendingIntent operation, IAlarmListener listener)` 是 service 接口
- 取消時只需提供其中一個識別符，另一個傳 null
- PendingIntent 透過 filterEquals() 匹配

## 難度說明
**Easy** - 從 fail log 可以看出 cancel 無效，比對 service 接口定義即可發現參數錯誤。
