# Q004: getMinDelay Returns Wrong Value

## CTS Test
`android.hardware.cts.SensorTest#testMinDelay`

## Failure Log
```
junit.framework.AssertionFailedError: getMinDelay() value out of expected range
Sensor: Accelerometer (500 Hz capable)
expected: <= 2000 μs but was: 2000000 μs

Sensor spec shows minimum delay should be ~2000 μs for 500 Hz

at android.hardware.cts.SensorTest.testMinDelay(SensorTest.java:267)
```

## 現象描述
`Sensor.getMinDelay()` 返回的值比預期大 1000 倍。
加速度計應該返回約 2000 微秒（500 Hz），但返回 2000000 微秒。

## 提示
- minDelay 從 HAL 以微秒傳入
- 問題可能在於單位轉換
- 檢查 minDelay 的儲存或取得邏輯
- 考慮是否有多餘的乘法運算
