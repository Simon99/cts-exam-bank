# Q006: rescheduleKernelAlarmsLocked Missed Wakeup

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testKernelAlarmReschedule`

## Failure Log
```
junit.framework.AssertionFailedError: Device did not wake for scheduled alarm
expected: device wakeup at scheduled time
actual: device remained asleep, alarm fired 15 minutes late on manual wake

at android.alarmmanager.cts.BasicApiTests.testKernelAlarmReschedule(BasicApiTests.java:623)
```

## 現象描述
設定 wakeup 類型鬧鐘後，裝置在預定時間沒有喚醒。
鬧鐘延遲到手動喚醒裝置後才觸發。這發生在設定多個鬧鐘後取消第一個鬧鐘的場景。

## 提示
- 問題出在 `rescheduleKernelAlarmsLocked()` 的邏輯
- 取消鬧鐘後需要重新排程 kernel alarm
- 檢查尋找下一個 wakeup alarm 的邏輯

## 選項
A. `rescheduleKernelAlarmsLocked()` 沒有在取消鬧鐘後被呼叫

B. `rescheduleKernelAlarmsLocked()` 只考慮第一個 batch，忽略了其他 batch 的 wakeup alarm

C. `rescheduleKernelAlarmsLocked()` 設定 kernel alarm 時使用了錯誤的時間戳

D. `rescheduleKernelAlarmsLocked()` 沒有區分 wakeup 和 non-wakeup 鬧鐘
