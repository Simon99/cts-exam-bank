# Q006 [Hard]: Geofence Exit Event Lost During Power Save

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testGeofenceExitDuringDoze
java.lang.AssertionError: 
Expected: Geofence exit event received after leaving power save mode
Actual: No exit event received, still shows as inside geofence
    at android.location.cts.fine.LocationManagerFineTest.testGeofenceExitDuringDoze(LocationManagerFineTest.java:1256)
```

## 失敗的測試代碼片段

```java
@Test
public void testGeofenceExitDuringDoze() throws Exception {
    double lat = 37.422, lon = -122.084;
    float radius = 100f;
    
    ProximityPendingIntentCapture capture = new ProximityPendingIntentCapture(mContext);
    mManager.addProximityAlert(lat, lon, radius, -1, capture.getPendingIntent());
    
    // 設定位置在 geofence 內部
    mManager.setTestProviderLocation(TEST_PROVIDER, createLocation(TEST_PROVIDER, lat, lon));
    Intent enterIntent = capture.getNextIntent(5000);
    assertThat(enterIntent.getBooleanExtra(KEY_PROXIMITY_ENTERING, false)).isTrue();
    
    // 模擬進入省電模式
    setDeviceIdleMode(true);
    Thread.sleep(1000);
    
    // 在省電模式期間移動到 geofence 外部
    mManager.setTestProviderLocation(TEST_PROVIDER, 
        createLocation(TEST_PROVIDER, lat + 0.01, lon));  // ~1km away
    
    // 退出省電模式
    setDeviceIdleMode(false);
    Thread.sleep(2000);
    
    // 應該收到 exit 事件
    Intent exitIntent = capture.getNextIntent(10000);  // ← 超時，未收到
    assertThat(exitIntent).isNotNull();
    assertThat(exitIntent.getBooleanExtra(KEY_PROXIMITY_ENTERING, true)).isFalse();
}
```

## 問題描述

當設備在省電模式（Doze）期間移出 geofence，退出省電模式後應該立即檢測並報告 exit 事件。但實際上 exit 事件丟失了。

## 相關源碼位置

呼叫鏈：
1. `frameworks/base/services/core/java/com/android/server/location/geofence/GeofenceManager.java`
2. `frameworks/base/services/core/java/com/android/server/location/provider/LocationProviderManager.java`
3. `frameworks/base/services/core/java/com/android/server/location/injector/SystemLocationPowerSaveModeHelper.java`

## 調試提示

1. 省電模式如何影響位置更新的傳遞？
2. 退出省電模式時，如何重新評估 geofence 狀態？
3. GeofenceManager 如何處理狀態恢復？

## 任務

找出省電模式期間 geofence 事件丟失的原因。
