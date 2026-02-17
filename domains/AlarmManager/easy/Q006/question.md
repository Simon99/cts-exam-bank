# Q006: AlarmClockInfo getTriggerTime Returns 0

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testAlarmClockInfo`

## Failure Log
```
junit.framework.AssertionFailedError: AlarmClockInfo trigger time is wrong
expected:<1703750400000> but was:<0>

at android.alarmmanager.cts.BasicApiTests.testAlarmClockInfo(BasicApiTests.java:478)
```

## 現象描述
建立 `AlarmClockInfo` 物件並設定觸發時間，但呼叫 `getTriggerTime()` 返回 0。
測試設定時間為明天早上 8:00，但 getter 返回值為 0。

## 提示
- 問題出在 `AlarmClockInfo` 類別的 getter 方法
- 這是一個簡單的欄位返回錯誤
- 檢查 `getTriggerTime()` 返回的是哪個欄位

## 選項
A. `getTriggerTime()` 返回的是未初始化的局部變數而非成員變數

B. `getTriggerTime()` 錯誤地返回了 0 而非 mTriggerTime 欄位

C. `AlarmClockInfo` 建構子沒有正確設定 mTriggerTime 欄位

D. `getTriggerTime()` 在 Parcel 反序列化時讀取順序錯誤
