# Q009: Non-Wakeup Delay Check Wrong

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testNonWakeupDelay`

## Failure Log
```
junit.framework.AssertionFailedError: Non-wakeup alarm fired during screen off
expected: alarm deferred until screen on
actual: alarm fired immediately during screen off

at android.alarmmanager.cts.BasicApiTests.testNonWakeupDelay(BasicApiTests.java:523)
```

## 現象描述
使用 `ELAPSED_REALTIME`（非 WAKEUP）類型設定鬧鐘，
螢幕關閉時，鬧鐘應該延遲到螢幕開啟後才觸發。
但測試中鬧鐘在螢幕關閉時立即觸發。

## 提示
- 問題出在 `checkAllowNonWakeupDelayLocked()` 方法
- 螢幕關閉時應該延遲非 wakeup 鬧鐘
- 檢查螢幕狀態的判斷邏輯

## 選項
A. `checkAllowNonWakeupDelayLocked()` 判斷螢幕狀態的變數用反了

B. `checkAllowNonWakeupDelayLocked()` 沒有被正確呼叫

C. `checkAllowNonWakeupDelayLocked()` 返回值的語意與呼叫方期望相反

D. `checkAllowNonWakeupDelayLocked()` 只檢查了 interactive 狀態，沒檢查 display 狀態
