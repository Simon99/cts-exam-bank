# Q001: Direct Channel Configuration Causes Crash

## CTS Test
`android.hardware.cts.SensorDirectReportTest#testDirectChannelConfigure`

## Failure Log
```
FATAL EXCEPTION: main
Process: android.hardware.cts, PID: 15678

java.lang.IllegalStateException: Direct channel not in valid state for configure
    at android.hardware.SensorDirectChannel.configure(SensorDirectChannel.java:156)
    at android.hardware.cts.SensorDirectReportTest.testDirectChannelConfigure(SensorDirectReportTest.java:234)

Channel state: CONFIGURED (expected: OPEN or STOPPED)
Attempted to start second sensor on same channel

Backtrace shows configure() rejecting valid state transitions
```

## 現象描述
對已經配置過一個感測器的 Direct Channel 嘗試配置第二個感測器時崩潰。
Direct Channel 應該可以同時配置多個感測器，但狀態檢查阻止了這個操作。

## 提示
- Direct Channel 可同時配置多個感測器
- 配置第二個感測器不應該改變 channel 狀態
- 問題在於狀態機的轉換邏輯
- 檢查 configure() 中的狀態驗證條件
