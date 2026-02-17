# Q004 [Hard]: Batched Location Delivery Fails

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testBatchedLocationUpdates
java.lang.AssertionError: 
Expected: Batch of 5 locations delivered together
Actual: Locations delivered one by one (no batching)
    at android.location.cts.fine.LocationManagerFineTest.testBatchedLocationUpdates(LocationManagerFineTest.java:645)
```

## 失敗的測試代碼片段

```java
@Test
public void testBatchedLocationUpdates() throws Exception {
    // 請求批次位置更新（每 5 秒一次，最多延遲 30 秒批次傳送）
    LocationRequest request = new LocationRequest.Builder(5000)
        .setMaxUpdateDelayMillis(30000)  // 最多延遲 30 秒批次傳送
        .build();
    
    List<LocationResult> results = new ArrayList<>();
    LocationListener listener = new LocationListener() {
        @Override
        public void onLocationChanged(List<Location> locations) {
            // 批次傳送會呼叫這個方法，傳入多個位置
            results.add(LocationResult.wrap(locations));
        }
    };
    
    mManager.requestLocationUpdates(TEST_PROVIDER, request, DIRECT_EXECUTOR, listener);
    
    // 快速產生 5 個位置
    for (int i = 0; i < 5; i++) {
        mManager.setTestProviderLocation(TEST_PROVIDER, createLocation(TEST_PROVIDER, 37.0 + i * 0.001, -122.0));
        Thread.sleep(1000);
    }
    
    // 等待批次傳送
    Thread.sleep(35000);
    
    // 應該收到一個包含多個位置的批次
    assertThat(results).hasSize(1);  // ← 失敗：收到 5 個單獨的結果
    assertThat(results.get(0).getLocations().size()).isAtLeast(3);
}
```

## 問題描述

設定了 `maxUpdateDelayMillis` 來啟用位置批次傳送，但位置仍然逐個傳送而不是批次傳送。批次傳送對於省電很重要，因為它允許 CPU 在位置收集期間保持休眠。

## 相關源碼位置

呼叫鏈：
1. `frameworks/base/location/java/android/location/LocationRequest.java`
2. `frameworks/base/services/core/java/com/android/server/location/LocationManagerService.java`
3. `frameworks/base/services/core/java/com/android/server/location/provider/LocationProviderManager.java`
4. `frameworks/base/services/core/java/com/android/server/location/gnss/GnssLocationProvider.java`

## 調試提示

1. `maxUpdateDelayMillis` 如何影響傳送行為？
2. 位置是如何緩存和批次傳送的？
3. 傳送邏輯在哪個類別中？

## 任務

追蹤批次傳送邏輯，找出批次功能失效的原因。
