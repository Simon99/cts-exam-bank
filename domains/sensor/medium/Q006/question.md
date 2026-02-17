# Q006: requestTriggerSensor Works But Doesn't Actually Trigger

## CTS Test
`android.hardware.cts.SensorTest#testTriggerSensor`

## Failure Log
```
junit.framework.AssertionFailedError: TriggerEventListener.onTrigger() 
was never called despite significant motion occurring

requestTriggerSensor returned: true
Test performed significant motion events
Timeout: 30 seconds

at android.hardware.cts.SensorTest.testTriggerSensor(SensorTest.java:389)
```

## 現象描述
`requestTriggerSensor()` 返回 true，表示請求成功，
但即使實際發生了顯著運動，`onTrigger()` 也不會被呼叫。

## 提示
- Trigger sensor 是一次性的，觸發後自動取消註冊
- requestTriggerSensor 需要正確設定 listener
- 問題可能在於 listener 的儲存或傳遞
