# Q009: SensorEvent Values Array Index Out of Bounds

## CTS Test
`android.hardware.cts.SensorTest#testSensorEventValues`

## Failure Log
```
java.lang.ArrayIndexOutOfBoundsException: length=3; index=5
    at android.hardware.SystemSensorManager$SensorEventQueue.dispatchSensorEvent
    (SystemSensorManager.java:467)

Sensor: Rotation Vector (TYPE_ROTATION_VECTOR)
Expected values length: 5 (quaternion + heading accuracy)
Actual array length: 3

Crash occurs when copying values from native to Java

at android.hardware.cts.SensorTest.testSensorEventValues(SensorTest.java:567)
```

## 現象描述
Rotation Vector 感測器的事件處理時發生陣列越界。
此感測器應該有 5 個值（4 個四元數分量 + 1 個航向精確度），
但 SensorEvent 的 values 陣列只分配了 3 個元素。

## 提示
- 不同類型感測器有不同數量的 values
- SensorEvent 建構時需要根據感測器類型分配正確大小
- 問題可能在於 values 陣列大小的決定邏輯
