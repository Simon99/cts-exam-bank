# Q001: Repeating Alarm Interval Too Short

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testSetRepeating`

## Failure Log
```
junit.framework.AssertionFailedError: Repeating alarm interval not enforced
expected: minimum interval of 60000ms
actual: alarm scheduled with interval 30000ms

at android.alarmmanager.cts.BasicApiTests.testSetRepeating(BasicApiTests.java:178)
```

## 現象描述
使用 `setRepeating()` 設定重複鬧鐘時，傳入 30 秒的 interval。
系統應該自動強制最小 interval 為 60 秒，但實際上接受了 30 秒。
這可能導致電池過度消耗。

## 提示
- 問題出在 `setRepeating()` 或 `setImpl()` 的 interval 處理
- 有一個 `INTERVAL_MINIMUM` 常數定義最小間隔
- 檢查 interval 的邊界處理邏輯

## 選項
A. `setRepeating()` 中 interval 與 `INTERVAL_MINIMUM` 比較時使用 `<` 而非 `<=`

B. `setRepeating()` 傳遞給 setImpl 時沒有使用 `Math.max(interval, INTERVAL_MINIMUM)`

C. `INTERVAL_MINIMUM` 常數值被錯誤定義為毫秒而非秒

D. `setRepeating()` 沒有區分 WAKEUP 和 non-WAKEUP 類型的最小 interval
