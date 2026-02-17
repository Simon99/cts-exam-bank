# Q003: getDefaultSensor Returns Wrong Type

## CTS Test
`android.hardware.cts.SensorTest#testGetDefaultSensor`

## Failure Log
```
junit.framework.AssertionFailedError: getDefaultSensor(TYPE_GYROSCOPE) 
returned sensor with wrong type
expected: TYPE_GYROSCOPE (4) but was: TYPE_ACCELEROMETER (1)

at android.hardware.cts.SensorTest.testGetDefaultSensor(SensorTest.java:89)
```

## 現象描述
呼叫 `getDefaultSensor(Sensor.TYPE_GYROSCOPE)` 卻返回了加速度感測器，
而非預期的陀螺儀。

## 提示
- getDefaultSensor 需要遍歷感測器列表
- 問題可能在於 type 比較的邏輯
- 檢查過濾條件中的感測器類型匹配
