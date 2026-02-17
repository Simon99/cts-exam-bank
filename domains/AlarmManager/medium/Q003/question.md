# Q003: setAndAllowWhileIdle Not Bypassing Doze

## CTS Test
`android.alarmmanager.cts.AppStandbyTests#testSetAndAllowWhileIdle`

## Failure Log
```
junit.framework.AssertionFailedError: Alarm did not fire during device idle
expected: alarm to fire within idle mode
actual: alarm deferred until device exit idle

at android.alarmmanager.cts.AppStandbyTests.testSetAndAllowWhileIdle(AppStandbyTests.java:187)
```

## 現象描述
使用 `setAndAllowWhileIdle()` 設定鬧鐘，期望在 Doze 模式下也能觸發。
但裝置進入 Doze 後，鬧鐘沒有觸發，直到手動喚醒裝置。

## 提示
- 問題出在 `setAndAllowWhileIdle()` 呼叫 `setImpl()` 時的 flag 設定
- FLAG_ALLOW_WHILE_IDLE 是關鍵 flag
- 檢查 flags 參數的傳遞

## 選項
A. `setAndAllowWhileIdle()` 沒有設定 FLAG_ALLOW_WHILE_IDLE flag

B. `setAndAllowWhileIdle()` 誤將 FLAG_ALLOW_WHILE_IDLE 傳到 type 參數

C. `setAndAllowWhileIdle()` 使用了錯誤的 flag 值 (FLAG_STANDALONE)

D. `setAndAllowWhileIdle()` 的 flag 被後續的 security check 清除
