# Q003: rebatchAllAlarmsLocked Lost Alarms

## CTS Test
`android.alarmmanager.cts.TimeChangeTests#testRebatchAfterTimeChange`

## Failure Log
```
junit.framework.AssertionFailedError: Alarms lost after time zone change
expected: 5 alarms remaining after rebatch
actual: 3 alarms remaining

at android.alarmmanager.cts.TimeChangeTests.testRebatchAfterTimeChange(TimeChangeTests.java:256)
```

## 現象描述
系統時區變更後，AlarmManager 重新批次排列所有鬧鐘。
但重新排列後，有些鬧鐘消失了。原本設定的 5 個鬧鐘只剩 3 個。

## 提示
- 問題出在 `rebatchAllAlarmsLocked()` 的邏輯
- 重新批次時需要保留所有鬧鐘
- 檢查從舊 batch 轉移到新 batch 的過程

## 選項
A. `rebatchAllAlarmsLocked()` 在清空舊 batch 前沒有複製所有鬧鐘

B. `rebatchAllAlarmsLocked()` 使用 `>` 而非 `>=` 導致邊界鬧鐘遺失

C. `rebatchAllAlarmsLocked()` 在處理重複鬧鐘時跳過了部分項目

D. `rebatchAllAlarmsLocked()` 的新 batch 容量計算錯誤
