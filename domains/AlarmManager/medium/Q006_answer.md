# Q006 Answer: RTC to ELAPSED Conversion Wrong

## 正確答案
**A. `convertToElapsed()` 計算時使用加法而非減法（或相反）**

## 問題根因
在 `AlarmManagerService.java` 的 `convertToElapsed()` 方法中，
將 RTC 時間轉換為 ELAPSED_REALTIME 時，計算公式應該是：
`elapsed = rtcTrigger - System.currentTimeMillis() + SystemClock.elapsedRealtime()`

但 bug 將減法寫成加法：
`elapsed = rtcTrigger + System.currentTimeMillis() + SystemClock.elapsedRealtime()`

導致計算出的觸發時間完全錯誤。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
private long convertToElapsed(long rtcTrigger, int type) {
    if (type == RTC || type == RTC_WAKEUP) {
        return rtcTrigger + System.currentTimeMillis() + SystemClock.elapsedRealtime();  // BUG
    }
    return rtcTrigger;
}

// 正確的代碼
private long convertToElapsed(long rtcTrigger, int type) {
    if (type == RTC || type == RTC_WAKEUP) {
        return rtcTrigger - System.currentTimeMillis() + SystemClock.elapsedRealtime();
    }
    return rtcTrigger;
}
```

## 相關知識
- RTC (Real Time Clock) 基於牆上時鐘，會受 NTP 同步影響
- ELAPSED_REALTIME 基於開機後經過時間，不受時間變更影響
- 所有鬧鐘內部都轉換為 ELAPSED 格式以確保一致性

## 難度說明
**Medium** - 需要理解 RTC 和 ELAPSED 的差異，以及時間轉換邏輯。
