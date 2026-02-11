# Q010: Sensor Accuracy Callback Invoked with Wrong Sensor

## CTS Test
`android.hardware.cts.SensorTest#testOnAccuracyChanged`

## Failure Log
```
junit.framework.AssertionFailedError: onAccuracyChanged called with wrong sensor

Registered: Accelerometer + Gyroscope
Gyroscope accuracy changed to SENSOR_STATUS_ACCURACY_HIGH

onAccuracyChanged received:
  - sensor: Accelerometer (should be Gyroscope)
  - accuracy: SENSOR_STATUS_ACCURACY_HIGH

Callback received correct accuracy but wrong sensor object

at android.hardware.cts.SensorTest.testOnAccuracyChanged(SensorTest.java:623)
```

## 現象描述
當 Gyroscope 的精確度改變時，`onAccuracyChanged` 回調收到了正確的
精確度值，但傳入的 Sensor 物件卻是 Accelerometer 而非 Gyroscope。

## 提示
- 一個 listener 可監聽多個感測器
- 需要用 sensor handle 找到正確的 Sensor 物件
- 問題可能在於 handle 到 Sensor 的映射邏輯
