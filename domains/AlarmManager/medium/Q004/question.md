# Q004: canScheduleExactAlarms Returns Wrong Result

## CTS Test
`android.alarmmanager.cts.ExactAlarmsTest#testCanScheduleExactAlarms`

## Failure Log
```
junit.framework.AssertionFailedError: canScheduleExactAlarms returned wrong value
expected: true (app has SCHEDULE_EXACT_ALARM permission)
actual: false

at android.alarmmanager.cts.ExactAlarmsTest.testCanScheduleExactAlarms(ExactAlarmsTest.java:89)
```

## 現象描述
App 已在 manifest 宣告 `SCHEDULE_EXACT_ALARM` 權限，
用戶也已在設定中授予權限，但 `canScheduleExactAlarms()` 返回 false。
導致 app 無法使用 setExact() 類 API。

## 提示
- 問題出在 `canScheduleExactAlarms()` 的實作
- 檢查權限檢查的邏輯
- 可能是返回值的處理問題

## 選項
A. `canScheduleExactAlarms()` 沒有捕獲 RemoteException 導致返回 false

B. `canScheduleExactAlarms()` 的返回值被意外取反

C. `canScheduleExactAlarms()` 檢查的是 USE_EXACT_ALARM 而非 SCHEDULE_EXACT_ALARM

D. `canScheduleExactAlarms()` 呼叫 service 時傳入了錯誤的 packageName
