# Q005: getDynamicSensorList Returns Static Sensors

## CTS Test
`android.hardware.cts.SensorTest#testDynamicSensorList`

## Failure Log
```
junit.framework.AssertionFailedError: getDynamicSensorList should only return
dynamic sensors, but returned static sensors
expected: all sensors isDynamicSensor()=true but found: 
  - Accelerometer (dynamic=false)
  - Gyroscope (dynamic=false)

Dynamic USB sensor connected but not in list

at android.hardware.cts.SensorTest.testDynamicSensorList(SensorTest.java:178)
```

## 現象描述
`getDynamicSensorList()` 應該只返回動態連接的感測器（如 USB 感測器），
但實際返回了內建的靜態感測器。

## 提示
- Dynamic sensor 是執行時連接的感測器
- 需要檢查 isDynamicSensor() 過濾
- 問題在於過濾條件的判斷
