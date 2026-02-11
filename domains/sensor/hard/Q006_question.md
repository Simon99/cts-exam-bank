# Q006: configureDirectChannel Allows Invalid Rate After Channel Stop

## CTS Test
`android.hardware.cts.SensorDirectReportTest#testConfigureAfterStop`

## Failure Log
```
junit.framework.AssertionFailedError: configureDirectChannel should validate
rate level against sensor capabilities after stop/restart cycle

Test sequence:
1. configure(sensor, RATE_FAST) -> OK
2. configure(sensor, RATE_STOP) -> OK (stopped)
3. configure(sensor, RATE_VERY_FAST) -> Should fail but returned OK

Sensor only supports up to RATE_FAST
After stop, rate validation was bypassed

at android.hardware.cts.SensorDirectReportTest.testConfigureAfterStop(SensorDirectReportTest.java:267)
```

## 現象描述
Direct Channel 停止後重新配置時，跳過了 rate level 的驗證。
感測器只支援 RATE_FAST，但停止後可以用 RATE_VERY_FAST 配置成功。

## 提示
- configure 有多個執行路徑：首次配置、更新、停止後重配
- rate level 驗證可能只在某些路徑執行
- 問題在於停止後重配的路徑缺少驗證
