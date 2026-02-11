# Q006: Sensor.getType() Returns Wrong Value

## CTS Test
`android.hardware.cts.SensorTest#testSensorType`

## Failure Log
```
junit.framework.AssertionFailedError: Sensor type mismatch
expected: TYPE_ACCELEROMETER (1) but was: TYPE_MAGNETIC_FIELD (2)

Sensor name: LSM6DSO Accelerometer

at android.hardware.cts.SensorTest.testSensorType(SensorTest.java:145)
```

## 現象描述
加速度感測器的 `getType()` 返回了錯誤的類型值。
明明是加速度感測器，卻返回磁力計的類型常數。

## 提示
- 感測器類型在建構時由 HAL 設定
- 問題可能在於類型欄位的賦值
- 檢查 Sensor 建構函數中的欄位初始化順序
