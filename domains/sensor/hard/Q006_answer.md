# Q006 Answer: configureDirectChannel Allows Invalid Rate After Channel Stop

## 問題根因
在 `SystemSensorManager.java` 的 `configureDirectChannelImpl()` 方法中，
rate level 驗證只在 channel 首次配置時執行。當 channel 被停止（RATE_STOP）
後重新配置，走的是 "restart" 路徑，該路徑跳過了 rate level 上限檢查。

## Bug 位置
`frameworks/base/core/java/android/hardware/SystemSensorManager.java`

## 修復方式
```java
// 錯誤的代碼（restart 路徑跳過驗證）
int configureDirectChannelImpl(SensorDirectChannel channel, 
        Sensor sensor, int rateLevel) {
    if (rateLevel == SensorDirectChannel.RATE_STOP) {
        // 停止配置
        return nativeConfigureDirectChannel(channel.mNativeHandle, 
                sensor.getHandle(), rateLevel);
    }
    
    if (channel.mConfiguredSensors.contains(sensor)) {
        // BUG: Restart 路徑，但跳過了 rate level 驗證
        return nativeConfigureDirectChannel(channel.mNativeHandle,
                sensor.getHandle(), rateLevel);
    }
    
    // 首次配置路徑有驗證
    if (rateLevel > sensor.getHighestDirectReportRateLevel()) {
        return -EINVAL;
    }
    // ...
}

// 正確的代碼（所有非 STOP 路徑都驗證）
int configureDirectChannelImpl(...) {
    if (rateLevel != SensorDirectChannel.RATE_STOP) {
        // 統一驗證 rate level
        if (rateLevel > sensor.getHighestDirectReportRateLevel()) {
            return -EINVAL;
        }
    }
    return nativeConfigureDirectChannel(channel.mNativeHandle,
            sensor.getHandle(), rateLevel);
}
```

## 相關知識
- Direct channel configure 有三種操作：start, update rate, stop
- 所有 start/update 操作都應該驗證 rate level
- RATE_STOP 是唯一不需要驗證的操作

## 難度說明
**Hard** - 需要理解 configure 的多個執行路徑和狀態轉換。
