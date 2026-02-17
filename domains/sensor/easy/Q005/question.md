# Q005: isWakeUpSensor Always Returns False

## CTS Test
`android.hardware.cts.SensorTest#testIsWakeUpSensor`

## Failure Log
```
junit.framework.AssertionFailedError: Significant Motion sensor should be 
a wake-up sensor
expected: true but was: false

Sensor: Significant Motion Detector
Flags: 0x00000001 (REPORTING_MODE_ONE_SHOT)

at android.hardware.cts.SensorTest.testIsWakeUpSensor(SensorTest.java:312)
```

## 現象描述
`Sensor.isWakeUpSensor()` 對於 Significant Motion Detector 應該返回 true，
因為它是強制的 wake-up 感測器，但實際返回 false。

## 提示
- Wake-up flag 儲存在 sensor flags 中
- 問題在於 flag 位元的遮罩操作
- 檢查 SENSOR_FLAG_WAKE_UP 的定義和使用
