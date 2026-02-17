# Q007: getReportingMode Returns Incorrect Mode

## CTS Test
`android.hardware.cts.SensorTest#testReportingMode`

## Failure Log
```
junit.framework.AssertionFailedError: getReportingMode() returned wrong value
Sensor: Proximity Sensor
expected: REPORTING_MODE_ON_CHANGE (1) but was: REPORTING_MODE_CONTINUOUS (0)

Proximity sensor should be on-change, not continuous

at android.hardware.cts.SensorTest.testReportingMode(SensorTest.java:298)
```

## 現象描述
接近感測器的 `getReportingMode()` 返回 `REPORTING_MODE_CONTINUOUS`，
但接近感測器應該是 `REPORTING_MODE_ON_CHANGE`。

## 提示
- Reporting mode 儲存在 mFlags 中
- 需要用位元遮罩取出正確的位元
- mode 佔用 flags 的 bit 1-2
