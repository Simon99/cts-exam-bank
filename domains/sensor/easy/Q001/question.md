# Q001: Sensor Registration Returns False Unexpectedly

## CTS Test
`android.hardware.cts.SensorTest#testRegisterListener`

## Failure Log
```
junit.framework.AssertionFailedError: registerListener should return true
for valid sensor but returned false

Sensor: Accelerometer (TYPE_ACCELEROMETER)
Sampling period: SENSOR_DELAY_NORMAL

at android.hardware.cts.SensorTest.testRegisterListener(SensorTest.java:156)
```

## 現象描述
使用 `SensorManager.registerListener()` 註冊有效的加速度感測器時，
返回 false 表示註冊失敗。感測器存在且可用，但註冊始終失敗。

## 提示
- registerListener 接受 samplingPeriodUs 或 delay 常數
- 需要將 delay 常數轉換為實際的微秒數
- 問題在於 delay 常數的判斷條件
- 檢查 SENSOR_DELAY_* 常數的處理邏輯
