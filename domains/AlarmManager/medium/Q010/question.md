# Q010: Exact Alarm Permission Check Bypassed

## CTS Test
`android.alarmmanager.cts.ExactAlarmsTest#testExactAlarmPermissionRequired`

## Failure Log
```
java.lang.SecurityException not thrown
expected: SecurityException when setting exact alarm without permission
actual: alarm was set successfully

at android.alarmmanager.cts.ExactAlarmsTest.testExactAlarmPermissionRequired(ExactAlarmsTest.java:112)
```

## 現象描述
App 沒有 `SCHEDULE_EXACT_ALARM` 權限，但仍然可以成功呼叫 `setExact()`。
系統沒有拋出 SecurityException，違反了 API 31+ 的權限要求。

## 提示
- 問題出在 `AlarmManagerService` 的權限檢查
- `hasScheduleExactAlarmInternal()` 用於檢查權限
- 檢查 setImpl 中呼叫權限檢查的邏輯

## 選項
A. 權限檢查的結果被忽略，沒有在失敗時拋出例外

B. 權限檢查只在 DEBUG build 啟用

C. 權限檢查的 targetSdk 版本判斷使用了錯誤的 API level

D. 權限檢查方法本身有 bug，總是返回 true
