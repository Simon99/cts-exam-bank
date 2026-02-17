# Q009: Alarm Wakeup Type Ignored

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testWakeupAlarm`

## Failure Log
```
junit.framework.AssertionFailedError: Wakeup alarm did not wake device from sleep
expected: device to wake up and fire alarm
actual: alarm only fired after manual wake

at android.alarmmanager.cts.BasicApiTests.testWakeupAlarm(BasicApiTests.java:312)
```

## 現象描述
使用 `ELAPSED_REALTIME_WAKEUP` 或 `RTC_WAKEUP` 類型設定鬧鐘，
裝置在休眠時沒有被喚醒，鬧鐘延遲到手動喚醒後才觸發。

## 提示
- 問題出在 `Alarm.java` 的 wakeup 類型判斷
- WAKEUP 類型的 type 值是奇數
- 檢查 wakeup 判斷的位元運算

## 選項
A. wakeup 判斷使用 `(type & 0x1) == 0` 而非 `(type & 0x1) != 0`

B. wakeup 判斷檢查的是 `type == RTC_WAKEUP` 但漏了 ELAPSED_REALTIME_WAKEUP

C. wakeup flag 在傳遞給 kernel 時被意外清除

D. wakeup 類型的常數值定義與 kernel 期望的不符
