# Q005: flushImpl Deadlock Under Heavy Load

## CTS Test
`android.hardware.cts.SensorBatchingFifoTest#testFlushUnderLoad`

## Failure Log
```
TIMEOUT: Test did not complete within 60 seconds
Thread dump shows deadlock:

Thread-1 (flush caller):
  waiting for lock: SystemSensorManager.mSensorListeners
  holding lock: SensorEventQueue.mLock

Thread-2 (event dispatcher):
  waiting for lock: SensorEventQueue.mLock
  holding lock: SystemSensorManager.mSensorListeners

Test was performing concurrent sensor reads and flush calls

at android.hardware.cts.SensorBatchingFifoTest.testFlushUnderLoad(timeout)
```

## 現象描述
在高負載情況下（同時讀取感測器和呼叫 flush），系統發生死鎖。
Thread dump 顯示兩個執行緒互相等待對方持有的鎖。

## 提示
- 死鎖需要循環等待條件
- flush 和 event dispatch 使用不同的鎖順序
- 問題在於鎖的取得順序不一致
- 需要統一所有路徑的鎖順序
