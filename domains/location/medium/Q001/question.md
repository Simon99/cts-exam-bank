# Q001: requestLocationUpdates Ignores minUpdateDistanceMeters

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testRequestLocationUpdates_minUpdateDistanceMeters
java.lang.AssertionError: Expected at most 2 location updates with 100m minimum distance, but got 5
    at android.location.cts.fine.LocationManagerFineTest.testRequestLocationUpdates_minUpdateDistanceMeters(LocationManagerFineTest.java:412)
```

## 失敗的測試代碼片段

```java
// Test that minimum distance is respected
LocationRequest request = new LocationRequest.Builder(1000)
    .setMinUpdateDistanceMeters(100)  // 至少移動 100 米才更新
    .build();

LocationListenerCapture capture = new LocationListenerCapture(mContext);
mManager.requestLocationUpdates(TEST_PROVIDER, request, DIRECT_EXECUTOR, capture);

// 發送 5 個位置，都在 10 米範圍內（應該只收到第一個）
for (int i = 0; i < 5; i++) {
    Location loc = createLocation(TEST_PROVIDER, 37.0 + i * 0.00001, -122.0);  // ~1m apart
    mManager.setTestProviderLocation(TEST_PROVIDER, loc);
    Thread.sleep(1100);
}

// 應該最多只收到 1-2 個更新（第一個 + 可能的初始位置）
assertThat(capture.getLocations().size()).isAtMost(2);  // ← 失敗：收到了 5 個
```

## 問題描述

當使用 `setMinUpdateDistanceMeters()` 設定最小更新距離時，即使位置變化小於指定距離，仍然會收到所有位置更新。距離過濾功能似乎被忽略了。

## 相關源碼位置

- `frameworks/base/location/java/android/location/LocationManager.java` — 客戶端 API
- `frameworks/base/services/core/java/com/android/server/location/provider/LocationProviderManager.java` — 伺服器端處理

## 調試提示

追蹤 LocationRequest 的 minUpdateDistanceMeters 參數：
1. 客戶端如何傳遞這個參數？
2. 伺服器端如何使用這個參數來過濾位置更新？

## 任務

找出導致距離過濾失效的 bug 並修復。
