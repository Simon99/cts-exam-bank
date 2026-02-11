# Q009: cancelTriggerSensor Returns False for Valid Request

## CTS Test
`android.hardware.cts.SensorTest#testCancelTriggerSensor`

## Failure Log
```
junit.framework.AssertionFailedError: cancelTriggerSensor should return true
for previously registered trigger request
expected: true but was: false

Sensor: Significant Motion Detector
Listener was successfully registered before cancel attempt

at android.hardware.cts.SensorTest.testCancelTriggerSensor(SensorTest.java:428)
```

## 現象描述
成功註冊 trigger sensor 後，呼叫 `cancelTriggerSensor()` 取消應該返回 true，
但實際返回 false。

## 提示
- cancelTriggerSensor 檢查 listener 是否已註冊
- 問題在於返回值的布林邏輯
- 檢查成功/失敗的判斷條件
