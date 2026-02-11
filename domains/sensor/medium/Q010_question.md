# Q010: SensorEvent Timestamp Off by Factor of 1000

## CTS Test
`android.hardware.cts.SensorIntegrationTests#testTimestamp`

## Failure Log
```
junit.framework.AssertionFailedError: SensorEvent timestamp appears to be
in wrong unit
expected: nanoseconds (System.nanoTime() order of magnitude)
actual: appears to be microseconds

First event timestamp: 1234567890123
System.nanoTime(): 1234567890123456789
Ratio suggests timestamp is 1000x smaller than expected

at android.hardware.cts.SensorIntegrationTests.testTimestamp(SensorIntegrationTests.java:178)
```

## 現象描述
`SensorEvent.timestamp` 的值比預期小約 1000 倍。
API 文件說 timestamp 應該是奈秒，但實際值看起來像微秒。

## 提示
- timestamp 應該與 System.nanoTime() 同等級
- HAL 傳入的是奈秒
- 問題可能在於 timestamp 的處理或轉換
