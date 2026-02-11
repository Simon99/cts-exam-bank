# Q003: getDefaultSensor with wakeUp Flag Ignored

## CTS Test
`android.hardware.cts.SensorTest#testGetDefaultSensorWakeUp`

## Failure Log
```
junit.framework.AssertionFailedError: getDefaultSensor(TYPE_ACCELEROMETER, true)
should return wake-up accelerometer but returned non-wake-up sensor
expected: isWakeUpSensor()=true but was: false

Device has both wake-up and non-wake-up accelerometers

at android.hardware.cts.SensorTest.testGetDefaultSensorWakeUp(SensorTest.java:124)
```

## 現象描述
呼叫 `getDefaultSensor(TYPE_ACCELEROMETER, true)` 指定要 wake-up 感測器，
但返回的是 non-wake-up 版本。設備同時有兩種版本的加速度計。

## 提示
- getDefaultSensor(int, boolean) 有 wakeUp 參數
- 需要同時匹配 type 和 wake-up 屬性
- 問題可能在於過濾條件的 AND/OR 邏輯
