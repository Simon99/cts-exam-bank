# Q002: triggerAlarmsLocked ConcurrentModification

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testRapidAlarmFiring`

## Failure Log
```
java.util.ConcurrentModificationException
    at java.util.ArrayList$Itr.checkForComodification(ArrayList.java:1013)
    at java.util.ArrayList$Itr.next(ArrayList.java:967)
    at com.android.server.alarm.AlarmManagerService.triggerAlarmsLocked(AlarmManagerService.java:3456)
```

## 現象描述
當大量鬧鐘同時到期時，偶發性地出現 ConcurrentModificationException。
問題發生在 triggerAlarmsLocked() 遍歷鬧鐘列表時，同時有新鬧鐘被加入。

## 提示
- 問題出在 `triggerAlarmsLocked()` 的迭代方式
- 遍歷集合時不能直接修改集合
- 檢查是否在迭代過程中有其他操作修改了列表

## 選項
A. `triggerAlarmsLocked()` 在 foreach 迴圈中直接呼叫 list.remove()

B. `triggerAlarmsLocked()` 使用 iterator 但沒有用 iterator.remove()

C. `triggerAlarmsLocked()` 迭代時呼叫了會修改列表的 callback

D. `triggerAlarmsLocked()` 沒有在迭代前複製列表
