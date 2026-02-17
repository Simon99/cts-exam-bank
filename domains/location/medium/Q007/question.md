# Q007: Geofence Proximity Alert Never Triggered

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testAddProximityAlert
java.util.concurrent.TimeoutException: Proximity alert was not triggered within 10 seconds
    at android.location.cts.fine.LocationManagerFineTest.testAddProximityAlert(LocationManagerFineTest.java:678)
```

## 失敗的測試代碼片段

```java
@Test
public void testAddProximityAlert() throws Exception {
    double latitude = 37.422;
    double longitude = -122.084;
    float radius = 100f;  // 100 米半徑
    
    ProximityPendingIntentCapture capture = 
        new ProximityPendingIntentCapture(mContext);
    PendingIntent pi = capture.getPendingIntent();
    
    mManager.addProximityAlert(latitude, longitude, radius, -1, pi);
    
    // 設定位置在 geofence 中心
    Location loc = createLocation(TEST_PROVIDER, latitude, longitude);
    mManager.setTestProviderLocation(TEST_PROVIDER, loc);
    
    // 等待收到進入 geofence 的通知
    Intent intent = capture.getNextIntent(10000);  // ← 超時
    assertThat(intent).isNotNull();
    assertThat(intent.getBooleanExtra(LocationManager.KEY_PROXIMITY_ENTERING, false))
        .isTrue();
}
```

## 問題描述

設定了 proximity alert 並將位置設定在 geofence 範圍內，但 PendingIntent 從未被觸發。

## 相關源碼位置

- `frameworks/base/location/java/android/location/LocationManager.java` — addProximityAlert API
- `frameworks/base/services/core/java/com/android/server/location/geofence/GeofenceManager.java` — Geofence 管理

## 調試提示

1. Geofence 的進入/退出判斷邏輯在哪裡？
2. 位置更新如何觸發 geofence 狀態檢查？

## 任務

找出 proximity alert 無法觸發的 bug 並修復。
