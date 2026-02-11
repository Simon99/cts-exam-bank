# Q005: Alarm Cancel with PendingIntent Fails

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testCancelPendingIntent`

## Failure Log
```
junit.framework.AssertionFailedError: Alarm was not cancelled properly
expected: no alarm callback after cancel
actual: received alarm callback

at android.alarmmanager.cts.BasicApiTests.testCancelPendingIntent(BasicApiTests.java:256)
```

## 現象描述
使用 `AlarmManager.cancel(PendingIntent)` 取消鬧鐘，但鬧鐘仍然在預定時間觸發。
測試建立一個 3 秒後的鬧鐘，呼叫 cancel() 取消，但仍收到 broadcast。

## 提示
- 問題出在 `cancel(PendingIntent operation)` 方法
- 檢查傳遞給 service 的參數順序
- cancel 使用 remove() 方法，接受 PendingIntent 或 listener

## 選項
A. `cancel()` 呼叫 service 時參數順序錯誤，將 listener 和 operation 位置互換

B. `cancel()` 沒有檢查 PendingIntent 是否已被 recycle

C. `cancel()` 內部使用了錯誤的 service method 名稱

D. `cancel()` 在呼叫前沒有驗證 mService 是否可用
