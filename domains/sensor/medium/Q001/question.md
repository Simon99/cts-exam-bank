# Q001: Sensor Batching Not Honoring maxReportLatencyUs

## CTS Test
`android.hardware.cts.SensorBatchingTests#testBatchingLatency`

## Failure Log
```
junit.framework.AssertionFailedError: Sensor events delivered too frequently,
batching latency not honored
maxReportLatencyUs: 5000000 (5 seconds)
Actual delivery interval: 200000 μs (200 ms)

Sensor: Accelerometer
Batching should delay delivery by up to 5 seconds

at android.hardware.cts.SensorBatchingTests.testBatchingLatency(SensorBatchingTests.java:156)
```

## 現象描述
註冊感測器時指定了 5 秒的 maxReportLatencyUs，
但事件仍以接近 samplingPeriod 的頻率送達，完全沒有批次延遲。

## 提示
- registerListener 有多個 overload 版本
- maxReportLatencyUs 參數需要傳遞到底層
- 問題可能在於參數轉換或傳遞邏輯
- 檢查 4 參數版本的 registerListener
