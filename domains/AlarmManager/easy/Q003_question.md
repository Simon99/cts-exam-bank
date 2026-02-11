# Q003: setExact Alarm Treated as Inexact

## CTS Test
`android.alarmmanager.cts.ExactAlarmsTest#testSetExact`

## Failure Log
```
junit.framework.AssertionFailedError: Exact alarm fired outside acceptable window
expected: alarm to fire within 100ms of scheduled time
actual: alarm fired 3247ms late

at android.alarmmanager.cts.ExactAlarmsTest.testSetExact(ExactAlarmsTest.java:156)
```

## 現象描述
使用 `AlarmManager.setExact()` 設定精確鬧鐘，但鬧鐘沒有在精確時間觸發，
而是像普通 `set()` 一樣有延遲。App 已獲得 SCHEDULE_EXACT_ALARM 權限。

## 提示
- 問題出在 `setExact()` 方法的 window 長度設定
- 精確鬧鐘的 window 長度應該為 0
- 檢查 `setExact()` 呼叫 `setImpl()` 時傳入的參數

## 選項
A. `setExact()` 傳入的 window 長度為 `WINDOW_EXACT` 而非 0

B. `setExact()` 傳入的 window 長度使用了 `legacyExactLength()` 而非 0

C. `setExact()` 沒有正確設定 FLAG_STANDALONE 標記

D. `setExact()` 的 type 參數被錯誤轉換導致降級為 inexact
