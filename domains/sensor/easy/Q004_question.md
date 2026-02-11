# Q004: getSensorList Returns Empty List

## CTS Test
`android.hardware.cts.SensorManagerStaticTest#testGetSensorList`

## Failure Log
```
junit.framework.AssertionFailedError: getSensorList(TYPE_ALL) should not 
return empty list on device with sensors
expected: list size > 0 but was: 0

Device has accelerometer, gyroscope, and magnetometer

at android.hardware.cts.SensorManagerStaticTest.testGetSensorList(SensorManagerStaticTest.java:67)
```

## 現象描述
呼叫 `getSensorList(Sensor.TYPE_ALL)` 應該返回所有可用感測器，
但實際返回空列表，即使設備有多個感測器。

## 提示
- TYPE_ALL 是特殊值 -1，代表所有類型
- 問題在於 TYPE_ALL 的特殊處理邏輯
- 檢查當 type 為 -1 時的過濾條件
