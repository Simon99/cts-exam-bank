# Q008: UpdateNextAlarmClock Not Triggered

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testNextAlarmClockBroadcast`

## Failure Log
```
junit.framework.AssertionFailedError: ACTION_NEXT_ALARM_CLOCK_CHANGED not received
expected: broadcast after setAlarmClock
actual: no broadcast received within timeout

at android.alarmmanager.cts.BasicApiTests.testNextAlarmClockBroadcast(BasicApiTests.java:456)
```

## 現象描述
呼叫 `setAlarmClock()` 設定新鬧鐘後，
系統應該發送 `ACTION_NEXT_ALARM_CLOCK_CHANGED` 廣播通知其他 app。
但測試中沒有收到此廣播，導致 widget 和其他 app 無法更新顯示。

## 提示
- 問題出在 `updateNextAlarmClockLocked()` 方法
- 設定鬧鐘後需要檢查是否需要更新 next alarm clock
- 檢查更新的觸發條件

## 選項
A. `updateNextAlarmClockLocked()` 的比較邏輯使用 `>` 而非 `<`

B. `updateNextAlarmClockLocked()` 沒有在設定新 alarm clock 後被呼叫

C. `updateNextAlarmClockLocked()` 發送廣播時使用了錯誤的 Intent action

D. `updateNextAlarmClockLocked()` 只在移除鬧鐘時更新，設定時不更新
