# Q007: getMaximumRange Returns Negative Value

## CTS Test
`android.hardware.cts.SensorParameterRangeTest#testMaximumRange`

## Failure Log
```
junit.framework.AssertionFailedError: getMaximumRange() must return 
non-negative value
expected: >= 0 but was: -39.2266

Sensor: Accelerometer
Actual range should be: 39.2266 m/s²

at android.hardware.cts.SensorParameterRangeTest.testMaximumRange(SensorParameterRangeTest.java:98)
```

## 現象描述
`Sensor.getMaximumRange()` 返回負值，但感測器範圍必須是正值。
返回的值正好是正確值的負數。

## 提示
- 範圍值從 HAL 取得並儲存在 mMaxRange
- 問題是簡單的符號錯誤
- 檢查 maxRange 的儲存或返回邏輯
