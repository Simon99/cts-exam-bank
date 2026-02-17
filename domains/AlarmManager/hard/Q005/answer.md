# Q005 Answer: deliverAlarmsLocked Exception Handling

## 正確答案
**A. try-catch 區塊範圍過大，包含了整個迴圈而非單一鬧鐘**

## 問題根因
在 `AlarmManagerService.java` 的 `deliverAlarmsLocked()` 方法中，
try-catch 應該包裹每個單獨鬧鐘的傳遞邏輯，讓一個鬧鐘失敗不影響其他。
但 bug 將 try 放在迴圈外面，一旦任何鬧鐘拋出異常，就會跳出整個迴圈，
導致後續的鬧鐘都無法傳遞。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
void deliverAlarmsLocked(ArrayList<Alarm> triggerList) {
    try {
        for (Alarm alarm : triggerList) {
            // 任何一個失敗就會跳出整個迴圈
            deliverAlarm(alarm);
        }
    } catch (Exception e) {
        Slog.w(TAG, "Alarm delivery failed", e);
    }
}

// 正確的代碼
void deliverAlarmsLocked(ArrayList<Alarm> triggerList) {
    for (Alarm alarm : triggerList) {
        try {
            deliverAlarm(alarm);
        } catch (Exception e) {
            // 單一失敗不影響其他鬧鐘
            Slog.w(TAG, "Alarm delivery failed for " + alarm, e);
        }
    }
}
```

## 相關知識
- 錯誤隔離原則：一個操作失敗不應影響其他獨立操作
- PendingIntent.send() 可能因多種原因失敗
- 服務應該保持健壯，gracefully 處理個別失敗

## 難度說明
**Hard** - 需要理解異常處理範圍的影響，以及服務健壯性設計原則。
