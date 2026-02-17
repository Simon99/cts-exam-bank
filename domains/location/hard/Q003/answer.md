# Q003 答案 [Hard]：GNSS Measurement Full Tracking Mode Ignored

## Bug 位置（2 處）

### Bug 1: mergeRegistrations() 方法
合併多個 listener 的請求時，沒有正確合併 `fullTracking` 設定：
```java
// 遺漏：fullTracking |= request.isFullTracking();
```

### Bug 2: registerWithService() 方法
呼叫 HAL 時，直接傳入 `false` 而不是合併後的值：
```java
mGnssNative.startMeasurementCollection(
    false,  // ← BUG: 應該是 request.isFullTracking()
    ...);
```

## 完整呼叫鏈

```
LocationManager.registerGnssMeasurementsCallback(request, ...)
    → GnssManagerService.registerGnssMeasurementsCallback()
        → GnssMeasurementsProvider.addListener()
            → mergeRegistrations() ← BUG 1: fullTracking 不合併
                → registerWithService() ← BUG 2: hardcoded false
                    → GnssNative.startMeasurementCollection(false, ...)
                        → HAL 使用標準模式
```

## 修復方案

### 修復 Bug 1 (mergeRegistrations)
```java
for (GnssListenerRegistration reg : registrations) {
    GnssMeasurementRequest request = reg.getRequest();
    fullTracking |= request.isFullTracking();  // 加回這行
    intervalMs = Math.min(intervalMs, request.getIntervalMillis());
}
```

### 修復 Bug 2 (registerWithService)
```java
mGnssNative.startMeasurementCollection(
    request.isFullTracking(),  // 使用合併後的值
    request.isCorrelationVectorOutputsEnabled(),
    request.getIntervalMillis());
```

## 教學重點

1. **請求合併**：多個 App 的請求需要合併，取最嚴格的設定
2. **Boolean 合併邏輯**：fullTracking 用 OR（任何一個要求就啟用）
3. **Interval 合併邏輯**：intervalMs 用 MIN（取最短間隔）
4. **HAL 介面**：參數必須正確傳遞到硬體抽象層
