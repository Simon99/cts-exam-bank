# Q006: RTC to ELAPSED Conversion Wrong

## CTS Test
`android.alarmmanager.cts.TimeChangeTests#testRtcToElapsedConversion`

## Failure Log
```
junit.framework.AssertionFailedError: Alarm trigger time miscalculated after time change
expected: alarm adjusted for time change
actual: alarm trigger time shifted by wallclock delta

at android.alarmmanager.cts.TimeChangeTests.testRtcToElapsedConversion(TimeChangeTests.java:134)
```

## 現象描述
設定 RTC 類型鬧鐘後，系統時間發生變更（例如 NTP 同步），
ELAPSED_REALTIME 類型的鬧鐘工作正常，但 RTC 鬧鐘的觸發時間計算出錯。
可能導致鬧鐘提前或延後觸發。

## 提示
- 問題出在 `convertToElapsed()` 方法
- RTC 時間需要減去當前 wall clock 然後加上 elapsed time
- 檢查時間轉換的計算公式

## 選項
A. `convertToElapsed()` 計算時使用加法而非減法（或相反）

B. `convertToElapsed()` 沒有區分 RTC 和 ELAPSED_REALTIME 類型

C. `convertToElapsed()` 使用了錯誤的系統時間源

D. `convertToElapsed()` 在計算後沒有處理負數結果
