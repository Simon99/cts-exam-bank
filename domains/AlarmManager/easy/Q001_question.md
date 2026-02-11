# Q001: Basic Alarm Not Firing

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testSet`

## Failure Log
```
junit.framework.AssertionFailedError: Alarm did not fire within expected window
expected: alarm to fire within 5 seconds
actual: alarm never fired

at android.alarmmanager.cts.BasicApiTests.testSet(BasicApiTests.java:142)
```

## 現象描述
使用 `AlarmManager.set()` 設定基本鬧鐘後，鬧鐘完全沒有觸發。
測試設定了一個 2 秒後觸發的鬧鐘，但等待 5 秒後仍未收到回調。

## 提示
- 此測試使用 `set(type, triggerAtMillis, operation)` 設定基本鬧鐘
- 問題出在 AlarmManager.java 中的 set() 方法
- 檢查 `legacyExactLength` 的呼叫邏輯

## 選項
A. `set()` 方法中 type 參數的 NULL 檢查錯誤，導致鬧鐘被拒絕設定

B. `set()` 方法中 `legacyExactLength()` 呼叫時傳入了錯誤的 type 參數

C. `set()` 方法中 triggerAtMillis 的時間轉換計算錯誤

D. `set()` 方法中 PendingIntent 的 flag 檢查邏輯有誤
