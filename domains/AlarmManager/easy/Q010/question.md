# Q010: Alarm Matches Wrong PendingIntent

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testAlarmMatches`

## Failure Log
```
junit.framework.AssertionFailedError: Alarm.matches() returned wrong result
expected: alarm1.matches(pendingIntent1) = true
actual: alarm1.matches(pendingIntent1) = false

at android.alarmmanager.cts.BasicApiTests.testAlarmMatches(BasicApiTests.java:389)
```

## 現象描述
設定鬧鐘後，使用相同的 PendingIntent 呼叫 matches() 檢查，
但 matches() 返回 false，導致無法正確識別和取消鬧鐘。

## 提示
- 問題出在 `Alarm.java` 的 `matches()` 方法
- PendingIntent 比較應該使用 filterEquals()
- 檢查比較邏輯是否正確

## 選項
A. `matches()` 使用 `==` 比較 PendingIntent 而非 `filterEquals()`

B. `matches()` 比較前沒有檢查 null，導致 NPE 被捕獲後返回 false

C. `matches()` 的返回值被意外取反

D. `matches()` 在比較時錯誤地使用了 operation.getCreatorPackage()
