# Q003 Answer: rebatchAllAlarmsLocked Lost Alarms

## 正確答案
**A. `rebatchAllAlarmsLocked()` 在清空舊 batch 前沒有複製所有鬧鐘**

## 問題根因
在 `AlarmManagerService.java` 的 `rebatchAllAlarmsLocked()` 方法中，
重新批次的標準做法是：1) 收集所有鬧鐘 2) 清空舊 batch 3) 重新插入。
但 bug 在收集時使用了 iterator 遍歷，同時在某些條件下跳過了鬧鐘，
導致部分鬧鐘沒有被收集到臨時列表中，清空後就永久遺失了。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
void rebatchAllAlarmsLocked(boolean doValidate) {
    ArrayList<Alarm> allAlarms = new ArrayList<>();
    for (Batch batch : mAlarmBatches) {
        for (int i = 0; i < batch.size(); i++) {
            Alarm a = batch.get(i);
            if (a.whenElapsed > 0) {  // BUG: 這個條件會跳過某些有效鬧鐘
                allAlarms.add(a);
            }
        }
    }
    mAlarmBatches.clear();
    // ... re-insert alarms
}

// 正確的代碼
void rebatchAllAlarmsLocked(boolean doValidate) {
    ArrayList<Alarm> allAlarms = new ArrayList<>();
    for (Batch batch : mAlarmBatches) {
        allAlarms.addAll(batch.getAlarms());  // 無條件收集所有
    }
    mAlarmBatches.clear();
    // ... re-insert alarms
}
```

## 相關知識
- 時區/時間變更需要重新計算所有 RTC 類型鬧鐘
- rebatch 是破壞性操作，必須確保不遺失鬧鐘
- 先收集再清空是安全的做法

## 難度說明
**Hard** - 需要理解 rebatch 的完整流程，找出條件判斷導致的資料遺失。
