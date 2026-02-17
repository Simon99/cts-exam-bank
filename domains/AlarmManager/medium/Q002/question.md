# Q002: setWindow Ignores Window Length

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testSetWindow`

## Failure Log
```
junit.framework.AssertionFailedError: Alarm fired outside specified window
expected: alarm to fire within window [triggerTime, triggerTime + windowLength]
actual: alarm fired exactly at triggerTime (ignored window)

at android.alarmmanager.cts.BasicApiTests.testSetWindow(BasicApiTests.java:223)
```

## 現象描述
使用 `setWindow()` 設定鬧鐘，指定 5 分鐘的彈性窗口。
期望鬧鐘在窗口內任意時間觸發（允許 batching），
但鬧鐘總是在 triggerTime 精確觸發，忽略了 windowLength 參數。

## 提示
- 問題出在 `setWindow()` 傳遞給 `setImpl()` 的參數
- window 相關參數的傳遞順序很重要
- 檢查 windowStartMillis 和 windowLengthMillis 的使用

## 選項
A. `setWindow()` 將 windowLengthMillis 傳遞到錯誤的參數位置

B. `setWindow()` 內部將 windowLengthMillis 轉換成 WINDOW_EXACT

C. `setWindow()` 沒有驗證 windowLengthMillis > 0

D. `setWindow()` 中 windowStartMillis 和 windowLengthMillis 參數互換了
