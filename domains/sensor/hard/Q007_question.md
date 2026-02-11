# Q007: requestTriggerSensorImpl Doesn't Prevent Double Registration

## CTS Test
`android.hardware.cts.SensorTest#testTriggerSensorDoubleRequest`

## Failure Log
```
junit.framework.AssertionFailedError: onTrigger() called multiple times
for same event

Significant motion detected once, but callback fired 3 times
Test called requestTriggerSensor 3 times with same listener before motion

Expected: API should prevent or handle duplicate requests

at android.hardware.cts.SensorTest.testTriggerSensorDoubleRequest(SensorTest.java:445)
```

## 現象描述
對同一個 listener 多次呼叫 `requestTriggerSensor()` 後，
當 trigger 事件發生時，`onTrigger()` 被呼叫多次。
Trigger 感測器應該是一次性的，且重複請求應該被處理。

## 提示
- Trigger sensor 的 listener 應該只註冊一次
- 重複請求應該更新而非疊加
- 問題在於 listener 的追蹤和去重邏輯
