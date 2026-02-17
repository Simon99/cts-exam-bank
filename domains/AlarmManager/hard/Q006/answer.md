# Q006 Answer: rescheduleKernelAlarmsLocked Missed Wakeup

## 正確答案
**B. `rescheduleKernelAlarmsLocked()` 只考慮第一個 batch，忽略了其他 batch 的 wakeup alarm**

## 問題根因
在 `AlarmManagerService.java` 的 `rescheduleKernelAlarmsLocked()` 方法中，
尋找下一個需要 kernel wakeup 的鬧鐘時，應該遍歷所有 batch 找到最早的 wakeup alarm。
但 bug 只檢查第一個 batch：如果第一個 batch 沒有 wakeup alarm（或被取消了），
就認為沒有需要設定的 kernel alarm，忽略了後續 batch 中的 wakeup alarm。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
void rescheduleKernelAlarmsLocked() {
    Batch firstBatch = mAlarmBatches.get(0);
    Alarm nextWakeup = firstBatch.findFirstWakeupAlarm();  // BUG: 只檢查第一個 batch
    if (nextWakeup != null) {
        setKernelAlarm(nextWakeup.whenElapsed);
    }
}

// 正確的代碼
void rescheduleKernelAlarmsLocked() {
    Alarm nextWakeup = null;
    for (Batch batch : mAlarmBatches) {
        Alarm wakeup = batch.findFirstWakeupAlarm();
        if (wakeup != null) {
            if (nextWakeup == null || wakeup.whenElapsed < nextWakeup.whenElapsed) {
                nextWakeup = wakeup;
            }
        }
    }
    if (nextWakeup != null) {
        setKernelAlarm(nextWakeup.whenElapsed);
    }
}
```

## 相關知識
- Kernel alarm 是喚醒裝置的唯一方式
- 每次鬧鐘變更後都需要重新評估 kernel alarm
- 需要找到所有 batch 中最早的 wakeup alarm

## 難度說明
**Hard** - 需要理解 kernel alarm 的排程機制和多 batch 結構。
