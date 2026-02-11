# Q001: setImpl Race Condition

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testConcurrentAlarmSetting`

## Failure Log
```
junit.framework.AssertionFailedError: Concurrent alarm setting caused inconsistent state
expected: both alarms scheduled correctly
actual: one alarm overwrote the other, ArrayIndexOutOfBoundsException in batch

Stack trace:
java.lang.ArrayIndexOutOfBoundsException: Index -1 out of bounds for length 5
    at com.android.server.alarm.AlarmManagerService.insertAndBatchAlarmLocked(AlarmManagerService.java:2567)
    at com.android.server.alarm.AlarmManagerService.setImplLocked(AlarmManagerService.java:1623)
```

## 現象描述
兩個執行緒同時呼叫 setImpl() 設定鬧鐘，偶發性地出現 ArrayIndexOutOfBoundsException。
問題是隨機發生的，約 10% 的測試執行會失敗。

## 提示
- 問題出在 `setImplLocked()` 的鎖定範圍
- 鬧鐘批次插入時需要完整的同步保護
- 檢查 synchronized 區塊的範圍

## 選項
A. `setImplLocked()` 在讀取 batch 大小和插入之間沒有持有鎖，導致 race condition

B. `setImplLocked()` 使用了錯誤的鎖物件

C. `setImplLocked()` 在插入後沒有正確更新 batch 的 size 計數器

D. `setImplLocked()` 對 batch list 的操作沒有使用 CopyOnWriteArrayList
