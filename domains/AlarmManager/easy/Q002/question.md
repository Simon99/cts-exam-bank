# Q002: Alarm Cancel Fails for Listener

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testCancelListener`

## Failure Log
```
junit.framework.AssertionFailedError: Alarm fired after cancel was called
expected: alarm should not fire after cancel
actual: alarm callback received

at android.alarmmanager.cts.BasicApiTests.testCancelListener(BasicApiTests.java:298)
```

## 現象描述
使用 `AlarmManager.cancel(listener)` 取消鬧鐘後，鬧鐘仍然觸發。
測試設定一個 5 秒後的鬧鐘，然後立即取消，但仍收到 listener 回調。

## 提示
- 問題出在 `cancel(OnAlarmListener)` 方法中
- 檢查傳遞給 service 的 listener 參數
- cancel 需要正確識別要取消的 listener

## 選項
A. `cancel()` 方法中 listener 的 null 檢查條件寫反了

B. `cancel()` 方法中傳遞給 service 的是 null 而非實際 listener

C. `cancel()` 方法沒有正確獲取 IAlarmManager service

D. `cancel()` 方法的異常處理吞掉了取消失敗的錯誤
