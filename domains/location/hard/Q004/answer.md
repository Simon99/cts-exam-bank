# Q004 答案 [Hard]：Batched Location Delivery Fails

## Bug 位置（2 處）

### Bug 1: LocationProviderManager.java
`onNewLocation()` 方法中，批次邏輯被移除，所有位置都立即傳送：
```java
// 遺漏：檢查 maxUpdateDelay 並緩存位置
```

### Bug 2: GnssLocationProvider.java
硬體批次設定被 hardcode 為 1，禁用了硬體層面的批次：
```java
int batchSize = 1;  // ← BUG: 應該計算實際的 batch size
```

## 完整呼叫鏈

```
LocationManager.requestLocationUpdates(request)
    → LocationProviderManager.registerListener()
        → 儲存 request (包含 maxUpdateDelayMillis)
    
(位置更新到達)
GnssLocationProvider.onReportLocation()
    → LocationProviderManager.onLocationChanged()
        → Registration.onNewLocation() ← BUG 1: 批次邏輯缺失
            → deliverLocation() (立即傳送)

GnssLocationProvider.onSetRequest()  ← BUG 2: batchSize = 1
    → mGnssNative.startBatch(1) (實際上禁用批次)
```

## 修復方案

### 修復 Bug 1 (LocationProviderManager.java)
```java
private void onNewLocation(Location location) {
    long maxUpdateDelay = mRequest.getMaxUpdateDelayMillis();
    if (maxUpdateDelay > 0) {
        mPendingLocations.add(location);
        if (!mBatchDeliveryScheduled) {
            scheduleBatchDelivery(maxUpdateDelay);
        }
    } else {
        deliverLocation(location);
    }
}
```

### 修復 Bug 2 (GnssLocationProvider.java)
```java
int batchSize = calculateBatchSize(request);  // 正確計算
```

## 教學重點

1. **位置批次**：省電優化，允許硬體收集多個位置後一次傳送
2. **軟體 vs 硬體批次**：LocationProviderManager 處理軟體層，GnssLocationProvider 處理硬體層
3. **maxUpdateDelayMillis**：控制批次傳送的最大延遲時間
