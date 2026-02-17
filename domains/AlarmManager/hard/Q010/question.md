# Q010: Battery Saver Exact Alarm Handling

## CTS Test
`android.alarmmanager.cts.BackgroundRestrictedAlarmsTest#testBatterySaverExactAlarm`

## Failure Log
```
junit.framework.AssertionFailedError: Exact alarm behavior wrong in battery saver
expected: setExact alarm to fire exactly (exempt from battery saver)
actual: setExact alarm was deferred like inexact alarm

Stack trace shows alarm was adjusted by adjustDeliveryTimeBasedOnBatterySaver()
```

## 現象描述
電池節省模式下，`setExact()` 設定的精確鬧鐘應該豁免於電池優化。
但測試中精確鬧鐘被延遲了，行為與普通 `set()` 相同。

## 提示
- 問題出在 `adjustDeliveryTimeBasedOnBatterySaver()` 的豁免檢查
- 精確鬧鐘在電池節省模式下有不同處理
- 檢查 isExact() 判斷在調整邏輯中的位置

## 選項
A. `adjustDeliveryTimeBasedOnBatterySaver()` 檢查 isExact() 的條件邏輯錯誤

B. `adjustDeliveryTimeBasedOnBatterySaver()` 在檢查 isExact() 前就已經調整了時間

C. isExact() 在 battery saver 情境下返回錯誤值

D. 電池節省模式的開關狀態檢查錯誤
