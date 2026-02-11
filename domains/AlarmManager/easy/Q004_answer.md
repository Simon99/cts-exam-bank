# Q004 Answer: getNextAlarmClock Returns Wrong Alarm

## 正確答案
**A. `getNextAlarmClock()` 呼叫時傳入了錯誤的 userId 參數**

## 問題根因
在 `AlarmManager.java` 的 `getNextAlarmClock()` 方法中，
呼叫 service 時應該傳入當前 user 的 ID (`mContext.getUserId()`)，
但 bug 將 userId 寫成了 `0`（系統用戶），導致返回的是系統用戶的下一個鬧鐘，
而非當前用戶設定的鬧鐘。

## Bug 位置
`frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (行 820-825)

## 修復方式
```java
// 錯誤的代碼
public AlarmClockInfo getNextAlarmClock() {
    try {
        return mService.getNextAlarmClock(0);  // BUG: 應該是 mContext.getUserId()
    } catch (RemoteException ex) {
        throw ex.rethrowFromSystemServer();
    }
}

// 正確的代碼
public AlarmClockInfo getNextAlarmClock() {
    try {
        return mService.getNextAlarmClock(mContext.getUserId());
    } catch (RemoteException ex) {
        throw ex.rethrowFromSystemServer();
    }
}
```

## 相關知識
- Android 支援多用戶，每個用戶有獨立的鬧鐘排程
- userId 0 是系統用戶，通常與當前用戶不同
- `getNextAlarmClock()` 用於顯示狀態列的鬧鐘圖示

## 難度說明
**Easy** - 從 fail log 看出返回時間不對，追蹤 getNextAlarmClock() 實作即可發現 userId 錯誤。
