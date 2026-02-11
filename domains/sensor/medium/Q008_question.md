# Q008: getFifoMaxEventCount Returns Reserved Count

## CTS Test
`android.hardware.cts.SensorBatchingFifoTest#testFifoEventCount`

## Failure Log
```
junit.framework.AssertionFailedError: getFifoMaxEventCount should be >= 
getFifoReservedEventCount
Sensor: Accelerometer
getFifoMaxEventCount: 300
getFifoReservedEventCount: 600
Max < Reserved is invalid

at android.hardware.cts.SensorBatchingFifoTest.testFifoEventCount(SensorBatchingFifoTest.java:89)
```

## 現象描述
`getFifoMaxEventCount()` 返回的值小於 `getFifoReservedEventCount()`，
這在邏輯上是不可能的。兩個值似乎被交換了。

## 提示
- FIFO max 是 FIFO 總容量
- FIFO reserved 是此感測器保證的容量
- max >= reserved 必須成立
