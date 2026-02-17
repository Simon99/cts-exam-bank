# Q005: deliverAlarmsLocked Exception Handling

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testAlarmDeliveryRecovery`

## Failure Log
```
junit.framework.AssertionFailedError: Subsequent alarms not delivered after one fails
expected: all 5 alarms delivered (one may fail)
actual: only first 2 alarms delivered, remaining 3 skipped

at android.alarmmanager.cts.BasicApiTests.testAlarmDeliveryRecovery(BasicApiTests.java:567)
```

## 現象描述
5 個鬧鐘同時到期，第 3 個鬧鐘的 PendingIntent 已被取消（會拋出異常）。
正常情況下應該跳過第 3 個，繼續傳遞第 4、5 個。但實際上只傳遞了 1、2，
第 3 個失敗後，第 4、5 個都被跳過。

## 提示
- 問題出在 `deliverAlarmsLocked()` 的異常處理
- 單一鬧鐘失敗不應影響其他鬧鐘
- 檢查 try-catch 的範圍

## 選項
A. try-catch 區塊範圍過大，包含了整個迴圈而非單一鬧鐘

B. catch 區塊使用了 break 而非 continue

C. 異常處理中錯誤地清空了剩餘鬧鐘列表

D. 異常處理後沒有重置迭代器狀態
