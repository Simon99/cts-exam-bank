# Q008 Answer: reorderAlarmsBasedOnStandbyBuckets Priority Inversion

## 正確答案
**A. Comparator 的比較結果返回值正負號錯誤，導致排序順序相反**

## 問題根因
在 `AlarmManagerService.java` 的 `reorderAlarmsBasedOnStandbyBuckets()` 方法中，
使用 Comparator 對鬧鐘按 bucket 優先級排序。ACTIVE bucket 值較小，應該排在前面。
但 Comparator 的返回值邏輯寫反了，導致 RARE (值大) 反而排在前面。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
void reorderAlarmsBasedOnStandbyBuckets(ArrayList<Alarm> alarms) {
    Collections.sort(alarms, (a1, a2) -> {
        // BUG: 應該是 a1.bucket - a2.bucket (升序)
        return a2.standbyBucket - a1.standbyBucket;  // 降序 - 錯誤
    });
}

// 正確的代碼
void reorderAlarmsBasedOnStandbyBuckets(ArrayList<Alarm> alarms) {
    Collections.sort(alarms, (a1, a2) -> {
        // ACTIVE=10, WORKING_SET=20, FREQUENT=30, RARE=40
        // 越小優先級越高，應該用升序
        return a1.standbyBucket - a2.standbyBucket;
    });
}
```

## 相關知識
- Standby Bucket: ACTIVE(10) < WORKING_SET(20) < FREQUENT(30) < RARE(40)
- 較低 bucket 值表示 app 最近被使用，優先級更高
- Comparator 返回負數表示 a1 應該排在 a2 前面

## 難度說明
**Hard** - Comparator 正負號錯誤是常見但難發現的 bug，需要理解排序語意。
