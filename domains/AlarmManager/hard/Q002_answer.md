# Q002 Answer: triggerAlarmsLocked ConcurrentModification

## 正確答案
**C. `triggerAlarmsLocked()` 迭代時呼叫了會修改列表的 callback**

## 問題根因
在 `AlarmManagerService.java` 的 `triggerAlarmsLocked()` 方法中，
遍歷到期鬧鐘時，每個鬧鐘觸發後會呼叫 delivery callback。
但 bug 是 callback 中會設定新的重複鬧鐘（對於 repeating alarm），
這個操作會修改正在迭代的鬧鐘列表，導致 ConcurrentModificationException。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
void triggerAlarmsLocked(ArrayList<Alarm> triggerList) {
    for (Alarm alarm : mPendingAlarms) {  // 使用 foreach
        triggerList.add(alarm);
        if (alarm.repeatInterval > 0) {
            // BUG: 這裡會修改 mPendingAlarms
            scheduleNextRepeatingAlarm(alarm);
        }
    }
}

// 正確的代碼
void triggerAlarmsLocked(ArrayList<Alarm> triggerList) {
    ArrayList<Alarm> toReschedule = new ArrayList<>();
    for (Alarm alarm : mPendingAlarms) {
        triggerList.add(alarm);
        if (alarm.repeatInterval > 0) {
            toReschedule.add(alarm);  // 收集需要重排的鬧鐘
        }
    }
    // 迭代結束後再處理重複鬧鐘
    for (Alarm alarm : toReschedule) {
        scheduleNextRepeatingAlarm(alarm);
    }
}
```

## 相關知識
- Java foreach 使用 Iterator，迭代中修改集合會拋出 CME
- 解決方案：收集待修改項，迭代後處理；或複製集合
- 這在 callback 場景特別容易發生

## 難度說明
**Hard** - 需要追蹤 callback 的副作用，理解迭代與修改的衝突。
