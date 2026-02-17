# Q002: registerListenerImpl Race Condition Causes Duplicate Events

## CTS Test
`android.hardware.cts.SensorTest#testListenerDuplicateEvents`

## Failure Log
```
junit.framework.AssertionFailedError: Received duplicate sensor events
Expected: unique timestamps for each event
Actual: found 15 pairs of events with identical timestamps

Sensor: Accelerometer
Rate: SENSOR_DELAY_FASTEST
Duration: 10 seconds

Duplicate events suggest listener registered twice internally

at android.hardware.cts.SensorTest.testListenerDuplicateEvents(SensorTest.java:512)
```

## 現象描述
使用同一個 listener 多次呼叫 registerListener 時，
雖然 API 文檔說會自動更新而非重複註冊，但實際收到重複的事件，
表示 listener 被內部註冊了多次。

## 提示
- registerListenerImpl 應該先檢查是否已註冊
- 如果已註冊，應該更新參數而非新增
- 問題可能在於已註冊檢查的同步或邏輯
- 考慮 ConcurrentHashMap 的 putIfAbsent 行為
