# Q002: flush() Returns True But Events Never Arrive

## CTS Test
`android.hardware.cts.SensorBatchingFifoTest#testFlush`

## Failure Log
```
junit.framework.AssertionFailedError: flush() returned true but 
onFlushCompleted() was never called
Timeout waiting for flush complete callback: 10 seconds

Sensor: Accelerometer with batching enabled
FIFO: reserved=300, max=600 events

at android.hardware.cts.SensorBatchingFifoTest.testFlush(SensorBatchingFifoTest.java:203)
```

## 現象描述
`SensorManager.flush()` 返回 true 表示成功，
但 `SensorEventListener2.onFlushCompleted()` 回調永遠不會被呼叫。

## 提示
- flush() 需要確認 listener 實作 SensorEventListener2
- 問題可能在於 listener 類型檢查
- 檢查 flush 請求是否正確發送到底層
- 考慮 listener 介面版本的判斷
