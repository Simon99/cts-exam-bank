# Q006 Answer: requestTriggerSensor Works But Doesn't Actually Trigger

## 問題根因
在 `SensorManager.java` 的 `requestTriggerSensor()` 方法中，
將 listener 傳遞給實作層時，誤傳了 null 而非實際的 listener。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorManager.java`

## 修復方式
```java
// 錯誤的代碼
public boolean requestTriggerSensor(TriggerEventListener listener, Sensor sensor) {
    if (listener == null || sensor == null) {
        return false;
    }
    if (sensor.getReportingMode() != Sensor.REPORTING_MODE_ONE_SHOT) {
        return false;
    }
    return requestTriggerSensorImpl(null, sensor);  // BUG: 傳了 null
}

// 正確的代碼
public boolean requestTriggerSensor(TriggerEventListener listener, Sensor sensor) {
    if (listener == null || sensor == null) {
        return false;
    }
    if (sensor.getReportingMode() != Sensor.REPORTING_MODE_ONE_SHOT) {
        return false;
    }
    return requestTriggerSensorImpl(listener, sensor);
}
```

## 相關知識
- Trigger sensor（如 Significant Motion）只觸發一次
- REPORTING_MODE_ONE_SHOT 表示一次性感測器
- listener 必須正確傳遞才能收到回調

## 難度說明
**Medium** - 需要追蹤 listener 參數的傳遞路徑。
