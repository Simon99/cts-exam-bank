# Q008: unregisterListenerImpl Fails to Stop HAL When Removing Last Sensor

## CTS Test
`android.hardware.cts.SensorTest#testUnregisterStopsHal`

## Failure Log
```
junit.framework.AssertionFailedError: After unregisterListener, sensor
should not produce events

Timeline:
- registerListener(accelerometer) -> OK
- registerListener(gyroscope) -> OK (same listener)
- unregisterListener(listener, accelerometer) -> OK
- unregisterListener(listener, gyroscope) -> OK
- Wait 5 seconds -> Still receiving gyroscope events!

HAL was not stopped when last sensor was removed from listener

at android.hardware.cts.SensorTest.testUnregisterStopsHal(SensorTest.java:234)
```

## 現象描述
當 listener 註冊了多個感測器，逐一取消註冊後，
最後一個感測器取消時 HAL 沒有被正確停止，仍然繼續產生事件。

## 提示
- unregisterListener(listener, sensor) 移除特定感測器
- 當 listener 的最後一個感測器被移除時，需要完全清理
- 問題可能在於判斷「是否為最後一個」的邏輯
