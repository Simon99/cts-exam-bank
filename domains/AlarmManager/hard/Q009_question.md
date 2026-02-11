# Q009: setTimeZoneImpl Alarms Not Adjusted

## CTS Test
`android.alarmmanager.cts.TimeChangeTests#testTimeZoneChange`

## Failure Log
```
junit.framework.AssertionFailedError: RTC alarms not adjusted after timezone change
expected: alarms adjusted for +8 hours timezone shift
actual: alarms still at original UTC-relative times

at android.alarmmanager.cts.TimeChangeTests.testTimeZoneChange(TimeChangeTests.java:189)
```

## 現象描述
時區從 UTC 變更為 UTC+8 後，RTC 類型的鬧鐘應該自動調整。
例如原本設定在「當地時間 8:00」的鬧鐘，時區變更後仍應在「新時區的 8:00」觸發。
但實際上鬧鐘沒有調整，導致在錯誤的當地時間觸發。

## 提示
- 問題出在 `setTimeZoneImpl()` 的處理流程
- 時區變更後需要重新計算 RTC 鬧鐘的觸發時間
- 檢查是否正確呼叫了重新計算的方法

## 選項
A. `setTimeZoneImpl()` 沒有呼叫 `rebatchAllAlarmsLocked()` 重新計算

B. `setTimeZoneImpl()` 使用了舊的時區 offset 進行計算

C. `setTimeZoneImpl()` 只處理了 RTC 類型，忽略了 RTC_WAKEUP

D. `setTimeZoneImpl()` 在 rebatch 時過濾掉了 RTC 類型鬧鐘
