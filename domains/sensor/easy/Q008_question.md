# Q008: getResolution Returns Zero

## CTS Test
`android.hardware.cts.SensorParameterRangeTest#testResolution`

## Failure Log
```
junit.framework.AssertionFailedError: getResolution() must return 
positive value for accelerometer
expected: > 0 but was: 0.0

Sensor: Accelerometer
Device spec shows resolution should be 0.0012 m/s²

at android.hardware.cts.SensorParameterRangeTest.testResolution(SensorParameterRangeTest.java:112)
```

## 現象描述
`Sensor.getResolution()` 對於加速度感測器返回 0.0，
但感測器應該有正的解析度值。

## 提示
- 解析度值在建構時從 native 層傳入
- 問題可能在於欄位未正確初始化
- 檢查 mResolution 的賦值
