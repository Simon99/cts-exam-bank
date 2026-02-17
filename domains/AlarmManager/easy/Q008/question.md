# Q008: Alarm isExact Check Wrong

## CTS Test
`android.alarmmanager.cts.ExactAlarmsTest#testIsExactAlarm`

## Failure Log
```
junit.framework.AssertionFailedError: Alarm.isExact() returned wrong value
expected:<true> but was:<false>

at android.alarmmanager.cts.ExactAlarmsTest.testIsExactAlarm(ExactAlarmsTest.java:234)
```

## 現象描述
透過 `setExact()` 設定的鬧鐘，在 service 內部檢查 `isExact()` 時返回 false。
這導致精確鬧鐘被錯誤地當成普通鬧鐘處理，失去精確觸發特性。

## 提示
- 問題出在 `Alarm.java` 類別的 `isExact()` 方法
- 精確鬧鐘的 windowLength 應該為 0
- 檢查 isExact() 的判斷邏輯

## 選項
A. `isExact()` 判斷條件使用 `windowLength > 0` 而非 `windowLength == 0`

B. `isExact()` 檢查了錯誤的 flag 而非 windowLength

C. `isExact()` 的返回值被意外取反

D. `isExact()` 中的 WINDOW_EXACT 常數值定義錯誤
