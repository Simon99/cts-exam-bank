# Q009: isDirectChannelTypeSupported Always Returns False

## CTS Test
`android.hardware.cts.SensorDirectReportTest#testDirectChannelTypeSupport`

## Failure Log
```
junit.framework.AssertionFailedError: isDirectChannelTypeSupported should 
return true for supported channel types
Sensor: Accelerometer
TYPE_MEMORY_FILE: expected=true, actual=false
TYPE_HARDWARE_BUFFER: expected=true, actual=false

HAL reports direct channel support for both types

at android.hardware.cts.SensorDirectReportTest.testDirectChannelTypeSupport(SensorDirectReportTest.java:112)
```

## 現象描述
`Sensor.isDirectChannelTypeSupported()` 對於所有 channel type 都返回 false，
即使 HAL 回報該感測器支援 direct channel。

## 提示
- Direct channel 支援儲存在 sensor flags
- 需要檢查特定的 flag 位元
- 問題可能在於 flag 檢查邏輯
