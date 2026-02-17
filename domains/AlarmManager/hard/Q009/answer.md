# Q009 Answer: setTimeZoneImpl Alarms Not Adjusted

## 正確答案
**A. `setTimeZoneImpl()` 沒有呼叫 `rebatchAllAlarmsLocked()` 重新計算**

## 問題根因
在 `AlarmManagerService.java` 的 `setTimeZoneImpl()` 方法中，
時區變更後應該呼叫 `rebatchAllAlarmsLocked(true)` 來重新計算所有 RTC 鬧鐘的觸發時間。
但 bug 版本漏掉了這個呼叫，只更新了系統時區設定，
沒有通知 AlarmManager 重新評估現有的鬧鐘。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
void setTimeZoneImpl(String tz) {
    if (TextUtils.isEmpty(tz)) {
        return;
    }
    TimeZone zone = TimeZone.getTimeZone(tz);
    TimeZone.setDefault(zone);
    // BUG: 漏掉了重新計算鬧鐘
}

// 正確的代碼
void setTimeZoneImpl(String tz) {
    if (TextUtils.isEmpty(tz)) {
        return;
    }
    TimeZone zone = TimeZone.getTimeZone(tz);
    TimeZone.setDefault(zone);
    
    synchronized (mLock) {
        rebatchAllAlarmsLocked(true);  // 重新計算所有鬧鐘
        rescheduleKernelAlarmsLocked();
    }
    
    // 通知時區變更
    Intent intent = new Intent(Intent.ACTION_TIMEZONE_CHANGED);
    intent.putExtra("time-zone", zone.getID());
    mContext.sendBroadcastAsUser(intent, UserHandle.ALL);
}
```

## 相關知識
- RTC 鬧鐘基於 wall clock，時區變更會影響「當地時間」的解釋
- ELAPSED_REALTIME 鬧鐘不受時區影響
- rebatch 會重新計算所有鬧鐘的 elapsed 觸發時間

## 難度說明
**Hard** - 需要理解時區變更對 RTC 鬧鐘的影響，以及正確的處理流程。
